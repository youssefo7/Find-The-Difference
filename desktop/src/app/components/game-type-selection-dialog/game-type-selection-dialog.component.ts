import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { InfoCardComponent } from '@app/components/info-card/info-card.component';
import { ModalGameChooserComponent } from '@app/components/modal-game-chooser/modal-game-chooser.component';
import { GameChooserDialogData } from '@app/interfaces/dialog-data';
import { EnumTranslator } from '@app/utils/enum-translator';
import { GameMode, TIME_LIMIT_PREFIX } from '@common/game-template';

@Component({
    selector: 'app-game-type-selection-dialog',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './game-type-selection-dialog.component.html',
    styleUrls: ['./game-type-selection-dialog.component.scss'],
})
export class GameTypeSelectionDialogComponent {
    selectedMode: GameMode;

    constructor(
        private dialogRef: MatDialogRef<GameTypeSelectionDialogComponent>,
        private dialog: MatDialog,
        private router: Router,
    ) {}

    get gameModes() {
        return GameMode;
    }

    gameModeToString(gameMode: GameMode): string {
        return EnumTranslator.toGameModeString(gameMode);
    }
    selectMode(mode: GameMode) {
        this.dialogRef.close(mode);
        this.selectedMode = mode;

        if (mode.startsWith(TIME_LIMIT_PREFIX)) this.openLimitedTimeModeDialog(mode);
        else {
            InfoCardComponent.classicGameMode = mode;
            this.router.navigate(['/classic-game-selection']);
        }
    }

    private openLimitedTimeModeDialog(gameMode: GameMode) {
        this.dialogRef.close();

        const gameName = $localize`Limited Time Mode`;
        const data: GameChooserDialogData = { gameName, gameTemplateId: '', gameMode };
        this.dialog.open(ModalGameChooserComponent, {
            data,
        });
    }
}
