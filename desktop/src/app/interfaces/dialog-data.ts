import { Difficulty, GameMode } from '@common/game-template';
import { GameTemplateId } from '@common/ingame-ids.types';

export interface DifferenceDialogData {
    radius: number;
    diffImage: HTMLImageElement;
    firstImage: string;
    secondImage: string;
    difficulty: Difficulty;
    nGroups: number;
}

export interface EndgameDialogData {
    texts: string[];
    openReplayDialog?: () => void;
}

export interface GameChooserDialogData {
    gameMode: GameMode;
    gameTemplateId: GameTemplateId;
    gameName: string;
}

export interface ReplayDialogData {
    drawOriginalImages: () => void;
}

export interface MarketConfirmationDialogData {
    price: number;
}
