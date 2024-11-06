export enum DrawingTools {
    Pen = 'pen',
    Rectangle = 'rectangle',
    Eraser = 'eraser',
    Ellipse = 'ellipse',
    Bucket = 'bucket',
    Spray = 'spray',
}

export type Corner = [boolean, boolean];

export const possibleCorners: { [K in string]: Corner } = {
    topLeft: [true, true],
    topRight: [true, false],
    bottomLeft: [false, true],
    bottomRight: [false, false],
};
