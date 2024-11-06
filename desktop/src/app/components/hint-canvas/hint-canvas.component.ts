import { AfterViewInit, Component, ElementRef, Input, OnDestroy, ViewChild } from '@angular/core';
import { HintService } from '@app/services/hint.service';
import { ImageService } from '@app/services/image.service';
import { IMAGE_HEIGHT, IMAGE_WIDTH } from '@common/constants';
import { Username } from '@common/ingame-ids.types';

@Component({
    selector: 'app-hint-canvas',
    templateUrl: './hint-canvas.component.html',
    styleUrl: './hint-canvas.component.scss',
})
export class HintCanvasComponent implements AfterViewInit, OnDestroy {
    @ViewChild('HintCanvas', { static: true }) hintCanvas: ElementRef<HTMLCanvasElement>;
    @Input({ required: true }) observer: Username;

    protected imageWidth = IMAGE_WIDTH;
    protected imageHeight = IMAGE_HEIGHT;

    constructor(
        private hintService: HintService,
        private readonly imageService: ImageService,
    ) {}
    ngAfterViewInit(): void {
        this.hintService.addContext({
            observer: this.observer,
            canvas: this,
        });
    }

    ngOnDestroy(): void {
        this.hintService.removeContext(this.observer);
    }

    getContext(): CanvasRenderingContext2D {
        return this.imageService.getContext(this.hintCanvas.nativeElement);
    }
}
