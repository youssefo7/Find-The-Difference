import { GameTemplateId } from '../ingame-ids.types';

export enum MarketEvent {
    // Common

    // Client to server
    BuyGame = 'buyGame',
    BuyHint = 'hint',
    GetGamesToSell = 'getGamesToSell',

    // Server to client
    GamesToSell = 'gamesToSell',
    UpdateBalance = 'updateBalance',
}

export interface ClientToServerMarketEventsMap {
    [MarketEvent.BuyGame]: BuyGameDto;
    [MarketEvent.GetGamesToSell]: void;
    [MarketEvent.BuyHint]: void;
}

export interface ServerToClientMarketEventsMap {
    [MarketEvent.UpdateBalance]: UpdateBalanceDto;
}

export class BuyGameDto {
    gameTemplateId: GameTemplateId;
}

export interface UpdateBalanceDto {
    balance: number;
}
