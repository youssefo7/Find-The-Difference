import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Chat } from '@common/websocket/chat.dto';

@Component({
    selector: 'app-chat-join-dialog',
    templateUrl: './chat-join-dialog.component.html',
})
export class ChatJoinDialogComponent {
    searchTerm: string = '';
    filteredChats: Chat[];

    constructor(
        public dialogRef: MatDialogRef<ChatJoinDialogComponent>,
        @Inject(MAT_DIALOG_DATA) public data: { chats: Chat[] },
    ) {
        this.filteredChats = data.chats;
    }

    selectChat(chat: Chat) {
        this.dialogRef.close(chat);
    }

    filterChats() {
        if (!this.searchTerm) {
            this.filteredChats = this.data.chats;
        } else {
            this.filteredChats = this.data.chats.filter((chat) => chat.name.toLowerCase().includes(this.searchTerm.toLowerCase()));
        }
    }
}
