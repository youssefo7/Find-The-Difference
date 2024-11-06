import { GameMode } from '../game-template';
import { GameTemplateId, InstanceId, TeamIndex, Username } from '../ingame-ids.types';
import { UsernameDto } from './all-events.dto';
import { ClientToServerInGameEventsMap, InGameEvent, ServerToClientInGameEventsMap } from './in-game.dto';

export enum WaitingRoomEvent {
    // Common

    // Client to server
    InstantiateGame = 'instantiateGame',
    JoinGame = 'joinGame',

    ApprovePlayer = 'approvePlayer',
    RejectPlayer = 'rejectPlayer',
    ChangeTeam = 'changeTeam',
    EndSelection = 'endSelection',

    // Server to client
    JoinRequests = 'joinRequests',
    WaitingRefusal = 'waitingRefusal',
    AssignGameMaster = 'assignGameMaster',
    InvalidStartingState = 'invalidStartingState',
    GetWaitingGames = 'getWaitingGames',
    WaitingGames = 'waitingGames',
}

export interface ClientToServerWaitingRoomEventsMap extends Pick<ClientToServerInGameEventsMap, InGameEvent.LeaveGame> {
    [WaitingRoomEvent.EndSelection]: void;
    [WaitingRoomEvent.GetWaitingGames]: void;
    [WaitingRoomEvent.ApprovePlayer]: UsernameDto;
    [WaitingRoomEvent.RejectPlayer]: UsernameDto;
    [WaitingRoomEvent.ChangeTeam]: ChangeTeamDto;
    [WaitingRoomEvent.InstantiateGame]: InstantiateGameDto;
    [WaitingRoomEvent.JoinGame]: JoinGameDto;
}

export interface ServerToClientWaitingRoomEventsMap extends Pick<ServerToClientInGameEventsMap, InGameEvent.InstanceDeletion> {
    [WaitingRoomEvent.JoinRequests]: JoinRequestsDto;
    [WaitingRoomEvent.AssignGameMaster]: void;
    [WaitingRoomEvent.WaitingRefusal]: void;
    [WaitingRoomEvent.InvalidStartingState]: void;
    [WaitingRoomEvent.WaitingGames]: WaitingGamesListDto;
}

export interface WaitingGamesListDto {
    waitingGames: WaitingGameDto[];
    observerGames: ObserverGameDto[];
}

export interface WaitingGameDto {
    templateId: GameTemplateId;
    instanceId: InstanceId;
    creator: Username;
    gameMode: GameMode;
    players: Username[];
}

export interface ObserverGameDto {
    templateId: GameTemplateId;
    instanceId: InstanceId;
    players: Username[];
    gameMode: GameMode;
    hasObservers: boolean;
}

export interface JoinGameDto {
    instanceId: InstanceId;
}

export interface JoinRequestsDto {
    requests: Username[];
    players: Username[];
    teams: Username[][];
}

export interface TimeConfigDto {
    totalTime: number;
    rewardTime: number;
    cheatModeAllowed: boolean;
}

export interface InstantiateGameDto {
    gameTemplateId: GameTemplateId;
    gameMode: GameMode;
    timeConfig: TimeConfigDto;
}

export interface ChangeTeamDto {
    newTeam: TeamIndex;
}
