import { AfterViewInit, Component, ElementRef, Inject, ViewChild } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { DifferenceDialogData } from '@app/interfaces/dialog-data';
import { GameTemplateService } from '@app/services/game-template.service';
import { IMAGE_HEIGHT, IMAGE_WIDTH, MAX_GAME_TEMPLATE_NAME_LENGTH, MINIMUM_GAME_PRICE } from '@common/constants';
import { Difficulty } from '@common/game-template';
import { MAX_DIFFERENCES, MIN_DIFFERENCES } from '@common/game-template.constants';

@Component({
    selector: 'app-modal-difference',
    templateUrl: './modal-difference.component.html',
    styleUrls: ['./modal-difference.component.scss'],
})
export class ModalDifferenceComponent implements AfterViewInit {
    @ViewChild('differenceCanvas', { static: true }) differenceCanvas: ElementRef<HTMLCanvasElement>;

    gameName: string = '';
    gamePrice: number | null = null;
    isSubmitted: boolean = false;

    protected imageWidth = IMAGE_WIDTH;
    protected imageHeight = IMAGE_HEIGHT;
    protected minimumGamePrice = MINIMUM_GAME_PRICE;

    constructor(
        private gameTemplateService: GameTemplateService,
        public dialogRef: MatDialogRef<ModalDifferenceComponent, boolean>,
        @Inject(MAT_DIALOG_DATA) public differenceDialogData: DifferenceDialogData,
    ) {}

    get difficultyString() {
        return this.differenceDialogData.difficulty === Difficulty.Hard ? $localize`Hard` : $localize`Easy`;
    }

    get canSaveGame() {
        return this.isValidDifferenceNumber && this.gameName.trim().length > 0 && !this.isSubmitted && !this.priceFormFieldHasError;
    }

    get priceFormFieldHasError() {
        return this.gamePrice === null || this.gamePrice < this.minimumGamePrice;
    }

    get isValidDifferenceNumber(): boolean {
        const nGroups = this.differenceDialogData.nGroups;
        return MIN_DIFFERENCES <= nGroups && nGroups <= MAX_DIFFERENCES;
    }

    get maxGameTemplateNameLength() {
        return MAX_GAME_TEMPLATE_NAME_LENGTH;
    }

    ngAfterViewInit() {
        this.drawImage();
    }

    drawImage() {
        const context = this.differenceCanvas.nativeElement.getContext('2d');
        if (context === null) throw new Error('Failed to get 2d context');
        context.drawImage(this.differenceDialogData.diffImage, 0, 0);
    }

    saveGame() {
        this.isSubmitted = true;
        this.gameTemplateService
            .createGameTemplate({
                name: this.gameName.trim(),
                firstImage: this.differenceDialogData.firstImage,
                secondImage: this.differenceDialogData.secondImage,
                radius: this.differenceDialogData.radius,
                price: this.gamePrice ?? this.minimumGamePrice,
            })
            .add(() => this.dialogRef.close(true));
    }
}
