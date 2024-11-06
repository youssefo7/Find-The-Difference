import { AfterViewChecked, Component, ElementRef, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { ChatCreationDialogComponent } from '@app/components/chat-creation-dialog/chat-creation-dialog.component';
import { ChatJoinDialogComponent } from '@app/components/chat-join-dialog/chat-join-dialog.component';
import { ChatService } from '@app/services/chat.service';
import { LocaleService } from '@app/services/locale.service';
import { ChatId, Username } from '@common/ingame-ids.types';

@Component({
    selector: 'app-chat',
    templateUrl: './chat.component.html',
    styleUrl: './chat.component.scss',
})
export class ChatComponent implements AfterViewChecked {
    @ViewChild('scrollMe', { static: false }) private myScrollContainer: ElementRef;

    message: string = '';
    isPopoutOpen = false;
    isModalOpen = false;

    constructor(
        private dialog: MatDialog,
        public chatService: ChatService,
        readonly localeService: LocaleService,
    ) {}

    get username(): Username {
        return this.chatService.username;
    }

    ngAfterViewChecked() {
        this.scrollToBottom();
    }

    scrollToBottom(): void {
        if (this.myScrollContainer && this.myScrollContainer.nativeElement) {
            this.myScrollContainer.nativeElement.scrollTop = this.myScrollContainer.nativeElement.scrollHeight;
        }
    }

    onPopoutOpened(): void {
        this.isPopoutOpen = true;
    }

    onPopoutClosed(): void {
        this.isPopoutOpen = false;
    }

    toggleChatVisibility() {
        this.chatService.toggleChatVisibility();
    }

    toSelectionScreen() {
        this.chatService.toSelectionScreen();
    }

    trimMessage(): void {
        this.message = this.message.trim();
    }

    sendMessage() {
        const trimmedMessage = this.message.trim();
        if (!trimmedMessage) return;
        this.chatService.sendUserMessage(this.message);
        this.message = '';
    }

    createChat() {
        if (this.isModalOpen) return;

        this.isModalOpen = true;

        const dialogRef = this.dialog.open(ChatCreationDialogComponent, {
            width: '270px',
            data: { chatName: '' },
        });

        dialogRef.afterClosed().subscribe((result) => {
            this.isModalOpen = false;
            if (result) {
                this.chatService.createChat(result);
            }
        });
    }

    async listChats() {
        if (this.isModalOpen) return;

        this.isModalOpen = true;
        const listOfChats = await this.chatService.joinableChats();

        const dialogRef = this.dialog.open(ChatJoinDialogComponent, {
            width: '270px',
            data: { chats: listOfChats },
        });

        dialogRef.afterClosed().subscribe((selectedChat) => {
            this.isModalOpen = false;
            if (selectedChat) {
                this.joinChat(selectedChat.chatId);
            }
        });
    }

    joinChat(chatId: string) {
        this.chatService.joinChat(chatId);
    }

    openChat(chatId: string) {
        this.chatService.openChat(chatId);
    }

    leaveChat(chatId: string) {
        this.chatService.leaveChat(chatId);
    }

    deleteChat(chatId: ChatId) {
        this.chatService.deleteChat(chatId);
        this.chatService.leaveDeletedChat(chatId);
    }
}
