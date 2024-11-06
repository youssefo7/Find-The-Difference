import { ImageClicked, Vec2 } from '../game-template';
import { GameTemplateId, TeamIndex, UnixTimeMs, Username } from '../ingame-ids.types';
import { UsernameDto } from './all-events.dto';
import { JoinGameDto, TimeConfigDto } from './waiting-room.dto';

export enum InGameEvent {
    // Common
    CheatModeEvent = 'cheatModeEvent',

    // Client to server
    IdentifyDifference = 'identifyDifference',
    LeaveGame = 'leaveGame', // Warning: also used in "waiting-room.dto.ts"
    SendHint = 'sendHint',
    JoinGameObserver = 'joinGameObserver',

    // Server to client
    PlayerLeave = 'playerLeave',
    StartGame = 'startGame',
    EndGame = 'endGame',
    DifferenceFound = 'differenceFound',
    DifferenceNotFound = 'differenceNotFound',
    ShowError = 'showError',
    RemovePixels = 'removePixels',
    TimeEvent = 'timeEvent',
    ChangeTemplate = 'changeTemplate',
    InstanceDeletion = 'onInstanceDeletion', // Warning: also used in "waiting-room.dto.ts"

    ReceiveHint = 'receiveHint',
    ObserverJoinedEvent = 'observerJoinedEvent',
    ObserverLeavedEvent = 'observerLeavedEvent',
    ObserverStateSync = 'observerStateSync',
}

export interface ClientToServerInGameEventsMap {
    [InGameEvent.LeaveGame]: void;
    [InGameEvent.IdentifyDifference]: IdentifyDifferenceDto;
    [InGameEvent.CheatModeEvent]: void;

    [InGameEvent.JoinGameObserver]: JoinGameDto;
    [InGameEvent.SendHint]: SendHintDto;
}

export interface ServerToClientInGameEventsMap {
    [InGameEvent.StartGame]: StartGameDto;
    [InGameEvent.EndGame]: EndGameDto;
    [InGameEvent.DifferenceFound]: DifferenceFoundDto;
    [InGameEvent.DifferenceNotFound]: DifferenceNotFoundDto;
    [InGameEvent.ShowError]: ShowErrorDto;
    [InGameEvent.RemovePixels]: RemovePixelsDto;
    [InGameEvent.TimeEvent]: TimeEventDto;
    [InGameEvent.InstanceDeletion]: void; // Warning: also used in "waiting-room.dto.ts"
    [InGameEvent.CheatModeEvent]: CheatModeDto;
    [InGameEvent.ChangeTemplate]: ChangeTemplateDto;
    [InGameEvent.PlayerLeave]: UsernameDto;

    [InGameEvent.ReceiveHint]: ReceiveHintDto;
    [InGameEvent.ObserverJoinedEvent]: UsernameDto;
    [InGameEvent.ObserverLeavedEvent]: UsernameDto;
    [InGameEvent.ObserverStateSync]: StateDto;
}

export interface IdentifyDifferenceDto {
    position: Vec2;
    imageClicked: ImageClicked;
}

export interface StartGameDto {
    nGroups: number;
    teams: Record<TeamIndex, Username[]>;
    timeConfig: TimeConfigDto;
}

export interface EndGameDto {
    winners: Username[];
    losers: Username[];
    totalTimeMs: number;
    pointsReceived: number;
}

export interface DifferenceFoundDto {
    username: Username;
    time: UnixTimeMs;
}

export interface DifferenceNotFoundDto {
    username: Username;
    time: UnixTimeMs;
}

export interface ShowErrorDto {
    position: Vec2;
    imageClicked: ImageClicked;
}

export interface RemovePixelsDto {
    pixels: Vec2[];
}

export interface TimeEventDto {
    timeMs: number;
    team2TimeMs?: number;
}

export interface ReceiveChatMessageDto {
    message: string;
    sender: Username;
    time: UnixTimeMs;
}

export interface CheatModeDto {
    groupToPixels: Vec2[][];
}

export interface ChangeTemplateDto {
    nextGameTemplateId?: GameTemplateId;
    pixelsToRemove?: Vec2[];
}

export interface SendChatMessageDto {
    message: string;
}

export interface ReceiveHintDto {
    rect: [Vec2, Vec2];
    sender: Username;
}

export interface SendHintDto {
    rect: [Vec2, Vec2];
    player?: Username;
}

export interface StateDto {
    startGameDto: StartGameDto;
    pixelToRemove: Vec2[];
    playerScore: Record<Username, number>;
    observers: Username[];
    timeLimitPreload?: [ChangeTemplateDto, ChangeTemplateDto];
}
