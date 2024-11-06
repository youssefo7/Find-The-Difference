import { GameMode } from './game-template';
import { Username } from './ingame-ids.types';

export interface HistoryDto {
    startTime: number;
    totalTime: number;
    gameMode: GameMode;
    winners: Username[];
    losers: Username[];
    quitters: Username[];
}
