import { Component } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { GameTypeSelectionDialogComponent } from '@app/components/game-type-selection-dialog/game-type-selection-dialog.component';

@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent {
    constructor(
        public dialog: MatDialog,
        public router: Router,
    ) {}

    openCreateGameModal() {
        this.dialog.open(GameTypeSelectionDialogComponent);
    }

    joinGamePage() {
        this.router.navigate(['join-game']);
    }

    watchGamePage() {
        this.router.navigate(['watch-game']);
    }
}
