import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { POSSIBLE_REPLAY_SPEEDS } from '@app/constants/game-running';
import { ReplayDialogData } from '@app/interfaces/dialog-data';
import { ReplayService } from '@app/services/replay.service';
import { REPLAY_BAR_STEP as REPLAY_BAR_STEP_COUNT } from '@common/constants';

@Component({
    selector: 'app-modal-replay',
    templateUrl: './modal-replay.component.html',
    styleUrls: ['./modal-replay.component.scss'],
})
export class ModalReplayComponent implements OnInit, OnDestroy {
    private replaySpeedIndex = 0;
    constructor(
        private replayService: ReplayService,
        private dialogRef: MatDialogRef<ModalReplayComponent>,
        @Inject(MAT_DIALOG_DATA) public data: ReplayDialogData,
    ) {}

    get isLoaded(): boolean {
        return this.replayService.isLoaded;
    }

    get isReplaying(): boolean {
        return this.replayService.isReplaying;
    }

    get speedButtonText(): string {
        return this.replayService.currentReplaySpeed + 'x';
    }

    get stepCount() {
        return REPLAY_BAR_STEP_COUNT;
    }

    get fraction() {
        return Math.round(this.replayService.currentFraction * this.stepCount);
    }

    set fraction(fraction: number) {
        this.replayService.stopPlayback();
        this.data.drawOriginalImages();
        this.replayService.isInReplayMode = true;
        this.replayService.currentFraction = fraction / this.stepCount;
    }

    ngOnInit(): void {
        this.restartReplay();
    }

    ngOnDestroy(): void {
        this.replayService.isInReplayMode = false;
    }

    restartReplay(): void {
        this.fraction = 0;
    }

    onPausePlayClick(): void {
        if (this.replayService.isAtEndOfReplay()) {
            this.restartReplay();
        }
        this.replayService.togglePlayback();
    }

    changeReplaySpeed(): void {
        this.replaySpeedIndex = (this.replaySpeedIndex + 1) % POSSIBLE_REPLAY_SPEEDS.length;
        this.replayService.currentReplaySpeed = POSSIBLE_REPLAY_SPEEDS[this.replaySpeedIndex];
    }

    closeReplay(): void {
        this.dialogRef.close();
    }

    saveAndQuit(): void {
        this.closeReplay();
        this.replayService.uploadReplay();
    }
}
