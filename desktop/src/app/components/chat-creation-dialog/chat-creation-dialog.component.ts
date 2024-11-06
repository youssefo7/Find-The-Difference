import { Component, Inject } from '@angular/core';
import { AbstractControl, FormControl, ValidationErrors, ValidatorFn, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MAX_CHAT_NAME_LENGTH } from '@common/constants';

@Component({
    selector: 'app-chat-creation-dialog',
    templateUrl: './chat-creation-dialog.component.html',
})
export class ChatCreationDialogComponent {
    chatNameControl = new FormControl(this.data.chatName, [Validators.required, Validators.maxLength(MAX_CHAT_NAME_LENGTH), this.customValidator]);

    constructor(@Inject(MAT_DIALOG_DATA) private readonly data: { chatName: string }) {}

    get maxChatNameLength(): number {
        return MAX_CHAT_NAME_LENGTH;
    }

    get isEmptyChatName(): boolean {
        return this.data.chatName.trim() === '';
    }

    get customValidator(): ValidatorFn {
        return (control: AbstractControl): ValidationErrors | null => {
            if (control.value.trim() === '') {
                return { required: true };
            }
            return null;
        };
    }

    get chatName(): string {
        return this.chatNameControl.value ?? '';
    }

    get chatNameLength(): number {
        return this.chatName.length;
    }
}
