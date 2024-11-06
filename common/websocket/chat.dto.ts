import { ChatId, UnixTimeMs, Username } from '../ingame-ids.types';

export enum ChatEvent {
    // Common
    Message = 'message',

    // Client to server
    CreateChat = 'createChat',
    DeleteChat = 'deleteChat',
    JoinChat = 'joinChat',
    LeaveChat = 'leaveChat',

    // Server to client
    ChatCreated = 'chatCreated',
    ChatDeleted = 'chatDeleted',
    ChatJoined = 'chatJoined',
    ChatLeft = 'chatLeft',
    ServerMessage = 'serverMessage',

    // Server to client errors
    ChatNotFound = 'chatNotFound',
    CannotJoinGameChat = 'cannotJoinGameChat',
    CannotLeaveGameChat = 'cannotLeaveGameChat',
    AlreadyInChat = 'alreadyInChat',
    NotInChat = 'notInChat',
    NotChatCreator = 'notChatCreator',
    CannotJoinGeneralChat = 'cannotJoinGeneralChat',
    CannotLeaveGeneralChat = 'cannotLeaveGeneralChat',
    CannotDeleteGeneralChat = 'cannotDeleteGeneralChat',
}

export interface ClientToServerChatEventsMap {
    [ChatEvent.Message]: ClientToServerMessageDto;
    [ChatEvent.CreateChat]: ChatNameDto;
    [ChatEvent.DeleteChat]: ChatIdDto;
    [ChatEvent.JoinChat]: ChatIdDto;
    [ChatEvent.LeaveChat]: ChatIdDto;
}

export interface ServerToClientChatEventsMap {
    [ChatEvent.Message]: ServerToClientMessageDto;
    [ChatEvent.ChatCreated]: ChatCreatedDto;
    [ChatEvent.ChatDeleted]: ChatIdDto;
    [ChatEvent.ChatJoined]: ChatIdDto;
    [ChatEvent.ChatLeft]: ChatIdDto;
    [ChatEvent.ServerMessage]: ServerMessageDto;
    [ChatEvent.ChatNotFound]: ChatIdDto;
    [ChatEvent.CannotJoinGameChat]: ChatIdDto;
    [ChatEvent.CannotLeaveGameChat]: ChatIdDto;
    [ChatEvent.AlreadyInChat]: ChatIdDto;
    [ChatEvent.NotInChat]: ChatIdDto;
    [ChatEvent.NotChatCreator]: ChatIdDto;
    [ChatEvent.CannotJoinGeneralChat]: void;
    [ChatEvent.CannotLeaveGeneralChat]: void;
    [ChatEvent.CannotDeleteGeneralChat]: void;
}

export interface Message {
    sender: Username;
    content: string;
    timestamp: UnixTimeMs;
    senderAvatar: string;
    isStickerGif?: boolean;
}

export interface Chat {
    users: Username[];
    creator: Username;
    name: string;
    isInGame: boolean;
    chatId: ChatId;
}

export interface ChatIdDto {
    chatId: ChatId;
}

export interface ChatNameDto {
    name: string;
}

export interface ChatCreatorDto {
    creator: Username;
}

export interface ClientToServerMessageDto {
    chatId: string;
    content: string;
}

export interface ServerToClientMessageDto {
    chatId: ChatId;
    sender: Username;
    content: string;
    timestamp: UnixTimeMs;
    senderAvatar: string;
}

export interface ChatCreatedDto {
    chatId: ChatId;
    name: string;
    creator: Username;
}

export interface ServerMessageDto {
    chatId: ChatId;
    content: string;
    frenchContent: string;
    timestamp: UnixTimeMs;
}
