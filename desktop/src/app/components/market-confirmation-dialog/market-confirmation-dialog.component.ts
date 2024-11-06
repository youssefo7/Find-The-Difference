import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MarketConfirmationDialogData } from '@app/interfaces/dialog-data';

@Component({
    selector: 'app-market-confirmation-dialog.component',
    templateUrl: './market-confirmation-dialog.component.html',
    styleUrls: ['./market-confirmation-dialog.component.scss'],
})
export class MarketConfirmationDialogComponent {
    constructor(@Inject(MAT_DIALOG_DATA) public data: MarketConfirmationDialogData) {}
}
