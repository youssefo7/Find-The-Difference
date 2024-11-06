import { Component, ElementRef, EventEmitter, OnDestroy, OnInit, Output, ViewChild } from '@angular/core';
import { MouseButton } from '@app/constants/mouse';
import { ImageService } from '@app/services/image.service';
import { IMAGE_HEIGHT, IMAGE_WIDTH } from '@common/constants';
import { Vec2 } from '@common/game-template';

@Component({
    selector: 'app-observer-draw-hint',
    templateUrl: './observer-draw-hint.component.html',
    styleUrl: './observer-draw-hint.component.scss',
})
export class ObserverDrawHintComponent implements OnInit, OnDestroy {
    private static allObserverDrawHintComponent: ObserverDrawHintComponent[] = [];

    @ViewChild('drawCanvas', { static: true }) drawCanvas: ElementRef<HTMLCanvasElement>;
    @Output() coordEvent = new EventEmitter<[Vec2, Vec2]>();

    previousCoord: Vec2;
    isPressed = false;
    protected imageWidth = IMAGE_WIDTH;
    protected imageHeight = IMAGE_HEIGHT;

    constructor(private imageService: ImageService) {}

    static resetCanvas(): void {
        ObserverDrawHintComponent.allObserverDrawHintComponent.forEach((component) =>
            component.getContext().clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT),
        );
    }

    ngOnInit(): void {
        ObserverDrawHintComponent.allObserverDrawHintComponent.push(this);
    }
    ngOnDestroy(): void {
        ObserverDrawHintComponent.allObserverDrawHintComponent.filter((component) => component !== this);
    }

    onMouseDown(event: MouseEvent) {
        if (event.button !== MouseButton.Left) return;

        this.coordEvent.emit(undefined);
        ObserverDrawHintComponent.resetCanvas();
        const { x, y } = this.getMousePosition(event);
        this.isPressed = true;
        this.previousCoord = { x, y };
    }

    onMouseUp(event: MouseEvent) {
        if (event.button !== MouseButton.Left || !this.isPressed) return;
        this.onMouseMove(event);
        this.isPressed = false;
        const { x, y } = this.getMousePosition(event);
        const start: Vec2 = { x: Math.min(x, this.previousCoord.x), y: Math.min(y, this.previousCoord.y) };
        const dxy: Vec2 = { x: Math.abs(x - this.previousCoord.x), y: Math.abs(y - this.previousCoord.y) };

        if (dxy.x === 0 || dxy.y === 0) {
            this.coordEvent.emit(undefined);
            return;
        }
        this.coordEvent.emit([start, dxy]);
    }

    onMouseMove(event: MouseEvent) {
        if (!this.isPressed) {
            return;
        }

        const { x, y } = this.getMousePosition(event);

        this.drawRectangle({ x, y });
    }

    private getMousePosition(event: MouseEvent): Vec2 {
        return { x: Math.max(Math.min(event.offsetX, IMAGE_WIDTH), 0), y: Math.max(Math.min(event.offsetY, IMAGE_HEIGHT), 0) };
    }
    private async drawRectangle({ x, y }: Vec2): Promise<void> {
        ObserverDrawHintComponent.resetCanvas();
        const dx = x - this.previousCoord.x;
        const dy = y - this.previousCoord.y;
        ObserverDrawHintComponent.allObserverDrawHintComponent.forEach((component) =>
            component.getContext().strokeRect(this.previousCoord.x, this.previousCoord.y, dx, dy),
        );
    }

    private getContext(): CanvasRenderingContext2D {
        return this.imageService.getContext(this.drawCanvas.nativeElement);
    }
}
