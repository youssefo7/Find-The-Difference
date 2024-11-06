export type Pixel = [number, number, number];

export interface Image {
    readonly pixels: Pixel[][];
    readonly width: number;
    readonly height: number;
}
