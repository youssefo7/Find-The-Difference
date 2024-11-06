import { Injectable } from '@angular/core';
import { BMP_BIT_DEPTH, BMP_BIT_DEPTH_INDEX } from '@app/constants/game-creation';
import { DifferenceDialogData } from '@app/interfaces/dialog-data';
import { IMAGE_HEIGHT, IMAGE_WIDTH } from '@common/constants';
import { DEFAULT_RADIUS } from '@common/images-differences.constants';
import { ImagesDifferencesService } from './images-differences.service';

@Injectable({
    providedIn: 'root',
})
export class ImageService {
    radius = DEFAULT_RADIUS;

    constructor(private imagesDifferenceService: ImagesDifferencesService) {}

    getContext(canvas: HTMLCanvasElement): CanvasRenderingContext2D {
        const context = canvas.getContext('2d', { willReadFrequently: true });
        if (!context) {
            throw new Error("Can't get canvas context");
        }

        return context;
    }

    mergeCanvas(background: HTMLCanvasElement, foreground: HTMLCanvasElement): HTMLCanvasElement {
        const canvas = document.createElement('canvas');
        const context = this.getContext(canvas);

        canvas.width = IMAGE_WIDTH;
        canvas.height = IMAGE_HEIGHT;
        context.fillStyle = 'white';
        context.fillRect(0, 0, canvas.width, canvas.height);

        context.drawImage(background, 0, 0);
        context.drawImage(foreground, 0, 0);

        return canvas;
    }

    async fileToImage(file: File | string): Promise<HTMLImageElement> {
        return new Promise((resolve) => {
            const img = new Image();
            img.crossOrigin = 'Anonymous';
            img.src = typeof file === 'string' ? file : URL.createObjectURL(file);
            img.onload = () => {
                resolve(img);
            };
        });
    }

    async getDifferenceDialogData(firstCanvas: HTMLCanvasElement, secondCanvas: HTMLCanvasElement): Promise<DifferenceDialogData> {
        const firstImageBase64 = firstCanvas.toDataURL().split(',')[1];
        const secondImageBase64 = secondCanvas.toDataURL().split(',')[1];

        const diffInfo = await this.imagesDifferenceService.getDiffInfo({
            image1Base64: firstImageBase64,
            image2Base64: secondImageBase64,
            radius: this.radius,
        });

        const diffImage = await this.fileToImage(diffInfo.diffImage);

        return {
            difficulty: diffInfo.difficulty,
            nGroups: diffInfo.nGroups,
            radius: this.radius,
            firstImage: firstImageBase64,
            secondImage: secondImageBase64,
            diffImage,
        };
    }

    async validateImage(file: File): Promise<boolean> {
        if (file.type !== 'image/bmp') return false;
        const img = await this.fileToImage(file);
        return this.validateDimensions(img) && (await this.validateBitDepth(file));
    }

    private validateDimensions(image: HTMLImageElement): boolean {
        return image.naturalWidth === IMAGE_WIDTH && image.naturalHeight === IMAGE_HEIGHT;
    }

    private async validateBitDepth(file: File): Promise<boolean> {
        return new Promise((resolve) => {
            const reader = new FileReader();
            reader.readAsArrayBuffer(file);
            reader.onload = () => {
                const data = new Uint8Array(reader.result as ArrayBuffer);
                return resolve(data[BMP_BIT_DEPTH_INDEX] === BMP_BIT_DEPTH);
            };
        });
    }
}
