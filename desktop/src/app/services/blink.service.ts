import { Injectable } from '@angular/core';
import { BLINK_FREQUENCY_HZ, BLINK_TIMEOUT, CHEAT_MODE_BLINK_FREQUENCY_HZ } from '@app/constants/game-running';
import { CANVAS_IMAGE_CHANNELS, IMAGE_HEIGHT, IMAGE_WIDTH, MS_PER_SECOND } from '@common/constants';
import { Vec2 } from '@common/game-template';
import { ReplayService } from './replay.service';

@Injectable({
    providedIn: 'root',
})
export class BlinkService {
    leftEndFrame: ImageData;
    rightEndFrame: ImageData;
    isCheatModeBlinking: boolean = false;
    cheatPixels: Vec2[] = [];

    constructor(private replayService: ReplayService) {}

    enableCheatModeBlink(leftContext: CanvasRenderingContext2D, rightContext: CanvasRenderingContext2D, pixelsToBlink: Vec2[]) {
        this.isCheatModeBlinking = true;
        this.cheatPixels = pixelsToBlink;
        this.blinkPixels(leftContext, rightContext, this.cheatPixels);
        // Disable removal of pixels
        this.leftEndFrame = leftContext.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        this.rightEndFrame = rightContext.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
    }

    disableCheatModeBlink() {
        this.isCheatModeBlinking = false;
        this.blinkEndCallback();
    }

    blinkPixelsAndRemove(leftContext: CanvasRenderingContext2D, rightContext: CanvasRenderingContext2D, pixelsToRemove: Vec2[]): void {
        this.blinkPixels(leftContext, rightContext, pixelsToRemove);
        if (!this.isCheatModeBlinking) {
            this.replayService.setTimeout(this.blinkEndCallback, BLINK_TIMEOUT);
            return;
        }

        this.blinkEndCallback();
        const jsonToRemove: Set<string> = new Set<string>();
        pixelsToRemove.forEach((value) => {
            jsonToRemove.add(JSON.stringify(value));
        });
        this.cheatPixels = this.cheatPixels.filter((value) => {
            return !jsonToRemove.has(JSON.stringify(value));
        });
        this.enableCheatModeBlink(leftContext, rightContext, this.cheatPixels);
    }

    blinkEndCallback = (): void => {
        return;
    };

    removePixels(leftContext: CanvasRenderingContext2D, rightContext: CanvasRenderingContext2D, pixelsToRemove: Vec2[]): void {
        this.blinkPixels(leftContext, rightContext, pixelsToRemove);
        this.blinkEndCallback();
    }

    private blinkPixels(leftContext: CanvasRenderingContext2D, rightContext: CanvasRenderingContext2D, pixelsToBlink: Vec2[]) {
        this.blinkEndCallback();
        let [leftImageFrame1, leftImageFrame2] = this.computeBlinkFrames(leftContext, rightContext, pixelsToBlink);
        let [rightImageFrame1, rightImageFrame2] = this.computeBlinkFrames(rightContext, leftContext, pixelsToBlink);

        this.leftEndFrame = leftImageFrame1;
        this.rightEndFrame = rightImageFrame2;

        const blinkFrequencyHz = this.isCheatModeBlinking ? CHEAT_MODE_BLINK_FREQUENCY_HZ : BLINK_FREQUENCY_HZ;
        const intervalId = this.replayService.setInterval(() => {
            leftContext.putImageData(leftImageFrame1, 0, 0);
            rightContext.putImageData(rightImageFrame1, 0, 0);
            [leftImageFrame1, leftImageFrame2] = [leftImageFrame2, leftImageFrame1];
            [rightImageFrame1, rightImageFrame2] = [rightImageFrame2, rightImageFrame1];
        }, MS_PER_SECOND / blinkFrequencyHz);

        let blinkEnded = false;
        this.blinkEndCallback = () => {
            if (blinkEnded) return;
            blinkEnded = true;
            clearInterval(intervalId);
            leftContext.putImageData(this.leftEndFrame, 0, 0);
            rightContext.putImageData(this.rightEndFrame, 0, 0);
        };
    }

    private computeBlinkFrames(
        contextToBlink: CanvasRenderingContext2D,
        contextToCopyFrom: CanvasRenderingContext2D,
        position: Vec2[],
    ): [ImageData, ImageData] {
        const frame1 = contextToBlink.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        const frame2 = contextToBlink.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        const frameToCopyFrom = contextToCopyFrom.getImageData(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);

        position.forEach((pos) => {
            const index = (pos.y * IMAGE_WIDTH + pos.x) * CANVAS_IMAGE_CHANNELS;
            frame2.data[index] = frameToCopyFrom.data[index];
            frame2.data[index + 1] = frameToCopyFrom.data[index + 1];
            frame2.data[index + 2] = frameToCopyFrom.data[index + 2];
            frame2.data[index + 3] = frameToCopyFrom.data[index + 3];
        });
        return [frame1, frame2];
    }
}
