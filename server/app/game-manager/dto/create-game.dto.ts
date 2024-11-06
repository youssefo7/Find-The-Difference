import { GameMode } from '@common/game-template';
import { ImagesDifferences } from '@common/images-differences';
import { ChatId, GameTemplateId, Username } from '@common/ingame-ids.types';
import { TimeConfigDto } from '@common/websocket/waiting-room.dto';

export interface BaseCreateInstance {
    gameMode: GameMode;
    timeConfig: TimeConfigDto;
    teams: Set<Username>[];
    chatId: ChatId;
}

export interface ImagesDifferencesForGame extends ImagesDifferences {
    _id: GameTemplateId;
    name: string;
}

export interface TimeLimitCreateInstance extends BaseCreateInstance {
    gameTemplates: ImagesDifferencesForGame[];
}

export interface ClassicCreateInstance extends BaseCreateInstance {
    gameTemplateId: GameTemplateId;
}

export type ClassicTeamCreateInstance = BaseCreateInstance;
