import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { GameChooserDialogData } from '@app/interfaces/dialog-data';
import { GameLoaderService } from '@app/services/game-loader.service';
import { SocketIoService } from '@app/services/socket.io.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { GameMode, TIME_LIMIT_PREFIX } from '@common/game-template';
import { DEFAULT_REWARD_TIME, DEFAULT_TOTAL_TIME } from '@common/time-config.constants';
import { ObserverGameDto, TimeConfigDto, WaitingGameDto, WaitingGamesListDto, WaitingRoomEvent } from '@common/websocket/waiting-room.dto';

@Component({
    selector: 'app-modal-game-chooser',
    templateUrl: './modal-game-chooser.component.html',
    styleUrls: ['./modal-game-chooser.component.scss'],
})
export class ModalGameChooserComponent implements OnInit, OnDestroy {
    waitingGames: WaitingGameDto[];
    observerGames: ObserverGameDto[];
    selectedWaitingGame: WaitingGameDto | undefined;
    selectedObserverGame: ObserverGameDto | undefined;
    timeConfig: TimeConfigDto = {
        totalTime: DEFAULT_TOTAL_TIME,
        rewardTime: DEFAULT_REWARD_TIME,
        cheatModeAllowed: false,
    };

    // eslint-disable-next-line max-params
    constructor(
        public dialogRef: MatDialogRef<ModalGameChooserComponent>,
        @Inject(MAT_DIALOG_DATA) public data: GameChooserDialogData,
        private socketIoService: SocketIoService,
        private gameLoaderService: GameLoaderService,
    ) {}

    get isTimeLimit(): boolean {
        return this.data.gameMode.startsWith(TIME_LIMIT_PREFIX);
    }

    get possibleTimeLimitValues(): GameMode[] {
        return Object.values(GameMode).filter((v) => v.startsWith(TIME_LIMIT_PREFIX));
    }

    get possibleClassicValues(): GameMode[] {
        return Object.values(GameMode).filter((v) => !v.startsWith(TIME_LIMIT_PREFIX));
    }

    get possibleGamemodesValues(): GameMode[] {
        return this.isTimeLimit ? this.possibleTimeLimitValues : this.possibleClassicValues;
    }

    get isTimeLimitTurnByTurn(): boolean {
        return this.data.gameMode === GameMode.TimeLimitTurnByTurn;
    }

    ngOnDestroy(): void {
        this.socketIoService.removeListener(WaitingRoomEvent.WaitingGames);
    }

    ngOnInit(): void {
        this.socketIoService.emit(WaitingRoomEvent.GetWaitingGames, undefined);
        this.listenWaitingGames();
    }

    gameModeToString(gameMode: GameMode) {
        return EnumTranslator.toGameModeString(gameMode);
    }

    joinWaitingGame(): void {
        if (!this.selectedWaitingGame) return;
        this.gameLoaderService.joinWaitingGame(this.selectedWaitingGame);
        this.dialogRef.close();
    }

    createGame(): void {
        this.gameLoaderService.createGame({
            gameTemplateId: this.data.gameTemplateId,
            gameMode: this.data.gameMode,
            timeConfig: this.timeConfig,
        });
        this.dialogRef.close();
    }

    joinObserverGame(): void {
        if (!this.selectedObserverGame) return;
        this.gameLoaderService.joinObserverGame(this.selectedObserverGame);
        this.dialogRef.close();
    }

    private listenWaitingGames(): void {
        this.socketIoService.on(WaitingRoomEvent.WaitingGames, (waitingGamesListDto: WaitingGamesListDto) => {
            this.waitingGames = waitingGamesListDto.waitingGames.filter((game) =>
                game.gameMode.startsWith(TIME_LIMIT_PREFIX) ? this.isTimeLimit : game.templateId === this.data.gameTemplateId,
            );
            this.observerGames = waitingGamesListDto.observerGames.filter((game) =>
                game.gameMode.startsWith(TIME_LIMIT_PREFIX) ? this.isTimeLimit : game.templateId === this.data.gameTemplateId,
            );
            if (this.selectedWaitingGame && !this.waitingGames.map((game) => game.instanceId).includes(this.selectedWaitingGame.instanceId))
                this.selectedWaitingGame = undefined;
            if (this.selectedObserverGame && !this.observerGames.map((game) => game.instanceId).includes(this.selectedObserverGame.instanceId))
                this.selectedObserverGame = undefined;
        });
    }
}
