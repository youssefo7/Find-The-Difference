import { SPRAY_DENSITY } from '@app/constants/game-creation';
import { CANVAS_IMAGE_CHANNELS, IMAGE_HEIGHT, IMAGE_WIDTH } from '@common/constants';
import { Vec2 } from '@common/game-template';

export namespace DrawUtils {
    export const getAreaToFill = (pixels: Uint8ClampedArray, clickedPixel: Vec2): number[] => {
        if (clickedPixel.x < 0 || clickedPixel.x >= IMAGE_WIDTH || clickedPixel.y < 0 || clickedPixel.y >= IMAGE_HEIGHT) {
            return [];
        }

        const clickedPixelIndex = (clickedPixel.y * IMAGE_WIDTH + clickedPixel.x) * CANVAS_IMAGE_CHANNELS;
        const clickedPixelColor = getPixelColor(pixels, clickedPixelIndex);

        const areaToFill: number[] = [];
        const stack: number[] = [clickedPixelIndex];
        const visited = new Set<number>();

        // Depth-first search
        while (stack.length > 0) {
            // Get a pixel
            const pixelIndex = stack.pop();

            // If the pixel is falsy, skip it
            if (pixelIndex === undefined) {
                continue;
            }

            // Mark the pixel as visited
            visited.add(pixelIndex);

            // If the pixel is the same color as the clicked pixel, add it to the area to fill
            if (getPixelColor(pixels, pixelIndex) === clickedPixelColor) {
                areaToFill.push(pixelIndex);

                // Add the neighbors to the stack
                for (const neighbor of getNeighbors(pixelIndex)) {
                    const neighborIndex = (neighbor.y * IMAGE_WIDTH + neighbor.x) * CANVAS_IMAGE_CHANNELS;

                    // If the neighbor is within the image bounds and hasn't been visited, add it to the stack
                    if (neighbor.x >= 0 && neighbor.x < IMAGE_WIDTH && neighbor.y >= 0 && neighbor.y < IMAGE_HEIGHT && !visited.has(neighborIndex)) {
                        stack.push(neighborIndex);
                    }
                }
            }
        }

        return areaToFill;
    };

    const getPixelColor = (pixels: Uint8ClampedArray, pixelIndex: number): string => {
        return `rgba(${pixels[pixelIndex]}, ${pixels[pixelIndex + 1]}, ${pixels[pixelIndex + 2]}, ${pixels[pixelIndex + 3]})`;
    };

    const getNeighbors = (index: number): Vec2[] => {
        const { x, y } = getCoordinatesFromIndex(index);
        return [
            { x: x - 1, y },
            { x: x + 1, y },
            { x, y: y - 1 },
            { x, y: y + 1 },
        ];
    };

    const getCoordinatesFromIndex = (index: number): Vec2 => {
        return {
            x: (index % (IMAGE_WIDTH * CANVAS_IMAGE_CHANNELS)) / CANVAS_IMAGE_CHANNELS,
            y: Math.floor(index / (IMAGE_WIDTH * CANVAS_IMAGE_CHANNELS)),
        };
    };

    export const getRandomPointsInLine = (start: Vec2, end: Vec2, lineWidth: number): Vec2[] => {
        const points: Vec2[] = [];

        const dx = end.x - start.x;
        const dy = end.y - start.y;

        const lineAngle = Math.atan2(dy, dx);
        const lineCrossAngle = lineAngle + Math.PI / 2;
        const lineLength = Math.sqrt(dx ** 2 + dy ** 2);

        // Get random points in the semi-circles at the ends of the line
        const semiCircles = [
            { center: start, startAngle: lineCrossAngle },
            { center: end, startAngle: lineCrossAngle + Math.PI },
        ];
        const semiCircleRadius = lineWidth / 2;
        const semiCircleArea = (Math.PI * semiCircleRadius ** 2) / 2;
        const numberOfDotsInSemiCircle = Math.floor(semiCircleArea * SPRAY_DENSITY);
        for (const semiCircle of semiCircles) {
            for (let j = 0; j < numberOfDotsInSemiCircle; j++) {
                const angle = semiCircle.startAngle + Math.random() * Math.PI;
                const distance = Math.sqrt(Math.random()) * semiCircleRadius;
                const x = semiCircle.center.x + distance * Math.cos(angle);
                const y = semiCircle.center.y + distance * Math.sin(angle);
                points.push({ x, y });
            }
        }

        // Get random points in the rectangle between the two semi-circles
        const rectangleArea = lineWidth * Math.sqrt(dx ** 2 + dy ** 2);
        const numberOfDotsInRectangle = Math.floor(rectangleArea * SPRAY_DENSITY);
        for (let i = 0; i < numberOfDotsInRectangle; i++) {
            const positionInLine = Math.random() * lineLength;
            const distanceFromLine = Math.random() * lineWidth - lineWidth / 2;
            const x = start.x + positionInLine * Math.cos(lineAngle) + distanceFromLine * Math.cos(lineCrossAngle);
            const y = start.y + positionInLine * Math.sin(lineAngle) + distanceFromLine * Math.sin(lineCrossAngle);
            points.push({ x, y });
        }

        return points;
    };
}
