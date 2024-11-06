import { userRoomPrefix } from '@app/auth/auth.guard';
import { ChatService } from '@app/chat/chat.service';
import { GameTemplateService } from '@app/game-template/game-template.service';
import { HistoryService } from '@app/history/history.service';
import { UsersService } from '@app/users/users.service';
import { WaitingGamesService } from '@app/waiting-games/waiting-games.service';
import { HINT_PRICE, SERVER_USERNAME } from '@common/constants';
import { GameMode } from '@common/game-template';
import { ChatId, InstanceId, Username } from '@common/ingame-ids.types';
import { IdentifyDifferenceDto, InGameEvent, SendHintDto } from '@common/websocket/in-game.dto';
import { InstantiateGameDto, ObserverGameDto } from '@common/websocket/waiting-room.dto';
import { Inject, Injectable, OnModuleInit, forwardRef } from '@nestjs/common';
import { WebSocketGateway, WebSocketServer, WsException } from '@nestjs/websockets';
import { Server } from 'socket.io';
import { ClassicTeamCreateInstance, TimeLimitCreateInstance } from './dto/create-game.dto';
import { BaseInstanceManager } from './entities/base-instance-manager.entity';
import { ClassicTeamInstanceManager } from './entities/classic-team-instance-manager.entity';
import { TimeLimitSingleDiffInstanceManager } from './entities/time-limit-single-diff-instance-manager.entity';
import { TimeLimitTurnByTurnInstanceManager } from './entities/time-limit-turn-by-turn-instance-manager.entity';

@WebSocketGateway({ cors: true })
@Injectable()
export class GameManagerService implements OnModuleInit {
    private static self: GameManagerService;
    @WebSocketServer() private server: Server;
    instances: Record<InstanceId, BaseInstanceManager> = {};
    playerToInstanceId: Record<Username, InstanceId> = {};

    // eslint-disable-next-line max-params
    constructor(
        @Inject(forwardRef(() => GameTemplateService)) private gameTemplateService: GameTemplateService,
        private readonly historyService: HistoryService,
        private readonly chatService: ChatService,
        private readonly userService: UsersService,
    ) {}

    static get historyService() {
        return this.self.historyService;
    }

    static get chatService() {
        return this.self.chatService;
    }

    static get webSocketServer() {
        return this.self.server;
    }

    static get userService() {
        return this.self.userService;
    }

    static get gameTemplateService() {
        return this.self.gameTemplateService;
    }

    static quitGame(username: Username) {
        GameManagerService.self.quitGame(username);
    }

    async buyHint(username: Username) {
        const instance = this.getInstanceFromUsername(username);
        await this.userService.updateUserBalance(username, -HINT_PRICE, () => instance.buyHint(username));
    }

    onModuleInit() {
        GameManagerService.self = this;
    }

    joinGameObserver(username: Username, instanceId: InstanceId) {
        const instance = this.instances[instanceId];
        if (!instance || !instance.isRunning) {
            this.server.to(userRoomPrefix + username).emit(InGameEvent.InstanceDeletion);
            return;
        }

        this.playerToInstanceId[username] = instanceId;

        instance.addObserver(username);
        WaitingGamesService.broadcastWaitingGames();
    }

    getObservableGames(): ObserverGameDto[] {
        return Object.values(this.instances)
            .filter((instance) => instance.isRunning)
            .map((instance) => instance.observerGameDto);
    }

    quitGame(username: Username) {
        const instanceId = this.playerToInstanceId[username];
        if (!instanceId) {
            return;
        }
        const instance = this.instances[instanceId];
        if (!instance) {
            return;
        }

        instance.removePlayer(username);
        delete this.playerToInstanceId[username];

        if (instance.playerCount <= 0) {
            delete this.instances[instanceId];
            this.chatService.deleteChat(instance.chatId, SERVER_USERNAME);
            instance.beforeRemoval();
            instance.endGame();
        }

        this.server.in(userRoomPrefix + username).socketsLeave(instanceId);
    }

    getInstanceFromUsername(username: Username) {
        const instanceId = this.playerToInstanceId[username];
        const instance = this.instances[instanceId];
        if (instance === undefined) {
            throw new WsException('Instance not found');
        }
        return instance;
    }

    identifyDifference(difference: IdentifyDifferenceDto, username: Username): boolean {
        const position = difference.position;
        const instance = this.getInstanceFromUsername(username);
        return instance.identifyDifference(position, username);
    }

    sendCheatModePixels(username: Username): void {
        const instance = this.getInstanceFromUsername(username);
        instance.sendCheatModePixels(username);
    }

    sendHint(sendHintDto: SendHintDto, sender: Username): void {
        const instance = this.getInstanceFromUsername(sender);
        instance.sendHint(sendHintDto, sender);
    }

    // eslint-disable-next-line max-params
    async instantiateGame(
        instantiateGameDto: InstantiateGameDto,
        teams: Set<Username>[],
        creator: Username,
        chatId: ChatId,
    ): Promise<BaseInstanceManager> {
        const { gameMode } = instantiateGameDto;
        let instance: BaseInstanceManager;
        switch (gameMode) {
            case GameMode.ClassicMultiplayer:
            case GameMode.TeamClassic:
                instance = await this.createClassicTeamInstanceManager(instantiateGameDto, teams, chatId);
                break;
            case GameMode.TimeLimitAugmented:
            case GameMode.TimeLimitSingleDiff:
                instance = await this.createTimeLimitSingleDiffInstanceManager(instantiateGameDto, teams, creator, chatId);
                break;
            case GameMode.TimeLimitTurnByTurn:
                instance = await this.createTimeLimitTurnByTurnInstanceManager(instantiateGameDto, teams, creator, chatId);
        }
        teams.forEach((team) =>
            team.forEach((username) => {
                this.playerToInstanceId[username] = instance.instanceId;
            }),
        );
        this.instances[instance.instanceId] = instance;
        return instance;
    }

    // eslint-disable-next-line max-params
    private async createTimeLimitTurnByTurnInstanceManager(
        instantiateGameDto: InstantiateGameDto,
        teams: Set<Username>[],
        creator: Username,
        chatId: ChatId,
    ) {
        const { gameMode, timeConfig } = instantiateGameDto;
        const inventory = (await this.userService.getUserInventory(creator)) || [];
        const creationDto: TimeLimitCreateInstance = {
            gameTemplates: await this.gameTemplateService.findAllImagesDifferencesForGame(creator, inventory),
            gameMode,
            timeConfig,
            teams,
            chatId,
        };
        return new TimeLimitTurnByTurnInstanceManager(creationDto);
    }

    // eslint-disable-next-line max-params
    private async createTimeLimitSingleDiffInstanceManager(
        instantiateGameDto: InstantiateGameDto,
        teams: Set<Username>[],
        creator: Username,
        chatId: ChatId,
    ) {
        const { gameMode, timeConfig } = instantiateGameDto;
        const inventory = (await this.userService.getUserInventory(creator)) || [];
        const creationDto: TimeLimitCreateInstance = {
            gameTemplates: await this.gameTemplateService.findAllImagesDifferencesForGame(creator, inventory),
            gameMode,
            timeConfig,
            teams,
            chatId,
        };
        return new TimeLimitSingleDiffInstanceManager(creationDto);
    }

    private async createClassicTeamInstanceManager(instantiateGameDto: InstantiateGameDto, teams: Set<Username>[], chatId: ChatId) {
        const { gameTemplateId, gameMode, timeConfig } = instantiateGameDto;
        const differences = await this.gameTemplateService.getImagesDifferencesForGame(gameTemplateId);
        if (!differences) {
            teams.forEach((team) => team.forEach((username) => this.server.to(userRoomPrefix + username).emit(InGameEvent.InstanceDeletion)));
            throw new WsException('Invalid Game Template Id');
        }
        const creationDto: ClassicTeamCreateInstance = {
            gameMode,
            timeConfig,
            teams,
            chatId,
        };
        return new ClassicTeamInstanceManager(creationDto, { ...differences, _id: gameTemplateId });
    }
}
