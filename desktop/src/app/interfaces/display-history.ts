import { Username } from '@common/ingame-ids.types';
export interface DisplayHistory {
    startTime: string;
    totalTime: string;
    gameMode: string;
    winners: Username[];
    losers: Username[];
    quitters: Username[];
}
