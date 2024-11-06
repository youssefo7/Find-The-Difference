import { UnixTimeMs, Username } from '@common/ingame-ids.types';
import { ImagesDifferencesForGame } from './create-game.dto';

export interface TeamData {
    lastClickTimestamp?: UnixTimeMs;
    score: number;
    players: Username[];
}

export interface TimeData {
    startTime: UnixTimeMs;
    totalDeltaTime: number;
    intervalId: NodeJS.Timeout;
}

export interface SingleDiffGameTemplate extends ImagesDifferencesForGame {
    differenceToKeep: number;
}
