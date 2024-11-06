import { GameTemplateId } from './ingame-ids.types';

export enum Difficulty {
    Easy = 'easy',
    Hard = 'hard',
}

export interface Vec2 {
    x: number;
    y: number;
}

export interface Color {
    r: number;
    g: number;
    b: number;
    a: number;
}

export const TIME_LIMIT_PREFIX = 'timeLimit';

export enum GameMode {
    TeamClassic = 'teamClassic',
    TimeLimitSingleDiff = 'timeLimitSingleDiff',
    TimeLimitAugmented = 'timeLimitAugmented',
    TimeLimitTurnByTurn = 'timeLimitTurnByTurn',
    ClassicMultiplayer = 'classicMultiplayer',
}

export enum ImageClicked {
    Left = 'left',
    Right = 'right',
}

export interface ForegroundState {
    leftImage: ImageData;
    rightImage: ImageData;
}

export interface CreateGameDto {
    name: string;
    price: number;
    firstImage: string;
    secondImage: string;
    radius: number;
}

export interface buyGameDto {
    gameTemplateId: GameTemplateId;
}

export interface GameTemplate {
    name: string;
    price: number;
    creator: string;
    difficulty: Difficulty;
    firstImage: string;
    secondImage: string;
    nGroups: number;
    _id: GameTemplateId;
}
