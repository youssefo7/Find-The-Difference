import { Username } from '../ingame-ids.types';
import { ClientToServerChatEventsMap, ServerToClientChatEventsMap } from './chat.dto';
import { ClientToServerFriendsEventsMap, ServerToClientFriendsEventsMap } from './friends.dto';
import { ClientToServerInGameEventsMap, ServerToClientInGameEventsMap } from './in-game.dto';
import { ClientToServerMarketEventsMap, ServerToClientMarketEventsMap } from './market.dto';
import { ClientToServerWaitingRoomEventsMap, ServerToClientWaitingRoomEventsMap } from './waiting-room.dto';

export interface ClientToServerEventsMap
    extends ClientToServerChatEventsMap,
        ClientToServerFriendsEventsMap,
        ClientToServerInGameEventsMap,
        ClientToServerMarketEventsMap,
        ClientToServerWaitingRoomEventsMap {}

export interface ServerToClientEventsMap
    extends ServerToClientChatEventsMap,
        ServerToClientFriendsEventsMap,
        ServerToClientInGameEventsMap,
        ServerToClientMarketEventsMap,
        ServerToClientWaitingRoomEventsMap {}

export class UsernameDto {
    username: Username;
}
