import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { GEN_CHAT_ID, SERVER_USERNAME } from '@common/constants';
import { ChatId } from '@common/ingame-ids.types';
import { Chat, ChatEvent, Message, ServerToClientMessageDto } from '@common/websocket/chat.dto';
import { firstValueFrom } from 'rxjs';
import { environment } from 'src/environments/environment';
import { AuthService } from './auth.service';
import { SocketIoService } from './socket.io.service';

export interface ClientMessage extends Message {
    isFromServer: boolean;
    frenchContent: string;
}

export interface ClientChat extends Chat {
    messages: ClientMessage[];
}

@Injectable({
    providedIn: 'root',
})
export class ChatService {
    message: string = '';
    chats: ClientChat[] = [];
    joinedChats: ClientChat[] = [];
    currentChat: ClientChat;

    isRoomVisible = false;
    isPopupVisible = false;

    isPopoutOpen = false;

    private readonly baseUrl: string = environment.serverUrl;

    constructor(
        private readonly http: HttpClient,
        private readonly socketIoService: SocketIoService,
        private readonly authService: AuthService,
    ) {}

    get username() {
        return this.authService.getUsername();
    }

    get currentChatId() {
        return this.currentChat ? this.currentChat.chatId : '';
    }

    get isChatCreator() {
        return this.currentChat.creator === this.username;
    }

    get isInGame() {
        return this.currentChat.isInGame;
    }

    get isGeneralChat() {
        return this.currentChatId === GEN_CHAT_ID;
    }

    get messages() {
        return this.currentChat.messages.sort((a, b) => a.timestamp - b.timestamp);
    }

    sendUserMessage(message: string) {
        this.socketIoService.emit(ChatEvent.Message, { chatId: this.currentChatId, content: message });
    }

    createChat(chatName: string) {
        this.socketIoService.emit(ChatEvent.CreateChat, { name: chatName });
    }

    joinChat(chatId: string) {
        this.socketIoService.emit(ChatEvent.JoinChat, { chatId });

        const chat = this.chats.find((c) => c.chatId === chatId);
        if (chat && !this.joinedChats.some((c) => c.chatId === chatId)) {
            this.joinedChats.push(chat);
        }
    }

    openChat(chatId: string) {
        const chat = this.chats.find((c) => c.chatId === chatId);
        if (!chat) return;
        this.currentChat = chat;
        this.isRoomVisible = true;
    }

    leaveChat(chatId: string) {
        this.socketIoService.emit(ChatEvent.LeaveChat, { chatId });
    }

    deleteChat(chatId: string) {
        this.socketIoService.emit(ChatEvent.DeleteChat, { chatId });
    }

    addMessage(message: ServerToClientMessageDto, isFromServer: boolean = false, frenchContent: string = '') {
        const isStickerGif = message.content.startsWith(environment.s3BucketUrl) && this.isValidUrl(message.content);
        const fullMessage = { ...message, isStickerGif, isFromServer, frenchContent };

        const chat = this.chats.find((c) => c.chatId === message.chatId);
        if (chat) {
            chat.messages.push(fullMessage);
        }
    }

    toggleChatVisibility() {
        this.isPopupVisible = !this.isPopupVisible;
    }

    toSelectionScreen() {
        this.isRoomVisible = false;
    }

    async joinableChats(): Promise<ClientChat[]> {
        return (await this.getAvailableChats()).filter(
            (availableChat) => !this.joinedChats.some((joinedChat) => joinedChat.chatId === availableChat.chatId),
        );
    }

    leaveDeletedChat(chatId: ChatId) {
        this.joinedChats = this.joinedChats.filter((chat) => chat.chatId !== chatId);
        this.chats = this.chats.filter((chat) => chat.chatId !== chatId);
        if (chatId === this.currentChatId) this.toSelectionScreen();
    }

    initialize() {
        this.socketIoService.onConnect(() => {
            this.listenOnEvents();
            this.reset();
            Promise.all([this.fetchAvailableChats(), this.fetchJoinedChats()]).then(() => this.joinChat(GEN_CHAT_ID));
        });
    }

    private async getAvailableChats(): Promise<ClientChat[]> {
        const url = `${this.baseUrl}/chat/available-chats`;
        return firstValueFrom(this.http.get<Chat[]>(url)).then((chats) => chats.map((chat) => ({ ...chat, messages: [] as ClientMessage[] })));
    }

    private async getJoinedChats(): Promise<ClientChat[]> {
        const url = `${this.baseUrl}/chat/joined-chats`;
        return firstValueFrom(this.http.get<Chat[]>(url)).then((chats) => chats.map((chat) => ({ ...chat, messages: [] as ClientMessage[] })));
    }

    private async fetchAvailableChats() {
        this.chats = await this.getAvailableChats();
    }

    private async fetchJoinedChats() {
        this.joinedChats = await this.getJoinedChats();
    }

    private isValidUrl(message: string) {
        try {
            const url = new URL(message);
            return url.href === message;
        } catch (err) {
            return false;
        }
    }

    private reset() {
        this.isRoomVisible = false;
        this.isPopupVisible = false;
    }

    private listenOnEvents() {
        this.socketIoService.on(ChatEvent.Message, (msg) => {
            this.addMessage(msg);
        });

        this.socketIoService.on(ChatEvent.ServerMessage, (msg) => {
            this.addMessage({ ...msg, sender: '', senderAvatar: '' }, true, msg.frenchContent);
        });

        this.socketIoService.on(ChatEvent.ChatCreated, (chatCreatedDto) => {
            this.chats.push({ ...chatCreatedDto, users: [], messages: [], isInGame: chatCreatedDto.creator === SERVER_USERNAME });
        });

        this.socketIoService.on(ChatEvent.ChatJoined, async ({ chatId }) => {
            let chat = this.chats.find((c) => c.chatId === chatId);
            if (!chat) {
                const availableChats = await this.getAvailableChats();
                this.chats = this.chats.concat(
                    availableChats.filter((availableChat) => !this.chats.some((knownChat) => knownChat.chatId === availableChat.chatId)),
                );
                chat = this.chats.find((c) => c.chatId === chatId);
            }
            if (chat && !this.joinedChats.some((c) => c.chatId === chatId)) {
                this.joinedChats.push(chat);
            }
        });

        this.socketIoService.on(ChatEvent.ChatDeleted, ({ chatId }) => {
            this.joinedChats = this.joinedChats.filter((chat) => chat.chatId !== chatId);
            this.chats = this.chats.filter((chat) => chat.chatId !== chatId);
            if (chatId === this.currentChatId) this.toSelectionScreen();
        });

        this.socketIoService.on(ChatEvent.ChatLeft, ({ chatId }) => {
            this.joinedChats = this.joinedChats.filter((chat) => chat.chatId !== chatId);
            if (chatId === this.currentChatId) this.toSelectionScreen();
        });
    }
}
