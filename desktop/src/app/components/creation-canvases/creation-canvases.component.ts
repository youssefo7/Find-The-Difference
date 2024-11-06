import { AfterViewInit, Component, ElementRef, HostListener, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { ModalDifferenceComponent } from '@app/components/modal-difference/modal-difference.component';
import { BMP_BIT_DEPTH } from '@app/constants/game-creation';
import { DrawingTools } from '@app/interfaces/drawing-tools';
import { ImageService } from '@app/services/image.service';
import { IMAGE_HEIGHT, IMAGE_WIDTH } from '@common/constants';
import { ImageClicked } from '@common/game-template';
import { DrawService } from '@services/draw.service';

@Component({
    selector: 'app-creation-canvases',
    templateUrl: './creation-canvases.component.html',
    styleUrls: ['./creation-canvases.component.scss'],
})
export class CreationCanvasesComponent implements AfterViewInit {
    @ViewChild('leftBackgroundCanvas', { static: true })
    leftBackgroundCanvas: ElementRef<HTMLCanvasElement>;
    @ViewChild('rightBackgroundCanvas', { static: true })
    rightBackgroundCanvas: ElementRef<HTMLCanvasElement>;

    @ViewChild('leftForegroundCanvas', { static: true })
    leftForegroundCanvas: ElementRef<HTMLCanvasElement>;
    @ViewChild('rightForegroundCanvas', { static: true })
    rightForegroundCanvas: ElementRef<HTMLCanvasElement>;

    protected imageWidth = IMAGE_WIDTH;
    protected imageHeight = IMAGE_HEIGHT;
    protected bmpBitDepth = BMP_BIT_DEPTH;

    protected drawingTools = DrawingTools;
    protected imageClicked = ImageClicked;

    protected firstImage: File | null;
    protected secondImage: File | null;

    protected modalOpen: boolean = false;

    // eslint-disable-next-line max-params -- https://discord.com/channels/1054141487656472616/1054141488042356874/1074065304059117730
    constructor(
        private imageService: ImageService,
        public drawService: DrawService,
        public dialog: MatDialog,
        private snackBar: MatSnackBar,
    ) {}

    @HostListener('document:keydown', ['$event'])
    onKeyDown(event: KeyboardEvent): void {
        if (event.ctrlKey && event.shiftKey && event.key === 'Z') {
            this.drawService.redoAction();
        } else if (event.ctrlKey && event.key === 'z') {
            this.drawService.undoAction();
        }

        if (event.key === 'Shift') {
            this.drawService.onShiftKeyDown();
        }
    }

    @HostListener('document:keyup', ['$event'])
    onKeyUp(event: KeyboardEvent): void {
        if (event.key === 'Shift') {
            this.drawService.onShiftKeyUp();
        }
    }

    ngAfterViewInit(): void {
        this.drawService.setCanvas(this.leftForegroundCanvas.nativeElement, this.rightForegroundCanvas.nativeElement);
    }

    async onFileSelected(event: Event, index: number): Promise<void> {
        const fileItem = (event.target as HTMLInputElement).files?.item(0);
        if (!fileItem) throw new Error('No file selected');

        if (!(await this.imageService.validateImage(fileItem))) {
            this.snackBar.open(`L'image doit être un bmp ${BMP_BIT_DEPTH} bits de ${IMAGE_WIDTH}px par ${IMAGE_HEIGHT}px`, 'Ok');
            return;
        }

        this.drawFileOnCanvas(index, fileItem);
    }

    async refreshDiff(): Promise<void> {
        if (this.modalOpen) return;
        this.modalOpen = true;
        const leftCanvas = this.imageService.mergeCanvas(this.leftBackgroundCanvas.nativeElement, this.leftForegroundCanvas.nativeElement);
        const rightCanvas = this.imageService.mergeCanvas(this.rightBackgroundCanvas.nativeElement, this.rightForegroundCanvas.nativeElement);

        const data = await this.imageService.getDifferenceDialogData(leftCanvas, rightCanvas);
        this.dialog
            .open(ModalDifferenceComponent, { data, disableClose: true })
            .afterClosed()
            .subscribe(() => {
                this.modalOpen = false;
            });
    }

    resetBackgroundImage(index: number): void {
        switch (index) {
            case 0:
                this.firstImage = null;
                this.imageService.getContext(this.leftBackgroundCanvas.nativeElement).clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
                break;
            case 1:
                this.secondImage = null;
                this.imageService.getContext(this.rightBackgroundCanvas.nativeElement).clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
                break;
        }
    }

    private async drawImage(canvas: HTMLCanvasElement, file: File): Promise<void> {
        const context = this.imageService.getContext(canvas);
        const img = await this.imageService.fileToImage(file);
        context.drawImage(img, 0, 0, canvas.width, canvas.height);
    }

    private drawFileOnCanvas(index: number, fileItem: File) {
        switch (index) {
            case 0:
                this.drawImage(this.leftBackgroundCanvas.nativeElement, fileItem);
                this.firstImage = fileItem;
                break;
            case 1:
                this.drawImage(this.rightBackgroundCanvas.nativeElement, fileItem);
                this.secondImage = fileItem;
                break;
            case 2:
                this.drawFileOnCanvas(0, fileItem);
                this.drawFileOnCanvas(1, fileItem);
                break;
        }
    }
}
