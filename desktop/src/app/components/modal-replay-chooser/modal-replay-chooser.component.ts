import { Component, OnInit } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { GameLoaderService } from '@app/services/game-loader.service';
import { ReplayService } from '@app/services/replay.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { GameMode } from '@common/game-template';
import { ReceiveReplayDto } from '@common/replay.dto';

@Component({
    selector: 'app-modal-replay-chooser',
    templateUrl: './modal-replay-chooser.component.html',
    styleUrl: './modal-replay-chooser.component.scss',
})
export class ModalReplayChooserComponent implements OnInit {
    replays: ReceiveReplayDto[] = [];
    selected: ReceiveReplayDto | undefined;

    constructor(
        public dialogRef: MatDialogRef<ModalReplayChooserComponent>,
        private replayService: ReplayService,
        private gameLoaderService: GameLoaderService,
    ) {}

    gameModeToString(gameMode: GameMode) {
        return EnumTranslator.toGameModeString(gameMode);
    }

    async ngOnInit(): Promise<void> {
        this.replays = (await this.replayService.getReplays()).reverse();
    }

    startReplay() {
        if (!this.selected) return;
        this.gameLoaderService.replayGame(this.selected);
        this.dialogRef.close();
    }
}
