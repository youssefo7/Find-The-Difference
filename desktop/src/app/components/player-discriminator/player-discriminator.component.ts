import { Component, Input, OnDestroy, OnInit } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { AuthService } from '@app/services/auth.service';
import { SocketIoService } from '@app/services/socket.io.service';
import { UserService } from '@app/services/user.service';
import { GameMode } from '@common/game-template';
import { Username } from '@common/ingame-ids.types';
import { InGameEvent } from '@common/websocket/in-game.dto';
import { JoinRequestsDto, WaitingRoomEvent } from '@common/websocket/waiting-room.dto';

interface TeamFormat {
    minPlayerPerTeam: number;
    maxPlayerPerTeam: number;
    maxTeam: number;
    minTeam: number;
}

@Component({
    selector: 'app-player-discriminator',
    templateUrl: './player-discriminator.component.html',
    styleUrls: ['./player-discriminator.component.scss'],
})
export class PlayerDiscriminatorComponent implements OnInit, OnDestroy {
    @Input() gameMode: GameMode;
    currentTeam: number = 0;
    players: Username[] = [];
    requests: Username[] = [];
    teams: Username[][] = [];
    isGameMaster = false;
    isSelected = false;
    isWaitingForAcceptance = false;
    showError = false;
    startDisabled = false;

    // eslint-disable-next-line max-params
    constructor(
        private socketIoService: SocketIoService,
        private router: Router,
        private snackBar: MatSnackBar,
        private authService: AuthService,
        private userService: UserService,
    ) {}

    ngOnDestroy(): void {
        this.socketIoService.emit(InGameEvent.LeaveGame, undefined);
        this.socketIoService.removeListener(WaitingRoomEvent.JoinRequests);
        this.socketIoService.removeListener(WaitingRoomEvent.WaitingRefusal);
        this.socketIoService.removeListener(WaitingRoomEvent.AssignGameMaster);
        this.socketIoService.removeListener(WaitingRoomEvent.InvalidStartingState);
    }

    ngOnInit(): void {
        this.listenJoinRequest();
        this.listenAssignGameMaster();
        this.listenWaitingRefusal();
        this.listenInvalidStartingState();
        this.userService.fetchAllUsers();
        this.isWaitingForAcceptance = true;
        this.isGameMaster = false;
        this.isSelected = false;
        this.currentTeam = 0;
        this.players = [];
        this.requests = [];
        this.teams = [];
    }

    listenJoinRequest(): void {
        this.socketIoService.on(WaitingRoomEvent.JoinRequests, (joinRequestDto: JoinRequestsDto) => {
            this.isWaitingForAcceptance = false;
            this.players = joinRequestDto.players;
            this.requests = joinRequestDto.requests;
            this.teams = joinRequestDto.teams;
            this.isSelected = this.players.includes(this.authService.getUsername());
            this.currentTeam = this.teams.findIndex((team) => team.includes(this.authService.getUsername()));
        });
    }

    listenWaitingRefusal(): void {
        this.socketIoService.on(WaitingRoomEvent.WaitingRefusal, () => {
            this.isWaitingForAcceptance = false;
            this.snackBar.open($localize`The game master didn't choose you :(`, 'Ok');
            this.router.navigate(['/']);
        });
    }

    listenAssignGameMaster(): void {
        this.socketIoService.on(WaitingRoomEvent.AssignGameMaster, () => {
            this.isGameMaster = true;
            this.isSelected = true;
        });
    }

    listenInvalidStartingState(): void {
        this.socketIoService.on(WaitingRoomEvent.InvalidStartingState, () => {
            this.startDisabled = false;
            this.showError = true;
        });
    }

    removePlayer(username: Username): void {
        this.socketIoService.emit(WaitingRoomEvent.RejectPlayer, { username });
    }

    approvePlayer(username: Username): void {
        this.socketIoService.emit(WaitingRoomEvent.ApprovePlayer, { username });
    }

    startGame() {
        if (this.startDisabled) return;
        this.showError = false;
        this.startDisabled = true;
        this.socketIoService.emit(WaitingRoomEvent.EndSelection, undefined);
    }

    onTeamChange(newTeam: number) {
        this.socketIoService.emit(WaitingRoomEvent.ChangeTeam, { newTeam });
    }

    getTeamLabel(idx: number) {
        const teamText = $localize`Team`;
        return `${teamText} ${idx + 1}: ${this.teams[idx].join(', ')}`;
    }
    getTeamPlayers(idx: number) {
        return this.teams[idx];
    }

    isTeamClassic() {
        return this.gameMode === GameMode.TeamClassic;
    }

    getNumberOfPlayersLabel() {
        const teamFormat = this.getTeamFormat();
        const min = teamFormat.minPlayerPerTeam * teamFormat.minTeam;
        const max = teamFormat.maxPlayerPerTeam * teamFormat.maxTeam;
        return $localize`Number of players: ${min}~${max}`;
    }

    isReady(): boolean {
        if (this.startDisabled) return false;
        return this.validatePlayerCount() && this.validateTeamsValid();
    }

    private validatePlayerCount() {
        const teamFormat = this.getTeamFormat();
        return this.players.length >= teamFormat.minTeam * teamFormat.minPlayerPerTeam;
    }

    private validateTeamsValid() {
        const teamFormat = this.getTeamFormat();
        const nNonEmptyTeam = this.teams.reduce((value, team) => (team.length === 0 ? value : value + 1), 0);
        if (!(nNonEmptyTeam >= teamFormat.minTeam && nNonEmptyTeam <= teamFormat.maxTeam)) return false;
        return this.teams.every(
            (team) => team.length === 0 || (team.length >= teamFormat.minPlayerPerTeam && team.length <= teamFormat.maxPlayerPerTeam),
        );
    }

    private getTeamFormat(): TeamFormat {
        switch (this.gameMode) {
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
