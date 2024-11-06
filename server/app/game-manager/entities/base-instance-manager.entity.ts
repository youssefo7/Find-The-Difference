/* eslint-disable max-lines */
import { userRoomPrefix } from '@app/auth/auth.guard';
import { WaitingGamesService } from '@app/waiting-games/waiting-games.service';
import {
    HIGH_SCORE_MONEY,
    HINT_COOLDOWN_TIME_MS,
    IMAGE_HEIGHT,
    IMAGE_WIDTH,
    MS_PER_SECOND,
    PENALTY_COOLDOWN_TIME_MS,
    SERVER_USERNAME,
    WIN_MONEY,
} from '@common/constants';
import { GameMode, TIME_LIMIT_PREFIX, Vec2 } from '@common/game-template';
import { HistoryDto } from '@common/history';
import { ChatId, InstanceId, TeamIndex, UnixTimeMs, Username } from '@common/ingame-ids.types';
import { UsernameDto } from '@common/websocket/all-events.dto';
import {
    ChangeTemplateDto,
    CheatModeDto,
    DifferenceFoundDto,
    DifferenceNotFoundDto,
    EndGameDto,
    InGameEvent,
    ReceiveHintDto,
    RemovePixelsDto,
    SendHintDto,
    StartGameDto,
    StateDto,
} from '@common/websocket/in-game.dto';
import { ObserverGameDto, TimeConfigDto } from '@common/websocket/waiting-room.dto';
import { WsException } from '@nestjs/websockets';
import { randomUUID } from 'crypto';
import { BaseCreateInstance, ImagesDifferencesForGame } from './../dto/create-game.dto';
import { TeamData, TimeData } from './../dto/game-data.dto';
import { GameManagerService } from './../game-manager.service';

export abstract class BaseInstanceManager {
    readonly instanceId: InstanceId;
    readonly chatId: ChatId;
    protected teams: Record<TeamIndex, TeamData> = {};
    protected usernameToTeamIndex: Record<Username, TeamIndex> = {};
    protected usernames: Set<Username> = new Set<Username>();
    protected discoveredDifferences: Set<number> = new Set<number>();
    protected clock: TimeData;
    protected gameMode: GameMode;
    protected timeConfig: TimeConfigDto;
    protected quitters: Username[] = [];

    protected observers: Map<Username, UnixTimeMs> = new Map<Username, UnixTimeMs>();

    private privateIsRunning: boolean = false;

    constructor(
        createDto: BaseCreateInstance,
        protected differences: ImagesDifferencesForGame,
    ) {
        this.instanceId = randomUUID();
        this.chatId = createDto.chatId;
        this.gameMode = createDto.gameMode;
        this.timeConfig = createDto.timeConfig;
        createDto.teams.forEach((team, index) => {
            this.addTeam(team, index);
        });
    }

    get observerGameDto(): ObserverGameDto {
        // eslint-disable-next-line no-underscore-dangle
        return {
            gameMode: this.gameMode,
            instanceId: this.instanceId,
            players: [...this.usernames],
            // eslint-disable-next-line no-underscore-dangle
            templateId: this.differences._id,
            hasObservers: this.observers.size > 0,
        };
    }

    get historyService() {
        return GameManagerService.historyService;
    }

    get chatService() {
        return GameManagerService.chatService;
    }

    get userService() {
        return GameManagerService.userService;
    }

    get gameTemplateService() {
        return GameManagerService.gameTemplateService;
    }

    get webSocketServer() {
        return GameManagerService.webSocketServer;
    }

    get isRunning(): boolean {
        return this.privateIsRunning;
    }

    get playerCount(): number {
        return this.usernames.size;
    }
    get teamCount(): number {
        return Object.keys(this.teams).length;
    }

    get isTimeLimit(): boolean {
        return this.gameMode.startsWith(TIME_LIMIT_PREFIX);
    }
    protected abstract get differencesToFind(): number;

    // eslint-disable-next-line @typescript-eslint/adjacent-overload-signatures
    set isRunning(value: boolean) {
        if (value === this.privateIsRunning) return;
        this.privateIsRunning = value;
        setTimeout(() => WaitingGamesService.broadcastWaitingGames(), 0);
    }

    addObserver(username: Username) {
        this.webSocketServer.to(this.instanceId).emit(InGameEvent.ObserverJoinedEvent, { username } as UsernameDto);
        this.webSocketServer.to(userRoomPrefix + username).socketsJoin(this.instanceId);
        this.observers.set(username, Date.now() - HINT_COOLDOWN_TIME_MS);

        const startGameDto: StartGameDto = {
            nGroups: this.differencesToFind,
            teams: Object.entries(this.teams).reduce((teams, [index, team]) => {
                return { [parseInt(index, 10)]: team.players, ...teams };
            }, {}),
            timeConfig: this.timeConfig,
        };
        const playerScore: Record<Username, number> = {};
        Object.values(this.teams).forEach((team: TeamData) => team.players.forEach((player) => (playerScore[player] = team.score)));

        this.webSocketServer.to(userRoomPrefix + username).emit(InGameEvent.ObserverStateSync, {
            observers: [...this.observers].map(([observer]) => observer),
            pixelToRemove: this.differences.groupToPixels.filter((_pixels, i) => this.discoveredDifferences.has(i)).flat(),
            startGameDto,
            playerScore,
            timeLimitPreload: this.getTimeLimitPreload(),
        } as StateDto);
        this.chatService.addUserToChat(this.chatId, username, true);
    }

    identifyDifference(position: Vec2, username: Username): boolean {
        const teamIndex = this.usernameToTeamIndex[username];
        if (!this.isRunning) return false;
        // check click delay from user
        if (this.onCooldown(teamIndex)) throw new WsException('Player is on cooldown');

        const diff = this.differences.pixelToGroup[position.x][position.y];

        // We didn't click on a difference or it was already discovered
        if (diff === null || this.discoveredDifferences.has(diff)) {
            this.teams[teamIndex].lastClickTimestamp = Date.now();
            const differenceNotFoundDto: DifferenceNotFoundDto = { username, time: Date.now() };
            this.webSocketServer.to(this.instanceId).emit(InGameEvent.DifferenceNotFound, differenceNotFoundDto);
            this.chatService.addServerMessageToChat(this.chatId, `${username} made an error.`, `${username} a fait une erreur.`);
            return false;
        }

        const differenceFoundDto: DifferenceFoundDto = { username, time: Date.now() };
        this.webSocketServer.to(this.instanceId).emit(InGameEvent.DifferenceFound, differenceFoundDto);
        this.chatService.addServerMessageToChat(this.chatId, `${username} found a difference.`, `${username} a trouvé une différence.`);

        const removePixelsDto: RemovePixelsDto = { pixels: this.differences.groupToPixels[diff] };
        this.webSocketServer.to(this.instanceId).emit(InGameEvent.RemovePixels, removePixelsDto);

        this.discoveredDifferences.add(diff);
        this.teams[teamIndex].score++;
        this.onDifferenceFound(teamIndex);

        return true;
    }

    removePlayer(username: Username): void {
        this.chatService.removeUserFromChat(this.chatId, username, true);
        if (this.observers.delete(username)) {
            this.webSocketServer.to(this.instanceId).emit(InGameEvent.ObserverLeavedEvent, { username } as UsernameDto);
            WaitingGamesService.broadcastWaitingGames();
            return;
        }

        const teamIndex = this.usernameToTeamIndex[username];
        delete this.usernameToTeamIndex[username];
        this.teams[teamIndex].players = this.teams[teamIndex].players.filter((teamMember) => teamMember !== username);
        if (this.teams[teamIndex].players.length === 0) {
            delete this.teams[teamIndex];
        }
        this.usernames.delete(username);

        if (this.isRunning) {
            this.webSocketServer.to(this.instanceId).emit(InGameEvent.PlayerLeave, { username } as UsernameDto);
            this.chatService.addServerMessageToChat(this.chatId, `${username} gave up the game.`, `${username} a abandonné la partie.`);
            this.quitters.push(username);
            this.onPlayerLeave();
        }
    }

    createHistoryEntry(winners: Username[], losers: Username[]): void {
        const now = new Date();
        const totalTimeDate = new Date(now.getTime() - this.clock.startTime);
        const startTimeDate = new Date(this.clock.startTime);
        const totalTimeNumber = totalTimeDate.getTime();
        const startTimeNumber = startTimeDate.getTime();

        const historyDto: HistoryDto = {
            startTime: startTimeNumber,
            totalTime: totalTimeNumber,
            gameMode: this.gameMode,
            winners,
            losers,
            quitters: this.quitters,
        };

        this.historyService.create(historyDto);
    }

    endGame(): void {
        this.isRunning = false;
        clearInterval(this.clock.intervalId);
        [...this.observers].forEach(([observer]) => GameManagerService.quitGame(observer));
        this.usernames.forEach((username) => GameManagerService.quitGame(username));
    }

    buyHint(username: Username): void {
        if (!this.isRunning) return;
        const serverUser: UsernameDto = { username: SERVER_USERNAME };
        GameManagerService.webSocketServer.to(userRoomPrefix + username).emit(InGameEvent.ObserverJoinedEvent, serverUser);

        const notFound = this.differences.groupToPixels.filter((value, index) => !this.discoveredDifferences.has(index));
        if (!notFound) return;
        const difference = notFound[Math.floor(Math.random() * notFound.length)];
        const minmax: [Vec2, Vec2] = difference.reduce(
            (minmaxTemp, value) => [
                { x: Math.min(minmaxTemp[0].x, value.x), y: Math.min(minmaxTemp[0].y, value.y) },
                { x: Math.max(minmaxTemp[1].x, value.x), y: Math.max(minmaxTemp[1].y, value.y) },
            ],
            [
                { x: IMAGE_WIDTH, y: IMAGE_HEIGHT },
                { x: 0, y: 0 },
            ],
        );
        GameManagerService.webSocketServer.to(userRoomPrefix + username).emit(InGameEvent.ReceiveHint, {
            rect: [minmax[0], { x: minmax[1].x - minmax[0].x, y: minmax[1].y - minmax[0].y }],
            sender: SERVER_USERNAME,
        } as ReceiveHintDto);

        setTimeout(
            () => GameManagerService.webSocketServer.to(userRoomPrefix + username).emit(InGameEvent.ObserverLeavedEvent, serverUser),
            HINT_COOLDOWN_TIME_MS,
        );
    }

    sendHint(sendHintDto: SendHintDto, sender: Username): void {
        const observerlastSend: UnixTimeMs | undefined = this.observers.get(sender);
        if (!observerlastSend) return;
        if (Date.now() - observerlastSend <= HINT_COOLDOWN_TIME_MS) throw new WsException('Hint is on cooldown');

        const receiveHintDto: ReceiveHintDto = { rect: sendHintDto.rect, sender };
        if (sendHintDto.player) {
            this.webSocketServer.to(userRoomPrefix + sendHintDto.player).emit(InGameEvent.ReceiveHint, receiveHintDto);
            this.webSocketServer.to(userRoomPrefix + sender).emit(InGameEvent.ReceiveHint, receiveHintDto);
        } else {
            this.webSocketServer.to(this.instanceId).emit(InGameEvent.ReceiveHint, receiveHintDto);
        }
        this.observers.set(sender, Date.now());
    }

    async sendWinnersLosers(winners: Username[]): Promise<void> {
        if (!this.isRunning) {
            this.endGame();
            return;
        }
        const totalTimeMs = this.getRemainingTime();
        const losers = [...this.usernames].filter((username) => {
            return !winners.some((winner) => winner === username);
        });
        const observers = [...this.observers].map(([observer]) => observer);
        this.createHistoryEntry(winners, losers);

        const endGameDto: EndGameDto = { winners, losers, totalTimeMs, pointsReceived: 0 };

        losers.forEach((winner) => this.webSocketServer.to(userRoomPrefix + winner).emit(InGameEvent.EndGame, endGameDto));
        observers.forEach((winner) => this.webSocketServer.to(userRoomPrefix + winner).emit(InGameEvent.EndGame, endGameDto));

        this.gameTemplateService
            .isHighScore(
                this.gameMode,
                Date.now() - this.clock.startTime,
                // eslint-disable-next-line no-underscore-dangle
                this.isTimeLimit ? undefined : this.differences._id,
            )
            .then((newHighScore) => {
                endGameDto.pointsReceived = newHighScore ? HIGH_SCORE_MONEY : WIN_MONEY;

                winners.forEach((winner) => {
                    this.webSocketServer.to(userRoomPrefix + winner).emit(InGameEvent.EndGame, endGameDto);
                    this.userService.updateUserBalance(winner, endGameDto.pointsReceived, () => undefined);
                });
            });

        this.endGame();
    }

    sendCheatModePixels(username: Username): void {
        if (!this.timeConfig.cheatModeAllowed) return;
        const groupToPixels = this.differences.groupToPixels.filter((_pixels, i) => !this.discoveredDifferences.has(i));
        this.webSocketServer.to(userRoomPrefix + username).emit(InGameEvent.CheatModeEvent, { groupToPixels } as CheatModeDto);
    }

    beforeRemoval(): void {
        if (!this.isRunning) return;
        this.webSocketServer.to(this.instanceId).emit(InGameEvent.InstanceDeletion);
        this.webSocketServer.to(this.instanceId).socketsLeave(this.instanceId);
    }

    protected getTimeLimitPreload(): [ChangeTemplateDto, ChangeTemplateDto] | undefined {
        return undefined;
    }

    protected start() {
        this.onStart();
        this.isRunning = true;
        const startGameDto: StartGameDto = {
            nGroups: this.differencesToFind,
            teams: Object.entries(this.teams).reduce((teams, [index, team]) => {
                return { [parseInt(index, 10)]: team.players, ...teams };
            }, {}),
            timeConfig: this.timeConfig,
        };
        this.webSocketServer.to(this.instanceId).emit(InGameEvent.StartGame, startGameDto);
        this.clock = {
            intervalId: setInterval(() => this.emitTick(), MS_PER_SECOND),
            startTime: Date.now(),
            totalDeltaTime: 0,
        };
    }

    protected addTeam(team: Set<Username>, teamIndex: TeamIndex) {
        this.teams[teamIndex] = {
            players: [...team],
            score: 0,
        };
        team.forEach((username) => {
            this.usernames.add(username);
            this.webSocketServer.to(userRoomPrefix + username).socketsJoin(this.instanceId);
            this.usernameToTeamIndex[username] = teamIndex;
        });
    }

    protected getRemainingTime(): number {
        return Math.max(this.timeConfig.totalTime * MS_PER_SECOND - (Date.now() - this.clock.startTime - this.clock.totalDeltaTime), 0);
    }

    protected onCooldown(team: TeamIndex): boolean {
        const lastClickTimestamp = this.teams[team].lastClickTimestamp;
        if (lastClickTimestamp === undefined) {
            return false;
        }

        return Date.now() - lastClickTimestamp <= PENALTY_COOLDOWN_TIME_MS;
    }

    protected addDeltaTime(deltaTimeSeconds: number): void {
        const deltaTimeMs = deltaTimeSeconds * MS_PER_SECOND;
        this.clock.totalDeltaTime += deltaTimeMs;
    }

    protected endGameIfTimeIsOver(): void {
        if (this.getRemainingTime() === 0) {
            this.sendWinnersLosers([]);
        }
    }

    protected abstract emitTick(): void;
    protected abstract onDifferenceFound(team: TeamIndex): void;
    protected abstract onPlayerLeave(): void;
    protected abstract onStart(): void;
}
