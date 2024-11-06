import { userRoomPrefix } from '@app/auth/auth.guard';
import { SERVER_USERNAME } from '@common/constants';
import { GameMode } from '@common/game-template';
import { ChatId, InstanceId, Username } from '@common/ingame-ids.types';
import { InGameEvent } from '@common/websocket/in-game.dto';
import { InstantiateGameDto, JoinRequestsDto, WaitingGameDto, WaitingRoomEvent } from '@common/websocket/waiting-room.dto';
import { WsException } from '@nestjs/websockets';
import { randomUUID } from 'crypto';
import { WaitingGamesService } from './../waiting-games.service';

interface TeamFormat {
    minPlayerPerTeam: number;
    maxPlayerPerTeam: number;
    maxTeam: number;
    minTeam: number;
}

export class WaitingInstance {
    gameStarted: boolean = false;
    readonly instanceId: InstanceId;
    readonly chatId: ChatId;
    teams: Set<Username>[] = [];
    approvedPlayers: Set<Username> = new Set<Username>();
    private waitingPlayers: Set<Username> = new Set<Username>();

    constructor(
        readonly instantiateGameDto: InstantiateGameDto,
        private startCb: (instance: WaitingInstance) => void,
        readonly gameMaster: Username,
    ) {
        this.chatId = this.chatService.createChat(gameMaster, SERVER_USERNAME, true);
        this.chatService.addUserToChat(this.chatId, gameMaster, true);
        const teamFormat = this.getTeamFormat();
        for (let i = 0; i < teamFormat.maxTeam; i++) {
            this.teams.push(new Set<Username>());
        }
        this.instanceId = randomUUID();
        this.webSocketServer.to(userRoomPrefix + gameMaster).emit(WaitingRoomEvent.AssignGameMaster);
        this.approveJoinRequest(gameMaster);
    }

    get webSocketServer() {
        return WaitingGamesService.webSocketServer;
    }

    get chatService() {
        return WaitingGamesService.chatService;
    }

    get waitingGameDto(): WaitingGameDto {
        return {
            templateId: this.instantiateGameDto.gameTemplateId,
            instanceId: this.instanceId,
            creator: this.gameMaster,
            gameMode: this.instantiateGameDto.gameMode,
            players: [...this.approvedPlayers],
        };
    }

    addWaitingPlayer(username: Username): void {
        this.waitingPlayers.add(username);
        this.chatService.addUserToChat(this.chatId, username, true);
        this.updatePlayerList();
    }

    approveJoinRequest(username: Username): void {
        const teamFormat = this.getTeamFormat();
        if (this.approvedPlayers.has(username)) return;
        if (this.approvedPlayers.size >= teamFormat.maxPlayerPerTeam * teamFormat.maxTeam) throw new WsException('Instance is Full');
        this.approvedPlayers.add(username);
        for (const team of this.teams) {
            if (team.size < teamFormat.maxPlayerPerTeam) {
                team.add(username);
                break;
            }
        }
        this.waitingPlayers.delete(username);
        this.webSocketServer.to(userRoomPrefix + username).socketsJoin(this.instanceId);
        this.updatePlayerList();
    }

    rejectJoinRequest(username: Username): void {
        this.waitingPlayers.delete(username);
        this.webSocketServer.to(userRoomPrefix + username).emit(WaitingRoomEvent.WaitingRefusal);
        this.updatePlayerList();
    }

    removePlayer(username: Username): void {
        this.chatService.removeUserFromChat(this.chatId, username, true);
        this.waitingPlayers.delete(username);
        this.approvedPlayers.delete(username);
        this.teams.forEach((team) => team.delete(username));
        this.webSocketServer.to(userRoomPrefix + username).socketsLeave(this.instanceId);
        this.updatePlayerList();
    }

    updatePlayerList(): void {
        this.webSocketServer.to(this.instanceId).emit(WaitingRoomEvent.JoinRequests, {
            requests: [...this.waitingPlayers],
            players: [...this.approvedPlayers],
            teams: this.teams.map((team) => [...team]),
        } as JoinRequestsDto);
        WaitingGamesService.broadcastWaitingGames();
    }

    startIfReady(): void {
        if (this.isReady()) {
            this.gameStarted = true;
            this.teams = this.teams.filter((team) => team.size !== 0);
            this.webSocketServer.to(this.instanceId).socketsLeave(this.instanceId);
            this.startCb(this);
        } else {
            this.webSocketServer.to(userRoomPrefix + this.gameMaster).emit(WaitingRoomEvent.InvalidStartingState);
        }
    }

    isReady(): boolean {
        if (this.gameStarted) return false;
        return this.validatePlayerCount() && this.validateTeamsValid();
    }

    rejectEveryone(): void {
        this.waitingPlayers.forEach((playerId) => {
            this.rejectJoinRequest(playerId);
        });
    }

    onDeletion() {
        if (!this.gameStarted) this.chatService.deleteChat(this.chatId, SERVER_USERNAME);
        this.waitingPlayers.forEach((username) => {
            if (this.gameStarted) this.chatService.removeUserFromChat(this.chatId, username, true);
            this.webSocketServer.to(userRoomPrefix + username).emit(InGameEvent.InstanceDeletion);
        });
        this.webSocketServer.to(this.instanceId).emit(InGameEvent.InstanceDeletion);
        this.webSocketServer.to(this.instanceId).socketsLeave(this.instanceId);
    }

    changeTeam(username: string, newTeam: number) {
        if (!this.approvedPlayers.has(username) || newTeam >= this.teams.length) return;
        this.teams.forEach((team) => team.delete(username));
        this.teams[newTeam].add(username);
        this.updatePlayerList();
    }

    private validatePlayerCount() {
        const teamFormat = this.getTeamFormat();
        return this.approvedPlayers.size >= teamFormat.minTeam * teamFormat.minPlayerPerTeam;
    }

    private validateTeamsValid() {
        const teamFormat = this.getTeamFormat();
        const nNonEmptyTeam = this.teams.reduce((value, team) => (team.size === 0 ? value : value + 1), 0);
        if (!(nNonEmptyTeam >= teamFormat.minTeam && nNonEmptyTeam <= teamFormat.maxTeam)) return false;
        return this.teams.every((team) => team.size === 0 || (team.size >= teamFormat.minPlayerPerTeam && team.size <= teamFormat.maxPlayerPerTeam));
    }

    private getTeamFormat(): TeamFormat {
        switch (this.instantiateGameDto.gameMode) {
            case GameMode.TeamClassic:
                return { maxPlayerPerTeam: 2, minPlayerPerTeam: 2, maxTeam: 3, minTeam: 2 };
            case GameMode.TimeLimitAugmented:
            case GameMode.TimeLimitSingleDiff:
                return { maxPlayerPerTeam: 4, minPlayerPerTeam: 2, maxTeam: 1, minTeam: 1 };
            case GameMode.ClassicMultiplayer:
                return { maxPlayerPerTeam: 1, minPlayerPerTeam: 1, maxTeam: 4, minTeam: 2 };
            case GameMode.TimeLimitTurnByTurn:
                return { maxPlayerPerTeam: 1, minPlayerPerTeam: 1, maxTeam: 2, minTeam: 2 };
        }
    }
}
