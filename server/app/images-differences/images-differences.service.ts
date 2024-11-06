import { CANVAS_IMAGE_CHANNELS, IMAGE_HEIGHT, IMAGE_WIDTH, PIXELS_CHANNELS, PIXELS_MAX_VALUES } from '@common/constants';
import { ErrorMessage } from '@common/error-response.dto';
import { Difficulty, Vec2 } from '@common/game-template';
import { Image, Pixel } from '@common/image';
import { DifferencesGroups, ImagesDifferences } from '@common/images-differences';
import { DEFAULT_GROUPS_VALUE, HARD_DIFFERENCES_NGROUPS_MIN, HARD_DIFFERENCES_PROPORTION_MAX } from '@common/images-differences.constants';
import { BadRequestException, Injectable } from '@nestjs/common';
import { ImageData, createCanvas, loadImage } from 'canvas';
import { CreateImagesDifferencesDto } from './dto/create-images-differences.dto';

@Injectable()
export class ImagesDifferencesService {
    private imageWidth = IMAGE_WIDTH;
    private imageHeight = IMAGE_HEIGHT;

    async toBlackAndWhite(diff: ImagesDifferences): Promise<string> {
        return this.imageToBase64({
            pixels: diff.pixelToGroup.map((line) => {
                return line.map((value) => {
                    if (value === null) return [PIXELS_MAX_VALUES, PIXELS_MAX_VALUES, PIXELS_MAX_VALUES];
                    return [0, 0, 0];
                });
            }),
            width: this.imageWidth,
            height: this.imageHeight,
        });
    }

    async computeDiff(createImagesDifferencesDto: CreateImagesDifferencesDto): Promise<ImagesDifferences> {
        const image1 = await this.base64ToImage(createImagesDifferencesDto.image1Base64);
        const image2 = await this.base64ToImage(createImagesDifferencesDto.image2Base64);
        let differences: DifferencesGroups = this.createBaseDifferenceImage(image1, image2);
        differences = this.growDifferences(differences, createImagesDifferencesDto.radius);
        return this.makeGroups(differences);
    }

    private countDifferentPixels(differences: DifferencesGroups): number {
        return differences.reduce((acc, line) => {
            return acc + line.filter((value) => value !== null).length;
        }, 0);
    }

    private createBaseDifferenceImage(image1: Image, image2: Image): DifferencesGroups {
        const differences = this.createArray();

        image1.pixels.forEach((column, xIndex) => {
            column.forEach((pixel, yIndex) => {
                const twinPixel = image2.pixels[xIndex][yIndex];
                if (pixel.every((value, channel) => value === twinPixel[channel])) return;
                differences[xIndex][yIndex] = DEFAULT_GROUPS_VALUE;
            });
        });

        return differences;
    }

    private createArray(): DifferencesGroups {
        return new Array(this.imageWidth).fill(null).map(() => {
            return new Array(this.imageHeight).fill(null);
        });
    }

    private growDifferences(differences: DifferencesGroups, radius: number): DifferencesGroups {
        // We iterate on the copy because the loop change the array while iterating and we need the original data
        let differencesExtended: DifferencesGroups = JSON.parse(JSON.stringify(differences));

        differences.forEach((line, x) => {
            line.forEach((value, y) => {
                if (value === null) return;
                differencesExtended = this.growPixel(differencesExtended, radius, { x, y });
            });
        });

        return differencesExtended;
    }

    private growPixel(differencesExtended: DifferencesGroups, radius: number, { x, y }: Vec2): DifferencesGroups {
        const value = differencesExtended[x][y];

        for (let dx = -radius; dx <= radius; dx++) {
            for (let dy = -radius; dy <= radius; dy++) {
                if (dx * dx + dy * dy > radius * radius) continue;
                const newX = x + dx;
                const newY = y + dy;
                if (this.isInBounds(newX, newY)) {
                    differencesExtended[newX][newY] = value;
                }
            }
        }

        return differencesExtended;
    }

    private makeGroups(differences: DifferencesGroups): ImagesDifferences {
        let currentGroup = 0;
        const groupToPixels: Vec2[][] = [];
        differences.forEach((line, x) => {
            line.forEach((value, y) => {
                if (value === null) return;
                if (value !== DEFAULT_GROUPS_VALUE) return;

                groupToPixels.push(this.groupBFS(differences, { x, y }, currentGroup));
                currentGroup++;
            });
        });

        const differentPixelsCount = this.countDifferentPixels(differences);
        const nGroups = groupToPixels.length;
        const isHard =
            differentPixelsCount < HARD_DIFFERENCES_PROPORTION_MAX * (this.imageWidth * this.imageHeight) && nGroups >= HARD_DIFFERENCES_NGROUPS_MIN;

        return {
            nGroups,
            pixelToGroup: differences,
            difficulty: isHard ? Difficulty.Hard : Difficulty.Easy,
            groupToPixels,
        };
    }

    private groupBFS(differences: DifferencesGroups, position: Vec2, currentGroup: number): Vec2[] {
        const queue = [position];

        const pixelsInGroup = [position];
        differences[position.x][position.y] = currentGroup;

        while (queue.length > 0) {
            const pos = queue.shift();
            if (pos === undefined) throw new Error('Impossible empty queue');
            const current = pos;

            for (const { x, y } of this.getNeighbors(current)) {
                if (differences[x][y] !== DEFAULT_GROUPS_VALUE) continue;

                differences[x][y] = currentGroup;
                pixelsInGroup.push({ x, y });
                queue.push({ x, y });
            }
        }
        return pixelsInGroup;
    }

    private getNeighbors(position: Vec2): Vec2[] {
        const neighbors = [];

        for (let x = position.x - 1; x <= position.x + 1; x++) {
            for (let y = position.y - 1; y <= position.y + 1; y++) {
                if (!this.isInBounds(x, y)) continue;
                neighbors.push({ x, y });
            }
        }

        return neighbors;
    }

    private isInBounds(x: number, y: number): boolean {
        const validX = x >= 0 && x < this.imageWidth;
        const validY = y >= 0 && y < this.imageHeight;
        return validX && validY;
    }

    private async base64ToImage(base64Image: string): Promise<Image> {
        try {
            const image = await loadImage(Buffer.from(base64Image, 'base64'));
            const ctx = createCanvas(this.imageWidth, this.imageHeight).getContext('2d');
            ctx.drawImage(image, 0, 0, this.imageWidth, this.imageHeight);
            return this.imageDataToImage(ctx.getImageData(0, 0, this.imageWidth, this.imageHeight));
        } catch (err) {
            throw new BadRequestException(ErrorMessage.ImageInvalid);
        }
    }

    private async imageToBase64(image: Image): Promise<string> {
        const canvas = createCanvas(this.imageWidth, this.imageHeight);
        canvas.getContext('2d').putImageData(await this.imageToImageData(image), 0, 0);
        return canvas.toDataURL();
    }

    private imageDataToImage(imageData: ImageData): Image {
        const pixelArray: Pixel[][] = new Array(imageData.width).fill(false).map((_value, xIndex) => {
            return new Array(imageData.height).fill(false).map((_value2, yIndex) => {
                const index: number = (yIndex * imageData.width + xIndex) * CANVAS_IMAGE_CHANNELS;
                return [imageData.data[index], imageData.data[index + 1], imageData.data[index + 2]];
            });
        });

        return { pixels: pixelArray, width: imageData.width, height: imageData.height };
    }

    private imageToImageData(image: Image): ImageData {
        const valuesArray: Uint8ClampedArray = new Uint8ClampedArray(image.width * image.height * CANVAS_IMAGE_CHANNELS)
            .fill(PIXELS_MAX_VALUES)
            .map((_value, index) => {
                if (index % CANVAS_IMAGE_CHANNELS >= PIXELS_CHANNELS) return PIXELS_MAX_VALUES;
                const x = Math.floor(index / CANVAS_IMAGE_CHANNELS) % image.width;
                const y = Math.floor(index / CANVAS_IMAGE_CHANNELS / image.width);
                return image.pixels[x][y][index % CANVAS_IMAGE_CHANNELS];
            });

        return new ImageData(valuesArray, image.width, image.height);
    }
}
