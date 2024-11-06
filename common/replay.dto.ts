import { GameMode } from './game-template';
import { GameTemplateId, Username } from './ingame-ids.types';

export type ReplayId = string;

export class ReplayEvent {
    name: string;
    time: number;
    data: unknown;
}

export class SendReplayDto {
    events: ReplayEvent[];
    gameTemplateId: GameTemplateId;
    gameMode: GameMode;
}

export class ReceiveReplayDto {
    id: ReplayId;
    events: ReplayEvent[];
    gameTemplateId: GameTemplateId;
    gameMode: GameMode;
    username: Username;
}
