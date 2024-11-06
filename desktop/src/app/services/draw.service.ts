/* eslint-disable max-lines */
import { Injectable } from '@angular/core';
import {
    HEX_COLOR_B_INDEX,
    HEX_COLOR_G_INDEX,
    HEX_COLOR_R_INDEX,
    INITIAL_COLOR,
    INITIAL_LINE_WIDTH,
    INITIAL_SPRAY_PER_SECOND,
    INITIAL_STEP,
} from '@app/constants/game-creation';
import { MouseButton } from '@app/constants/mouse';
import { Corner, DrawingTools, possibleCorners } from '@app/interfaces/drawing-tools';
import { DrawUtils } from '@app/utils/draw.utils';
import { IMAGE_HEIGHT, IMAGE_WIDTH, MS_PER_SECOND } from '@common/constants';
import { Color, ForegroundState, ImageClicked, Vec2 } from '@common/game-template';
import { ImageService } from './image.service';

@Injectable({
    providedIn: 'root',
})
export class DrawService {
    selectedTool = DrawingTools.Pen;
    lineWidth = INITIAL_LINE_WIDTH;
    color = INITIAL_COLOR;
    sprayPerSecond = INITIAL_SPRAY_PER_SECOND;
    isPressed = false;

    private leftCanvas: HTMLCanvasElement;
    private rightCanvas: HTMLCanvasElement;

    private currentCanvas: HTMLCanvasElement | null = null;

    private canvasStates: ForegroundState[];
    private currentStep: number;

    private sprayInterval: NodeJS.Timeout | null = null;

    private previousCoord: Vec2;
    private currentCord: Vec2;

    constructor(private imageService: ImageService) {}

    get canUndo(): boolean {
        return this.currentStep > 0;
    }

    get canRedo(): boolean {
        return !!this.canvasStates && this.currentStep < this.canvasStates.length - 1;
    }

    private get leftContext(): CanvasRenderingContext2D {
        return this.imageService.getContext(this.leftCanvas);
    }

    private get rightContext(): CanvasRenderingContext2D {
        return this.imageService.getContext(this.rightCanvas);
    }

    private get currentContext(): CanvasRenderingContext2D {
        if (!this.currentCanvas) {
            throw new Error('Current canvas is not set');
        }
        return this.imageService.getContext(this.currentCanvas);
    }

    private get currentColorRGBA(): Color {
        const r = parseInt(this.color.slice(HEX_COLOR_R_INDEX, HEX_COLOR_R_INDEX + 2), 16);
        const g = parseInt(this.color.slice(HEX_COLOR_G_INDEX, HEX_COLOR_G_INDEX + 2), 16);
        const b = parseInt(this.color.slice(HEX_COLOR_B_INDEX, HEX_COLOR_B_INDEX + 2), 16);
        return { r, g, b, a: 255 };
    }

    setCanvas(leftCanvas: HTMLCanvasElement, rightCanvas: HTMLCanvasElement): void {
        this.leftCanvas = leftCanvas;
        this.rightCanvas = rightCanvas;

        this.updateLineProperty(this.leftContext);
        this.updateLineProperty(this.rightContext);

        this.canvasStates = [];
        this.currentStep = INITIAL_STEP;
        this.memorizeAction();
    }

    resetCanvas(imageClicked: ImageClicked): void {
        this.getContext(imageClicked).clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        this.memorizeAction();
    }

    duplicateLeftCanvas(): void {
        const leftImageData = this.leftContext.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        this.rightContext.putImageData(leftImageData, 0, 0);
        this.memorizeAction();
    }

    duplicateRightCanvas(): void {
        const rightImageData = this.rightContext.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        this.leftContext.putImageData(rightImageData, 0, 0);
        this.memorizeAction();
    }

    swapCanvas(): void {
        const leftImageData = this.leftContext.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        const rightImageData = this.rightContext.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        this.leftContext.putImageData(rightImageData, 0, 0);
        this.rightContext.putImageData(leftImageData, 0, 0);
        this.memorizeAction();
    }

    undoAction(): void {
        if (this.canUndo) {
            this.currentStep--;
            this.drawState();
        }
    }

    redoAction(): void {
        if (this.canRedo) {
            this.currentStep++;
            this.drawState();
        }
    }

    onMouseDown(event: MouseEvent, imageClicked: ImageClicked) {
        if (event.button !== MouseButton.Left) {
            return;
        }

        this.currentCanvas = this.getCanvas(imageClicked);

        const { x, y } = this.getMousePosition(event);
        this.isPressed = true;
        const context = this.currentContext;

        this.updateLineProperty(this.leftContext);
        this.updateLineProperty(this.rightContext);

        switch (this.selectedTool) {
            case DrawingTools.Pen:
                context.beginPath();
                context.moveTo(x, y);
                context.lineTo(x, y);
                context.stroke();
                break;
            case DrawingTools.Rectangle:
                this.previousCoord = { x, y };
                this.memorizeAction();
                break;
            case DrawingTools.Eraser:
                this.previousCoord = { x, y };
                context.clearRect(x - this.lineWidth / 2, y - this.lineWidth / 2, this.lineWidth, this.lineWidth);
                context.globalCompositeOperation = 'destination-out';
                break;
            case DrawingTools.Ellipse:
                this.previousCoord = { x, y };
                this.memorizeAction();
                break;
            case DrawingTools.Bucket:
                this.fillBucket(context, { x, y });
                this.memorizeAction();
                this.isPressed = false;
                this.currentCanvas = null;
                break;
            case DrawingTools.Spray:
                this.previousCoord = { x, y };
                this.startSprayPaint(context, { x, y });
                break;
        }
    }

    onMouseUp(event: MouseEvent) {
        if (event.button !== MouseButton.Left || !this.isPressed) {
            return;
        }

        const { x, y } = this.getMousePosition(event);
        this.isPressed = false;
        const context = this.currentContext;
        this.currentCanvas = null;

        switch (this.selectedTool) {
            case DrawingTools.Pen:
                this.memorizeAction();
                break;
            case DrawingTools.Rectangle:
                this.currentCord = { x, y };
                this.drawRectangle(context, event.shiftKey);
                break;
            case DrawingTools.Eraser:
                this.memorizeAction();
                break;
            case DrawingTools.Ellipse:
                this.currentCord = { x, y };
                this.drawEllipse(context, event.shiftKey);
                break;
            case DrawingTools.Bucket:
                // Do nothing
                break;
            case DrawingTools.Spray:
                this.stopSprayPaint();
                this.memorizeAction();
                break;
        }
    }

    onMouseMove(event: MouseEvent) {
        if (!this.isPressed) {
            return;
        }

        const { x, y } = this.getMousePosition(event);
        const context = this.currentContext;

        switch (this.selectedTool) {
            case DrawingTools.Pen:
                context.lineTo(x, y);
                context.stroke();
                break;
            case DrawingTools.Rectangle:
                this.currentCord = { x, y };
                this.drawRectangle(context, event.shiftKey);
                break;
            case DrawingTools.Eraser:
                this.interpolateEraser(context, { x, y });
                break;
            case DrawingTools.Ellipse:
                this.currentCord = { x, y };
                this.drawEllipse(context, event.shiftKey);
                break;
            case DrawingTools.Bucket:
                // Do nothing
                break;
            case DrawingTools.Spray:
                this.stopSprayPaint();
                this.interpolateSprayPaint(context, { x, y });
                this.previousCoord = { x, y };
                this.startSprayPaint(context, { x, y });
                break;
        }
    }

    onShiftKeyDown(): void {
        if (!this.isPressed) {
            return;
        }

        const context = this.currentContext;
        this.updateLineProperty(context);

        switch (this.selectedTool) {
            case DrawingTools.Rectangle:
                this.drawRectangle(context, true);
                break;
            case DrawingTools.Ellipse:
                this.drawEllipse(context, true);
                break;
            default:
                break;
        }
    }

    onShiftKeyUp(): void {
        if (!this.isPressed) {
            return;
        }

        const context = this.currentContext;
        this.updateLineProperty(context);

        switch (this.selectedTool) {
            case DrawingTools.Rectangle:
                this.drawRectangle(context, false);
                break;
            case DrawingTools.Ellipse:
                this.drawEllipse(context, false);
                break;
            default:
                break;
        }
    }

    private interpolateEraser(context: CanvasRenderingContext2D, coord: Vec2) {
        const topLeft = this.getRectangleCorner(coord, possibleCorners.topLeft);
        context.clearRect(topLeft.x, topLeft.y, this.lineWidth, this.lineWidth);

        const corners1: Corner[] = [possibleCorners.bottomLeft, possibleCorners.topRight, possibleCorners.topRight, possibleCorners.bottomLeft];
        this.interpolateQuad(context, corners1, coord);

        const corners2 = [possibleCorners.topLeft, possibleCorners.bottomRight, possibleCorners.bottomRight, possibleCorners.topLeft];
        this.interpolateQuad(context, corners2, coord);

        this.previousCoord = coord;
    }

    private interpolateQuad(context: CanvasRenderingContext2D, corners: Corner[], coord: Vec2) {
        context.beginPath();

        const initialPoint = this.getRectangleCorner(this.previousCoord, corners[0]);
        context.moveTo(initialPoint.x, initialPoint.y);
        const coord1 = this.getRectangleCorner(this.previousCoord, corners[1]);
        context.lineTo(coord1.x, coord1.y);
        const coord2 = this.getRectangleCorner(coord, corners[2]);
        context.lineTo(coord2.x, coord2.y);
        const coord3 = this.getRectangleCorner(coord, corners[3]);
        context.lineTo(coord3.x, coord3.y);

        context.fill();
    }

    private getRectangleCorner(center: Vec2, corner: Corner): Vec2 {
        const { x, y } = center;
        const [top, left] = corner;

        const dx = this.lineWidth / 2;
        const dy = this.lineWidth / 2;
        return { x: x - (left ? dx : -dx), y: y - (top ? dy : -dy) };
    }

    private memorizeAction(): void {
        this.currentStep++;
        if (this.currentStep < this.canvasStates.length) {
            this.canvasStates.length = this.currentStep;
        }
        this.canvasStates.push({
            leftImage: this.leftContext.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT),
            rightImage: this.rightContext.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT),
        });
    }

    private drawState(): void {
        this.leftContext.clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        this.rightContext.clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);

        const { leftImage, rightImage } = this.canvasStates[this.currentStep];
        this.leftContext.putImageData(leftImage, 0, 0);
        this.rightContext.putImageData(rightImage, 0, 0);
    }

    private updateLineProperty(context: CanvasRenderingContext2D): void {
        context.globalCompositeOperation = 'source-over';
        context.lineCap = 'round';
        context.lineJoin = 'round';
        context.lineWidth = this.lineWidth;
        context.fillStyle = this.color;
        context.strokeStyle = this.color;
    }

    private getMousePosition(event: MouseEvent): Vec2 {
        if (!this.currentCanvas) {
            throw new Error('Current canvas is not set');
        }
        const x = event.clientX - this.currentCanvas.getBoundingClientRect().x;
        const y = event.clientY - this.currentCanvas.getBoundingClientRect().y;
        return { x, y };
    }

    private drawRectangle(context: CanvasRenderingContext2D, squareMode: boolean): void {
        this.undoAction();

        const dx = this.currentCord.x - this.previousCoord.x;
        const dy = this.currentCord.y - this.previousCoord.y;

        if (squareMode) {
            const sideLength = Math.min(Math.abs(dx), Math.abs(dy));
            const width = dx > 0 ? sideLength : -sideLength;
            const height = dy > 0 ? sideLength : -sideLength;
            context.fillRect(this.previousCoord.x, this.previousCoord.y, width, height);
        } else {
            context.fillRect(this.previousCoord.x, this.previousCoord.y, dx, dy);
        }
        this.memorizeAction();
    }

    private drawEllipse(context: CanvasRenderingContext2D, circleMode: boolean): void {
        this.undoAction();

        const widthX = Math.abs(this.currentCord.x - this.previousCoord.x);
        const widthY = Math.abs(this.currentCord.y - this.previousCoord.y);

        const radiusX = circleMode ? Math.min(widthX, widthY) / 2 : widthX / 2;
        const radiusY = circleMode ? Math.min(widthX, widthY) / 2 : widthY / 2;
        const centerX = this.previousCoord.x + radiusX * Math.sign(this.currentCord.x - this.previousCoord.x);
        const centerY = this.previousCoord.y + radiusY * Math.sign(this.currentCord.y - this.previousCoord.y);

        context.beginPath();
        context.ellipse(centerX, centerY, radiusX, radiusY, 0, 0, 2 * Math.PI);
        context.fill();

        this.memorizeAction();
    }

    private fillBucket(context: CanvasRenderingContext2D, { x, y }: Vec2): void {
        x = Math.floor(x);
        y = Math.floor(y);
        if (x < 0 || x >= IMAGE_WIDTH || y < 0 || y >= IMAGE_HEIGHT) {
            return;
        }

        const imageData = context.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        const { data } = imageData;

        const areaToFill = DrawUtils.getAreaToFill(data, { x, y });
        for (const index of areaToFill) {
            data[index] = this.currentColorRGBA.r;
            data[index + 1] = this.currentColorRGBA.g;
            data[index + 2] = this.currentColorRGBA.b;
            data[index + 3] = this.currentColorRGBA.a;
        }

        context.putImageData(imageData, 0, 0);
    }

    private sprayPaint(context: CanvasRenderingContext2D, { x, y }: Vec2): void {
        const radius = this.lineWidth / 2;
        const density = 0.05;
        const area = Math.PI * radius ** 2;
        const numberOfDots = density * area;

        for (let i = 0; i < numberOfDots; i++) {
            const angle = Math.random() * 2 * Math.PI;
            const distance = Math.sqrt(Math.random()) * radius;
            const dotX = x + distance * Math.cos(angle);
            const dotY = y + distance * Math.sin(angle);

            context.fillRect(dotX, dotY, 1, 1);
        }
    }

    private interpolateSprayPaint(context: CanvasRenderingContext2D, { x, y }: Vec2): void {
        const dotsToDraw = DrawUtils.getRandomPointsInLine(this.previousCoord, { x, y }, this.lineWidth);
        for (const { x: dotX, y: dotY } of dotsToDraw) {
            context.fillRect(dotX, dotY, 1, 1);
        }
    }

    private startSprayPaint(context: CanvasRenderingContext2D, { x, y }: Vec2): void {
        this.stopSprayPaint();
        this.sprayPaint(context, { x, y });
        this.sprayInterval = setInterval(() => {
            this.sprayPaint(context, { x, y });
        }, MS_PER_SECOND / this.sprayPerSecond);
    }

    private stopSprayPaint(): void {
        if (this.sprayInterval) {
            clearInterval(this.sprayInterval);
        }
    }

    private getContext(imageClicked: ImageClicked): CanvasRenderingContext2D {
        return imageClicked === ImageClicked.Left ? this.leftContext : this.rightContext;
    }

    private getCanvas(imageClicked: ImageClicked): HTMLCanvasElement {
        return imageClicked === ImageClicked.Left ? this.leftCanvas : this.rightCanvas;
    }
}
