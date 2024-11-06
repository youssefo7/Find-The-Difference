import { UsernameDto } from './all-events.dto';

export enum FriendsEvent {
    // Common

    // Client to server
    RequestOrAcceptFriend = 'requestOrAcceptFriend',
    RefuseOrRemoveFriend = 'refuseOrRemoveFriend',

    // Server to client
    NotifyNewFriendRequest = 'notifyNewFriendRequest',
    NotifyNewFriend = 'notifyNewFriend',
    NotifyFriendRemoved = 'notifyFriendRemoved',
    NotifyFriendRequestRefused = 'notifyFriendRequestRefused',
    NotifyNewUser = 'notifyNewUser',
}

export interface ClientToServerFriendsEventsMap {
    [FriendsEvent.RequestOrAcceptFriend]: UsernameDto;
    [FriendsEvent.RefuseOrRemoveFriend]: UsernameDto;
}

export interface ServerToClientFriendsEventsMap {
    [FriendsEvent.NotifyNewFriendRequest]: UsernameDto;
    [FriendsEvent.NotifyNewFriend]: UsernameDto;
    [FriendsEvent.NotifyFriendRemoved]: UsernameDto;
    [FriendsEvent.NotifyFriendRequestRefused]: UsernameDto;
    [FriendsEvent.NotifyNewUser]: UsernameDto;
}
