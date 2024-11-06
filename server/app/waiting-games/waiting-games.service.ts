import { userRoomPrefix } from '@app/auth/auth.guard';
import { ChatService } from '@app/chat/chat.service';
import { TimeLimitSingleDiffInstanceManager } from '@app/game-manager/entities/time-limit-single-diff-instance-manager.entity';
import { TimeLimitTurnByTurnInstanceManager } from '@app/game-manager/entities/time-limit-turn-by-turn-instance-manager.entity';
import { GameManagerService } from '@app/game-manager/game-manager.service';
import { GameTemplateId, InstanceId, TeamIndex, Username } from '@common/ingame-ids.types';
import { InGameEvent } from '@common/websocket/in-game.dto';
import { Inject, Injectable, OnModuleInit, forwardRef } from '@nestjs/common';
import { WebSocketGateway, WebSocketServer, WsException } from '@nestjs/websockets';
import { InstantiateGameDto, JoinGameDto, WaitingGameDto, WaitingGamesListDto, WaitingRoomEvent } from '@websocket/waiting-room.dto';
import { Server } from 'socket.io';
import { WaitingInstance } from './entities/waiting-instance.entity';

@WebSocketGateway({ cors: true })
@Injectable()
export class WaitingGamesService implements OnModuleInit {
    private static self: WaitingGamesService;
    @WebSocketServer() private server: Server;
    waitingInstances: Record<InstanceId, WaitingInstance> = {};
    playerToWaitingInstanceId: Record<Username, InstanceId> = {};

    constructor(
        @Inject(forwardRef(() => GameManagerService)) private gameManagerService: GameManagerService,
        private readonly chatService: ChatService,
    ) {}

    static get webSocketServer() {
        return this.self.server;
    }

    static get chatService() {
        return this.self.chatService;
    }

    static broadcastWaitingGames() {
        WaitingGamesService.self.broadcastWaitingGames();
    }

    onModuleInit() {
        WaitingGamesService.self = this;
    }

    async instantiate(instantiateGameDto: InstantiateGameDto, username: Username): Promise<void> {
        const waitingInstance = this.instantiateWaitingGame(instantiateGameDto, username);

        this.playerToWaitingInstanceId[username] = waitingInstance.instanceId;
    }

    async join(joinGameDto: JoinGameDto, username: Username): Promise<void> {
        const waitingInstance = this.waitingInstances[joinGameDto.instanceId];
        if (!waitingInstance) {
            this.server.to(userRoomPrefix + username).emit(InGameEvent.InstanceDeletion);
            throw new WsException('Invalid Game Instance Id');
        }
        this.playerToWaitingInstanceId[username] = waitingInstance.instanceId;

        waitingInstance.addWaitingPlayer(username);
    }

    quitWaitingInstance(username: Username) {
        const instanceId = this.playerToWaitingInstanceId[username];
        if (!instanceId) return;
        const waitingInstance = this.waitingInstances[instanceId];
        if (!waitingInstance) return;

        if (waitingInstance.gameMaster === username) {
            this.removeInstance(waitingInstance);
            return;
        }
        waitingInstance.removePlayer(username);
        delete this.playerToWaitingInstanceId[username];
    }

    sendWaitingGames(username: Username) {
        const waitingGames: WaitingGamesListDto = {
            waitingGames: this.getWaitingGames(),
            observerGames: this.gameManagerService.getObservableGames(),
        };
        this.server.to(userRoomPrefix + username).emit(WaitingRoomEvent.WaitingGames, waitingGames);
    }

    broadcastWaitingGames() {
        const waitingGames: WaitingGamesListDto = {
            waitingGames: this.getWaitingGames(),
            observerGames: this.gameManagerService.getObservableGames(),
        };
        this.server.emit(WaitingRoomEvent.WaitingGames, waitingGames);
    }

    getWaitingGames(): WaitingGameDto[] {
        return Object.values(this.waitingInstances).map((waitingInstance) => waitingInstance.waitingGameDto);
    }

    approvePlayer(username: Username, gameMaster: Username) {
        const waitingInstance = this.getInstanceFromUsername(gameMaster);
        if (gameMaster !== waitingInstance.gameMaster) return;
        waitingInstance.approveJoinRequest(username);
    }

    getInstanceFromUsername(username: Username) {
        const instanceId = this.playerToWaitingInstanceId[username];
        const waitingInstance = this.waitingInstances[instanceId];
        if (!waitingInstance) throw new WsException('Instance not found');
        return waitingInstance;
    }

    rejectPlayer(username: Username, gameMaster: Username) {
        const waitingInstance = this.getInstanceFromUsername(gameMaster);
        if (gameMaster !== waitingInstance.gameMaster) return;
        waitingInstance.rejectJoinRequest(username);
    }

    onTemplateDeletion(gameTemplateId: GameTemplateId): void {
        TimeLimitSingleDiffInstanceManager.onTemplateDeletion(gameTemplateId);
        TimeLimitTurnByTurnInstanceManager.onTemplateDeletion(gameTemplateId);
        for (const waitingInstance of Object.values(this.waitingInstances)) {
            if (waitingInstance.instantiateGameDto.gameTemplateId !== gameTemplateId) continue;
            this.removeInstance(waitingInstance);
        }
    }

    endSelection(gameMaster: Username) {
        const waitingInstance = this.getInstanceFromUsername(gameMaster);
        if (gameMaster !== waitingInstance.gameMaster) return;
        waitingInstance.startIfReady();
    }

    changeTeam(username: Username, newTeam: TeamIndex) {
        const waitingInstance = this.getInstanceFromUsername(username);
        waitingInstance.changeTeam(username, newTeam);
    }

    private instantiateWaitingGame(instantiateGameDto: InstantiateGameDto, username: Username): WaitingInstance {
        const waitingInstance = new WaitingInstance(
            instantiateGameDto,
            (instance) => {
                this.removeInstance(instance);
                this.gameManagerService.instantiateGame(instance.instantiateGameDto, instance.teams, instance.gameMaster, instance.chatId);
            },
            username,
        );
        this.waitingInstances[waitingInstance.instanceId] = waitingInstance;
        this.broadcastWaitingGames();
        return waitingInstance;
    }

    private removeInstance(waitingInstance: WaitingInstance) {
        waitingInstance.onDeletion();
        waitingInstance.approvedPlayers.forEach((player) => delete this.playerToWaitingInstanceId[player]);
        delete this.waitingInstances[waitingInstance.instanceId];
        this.broadcastWaitingGames();
    }
}
