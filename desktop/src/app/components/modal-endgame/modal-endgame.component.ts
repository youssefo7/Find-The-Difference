import { Component, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { EndgameDialogData } from '@app/interfaces/dialog-data';

@Component({
    selector: 'app-modal-endgame',
    templateUrl: './modal-endgame.component.html',
    styleUrls: ['./modal-endgame.component.scss'],
})
export class ModalEndgameComponent {
    constructor(
        private router: Router,
        private dialogRef: MatDialogRef<ModalEndgameComponent>,
        @Inject(MAT_DIALOG_DATA) public data: EndgameDialogData,
    ) {}

    onGameReplay(): void {
        this.dialogRef.close();
        if (!this.data.openReplayDialog) throw new Error('Cannot open replay dialog');
        this.data.openReplayDialog();
    }

    onClose(): void {
        this.dialogRef.close();
        this.router.navigate(['/']);
    }
}
