import { userRoomPrefix } from '@app/auth/auth.guard';
import { AuthService } from '@app/auth/auth.service';
import { UsersService } from '@app/users/users.service';
import { GEN_CHAT_ID, INITIAL_DEFAULT_AVATAR } from '@common/constants';
import { Username } from '@common/ingame-ids.types';
import { Injectable } from '@nestjs/common';
import { WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Chat, ChatEvent, ServerToClientChatEventsMap } from '@websocket/chat.dto';
import { randomUUID } from 'crypto';
import { Server } from 'socket.io';
import { environment } from './../../../desktop/src/environments/environment';

@WebSocketGateway({ cors: true })
@Injectable()
export class ChatService {
    @WebSocketServer() private server: Server;

    readonly generalChatId = GEN_CHAT_ID;
    private chats: Chat[] = [];

    constructor(
        private readonly authService: AuthService,
        private readonly usersService: UsersService,
    ) {
        const generalChat: Chat = { chatId: this.generalChatId, name: 'General', creator: '', isInGame: false, users: [] };
        this.chats.push(generalChat);
        this.authService.onUserConnect((username) => {
            if (!generalChat.users.includes(username)) generalChat.users.push(username);
            this.getJoinedChats(username).forEach((chat) => {
                this.server.in(userRoomPrefix + username).socketsJoin(chat.chatId);
                this.addServerMessageToChat(chat.chatId, `${username} joined the chat.`, `${username} a rejoint le chat.`);
            });
        });
        this.authService.onUserDisconnect((username) => {
            this.getJoinedChats(username).forEach((chat) => {
                this.server.in(userRoomPrefix + username).socketsLeave(chat.chatId);
                this.addServerMessageToChat(chat.chatId, `${username} left the chat.`, `${username} a quitté le chat.`);
            });
            generalChat.users = generalChat.users.filter((u) => u !== username);
        });

        UsersService.addOnUsernameChangeCallback(async (oldUsername: Username, newUsername: Username) => {
            this.chats = this.chats.map((chat) => {
                if (chat.creator === oldUsername) chat.creator = newUsername;
                chat.users = chat.users.map((user) => (user === oldUsername ? newUsername : user));
                return chat;
            });
        });
    }

    createChat(name: string, creator: Username, isInGame: boolean = false) {
        const chatId = randomUUID();
        this.chats.push({ chatId, name, creator, isInGame, users: [] });
        this.globalEmit(ChatEvent.ChatCreated, { chatId, name, creator });
        this.addUserToChat(chatId, creator);
        return chatId;
    }

    getChat(chatId: string) {
        return this.chats.find((chat) => chat.chatId === chatId);
    }

    deleteChat(chatId: string, username: string) {
        if (chatId === this.generalChatId) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.CannotDeleteGeneralChat, undefined);
            return;
        }
        const chatToDelete = this.getChat(chatId);
        if (!chatToDelete) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.ChatNotFound, { chatId });
            return;
        }
        if (chatToDelete.creator !== username) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.NotChatCreator, { chatId });
            return;
        }
        chatToDelete.users.forEach((user) => this.removeUserFromChat(chatId, user));
        this.chats = this.chats.filter((chat) => chat.chatId !== chatId);
        this.globalEmit(ChatEvent.ChatDeleted, { chatId });
    }

    addUserToChat(chatId: string, username: string, fromGameService: boolean = false) {
        if (chatId === this.generalChatId) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.CannotJoinGeneralChat, undefined);
            return;
        }
        const chat = this.getChat(chatId);
        if (!chat) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.ChatNotFound, { chatId });
            return;
        }
        if (chat.users.includes(username)) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.AlreadyInChat, { chatId });
            return;
        }
        if (!fromGameService && chat.isInGame) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.CannotJoinGameChat, { chatId });
            return;
        }
        chat.users.push(username);
        this.server.in(userRoomPrefix + username).socketsJoin(chatId);
        this.roomEmit(userRoomPrefix + username, ChatEvent.ChatJoined, { chatId });
        this.addServerMessageToChat(chatId, `${username} joined the chat.`, `${username} a rejoint le chat.`);
    }

    removeUserFromChat(chatId: string, username: Username, fromGameService: boolean = false) {
        if (chatId === this.generalChatId) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.CannotLeaveGeneralChat, undefined);
            return;
        }
        const chat = this.getChat(chatId);
        if (!chat) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.ChatNotFound, { chatId });
            return;
        }
        if (!chat.users.includes(username)) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.NotInChat, { chatId });
            return;
        }
        if (!fromGameService && chat.isInGame) {
            this.roomEmit(userRoomPrefix + username, ChatEvent.CannotLeaveGameChat, { chatId });
            return;
        }
        chat.users = chat.users.filter((u) => u !== username);
        this.addServerMessageToChat(chatId, `${username} left the chat.`, `${username} a quitté le chat.`);
        this.server.in(userRoomPrefix + username).socketsLeave(chatId);
        this.roomEmit(userRoomPrefix + username, ChatEvent.ChatLeft, { chatId });
    }

    async addMessageToChat(chatId: string, sender: Username, content: string) {
        const chat = this.getChat(chatId);
        if (!chat) {
            this.globalEmit(ChatEvent.ChatNotFound, { chatId });
            return;
        }
        const timestamp = Date.now();
        const senderAvatar = await this.getUserAvatar(sender);
        this.roomEmit(chatId, ChatEvent.Message, { chatId, sender, content, timestamp, senderAvatar });
    }

    addServerMessageToChat(chatId: string, content: string, frenchContent: string) {
        const chat = this.getChat(chatId);
        if (!chat) {
            this.globalEmit(ChatEvent.ChatNotFound, { chatId });
            return;
        }
        const timestamp = Date.now();
        this.roomEmit(chatId, ChatEvent.ServerMessage, { chatId, content, timestamp, frenchContent });
    }

    getAvailableChats(username: Username): Chat[] {
        return this.chats.filter((chat) => !chat.isInGame || chat.users.includes(username));
    }

    getJoinedChats(username: Username): Chat[] {
        return this.chats.filter((chat) => chat.users.includes(username));
    }

    async getUserAvatar(username: Username): Promise<string> {
        const userProfile = await this.usersService.getProfile(username);
        const userAvatar = environment.s3BucketUrl + '/' + userProfile?.avatarUrl;
        return userAvatar || INITIAL_DEFAULT_AVATAR;
    }
    private globalEmit<K extends keyof ServerToClientChatEventsMap>(eventName: K, dto: ServerToClientChatEventsMap[K]): void {
        this.server.emit(eventName, dto);
    }

    private roomEmit<K extends keyof ServerToClientChatEventsMap>(room: string, eventName: K, dto: ServerToClientChatEventsMap[K]): void {
        this.server.to(room).emit(eventName, dto);
    }
}
