import { Difficulty, Vec2 } from './game-template';

export type DifferencesGroups = (number | null)[][];

export interface ImagesDifferences {
    readonly nGroups: number;
    readonly pixelToGroup: DifferencesGroups;
    readonly difficulty: Difficulty;
    readonly groupToPixels: Vec2[][];
}

export interface CreateDiffDto {
    image1Base64: string;
    image2Base64: string;
    radius: number;
}

export interface CreateDiffResult {
    nGroups: number;
    difficulty: Difficulty;
    diffImage: string;
}
