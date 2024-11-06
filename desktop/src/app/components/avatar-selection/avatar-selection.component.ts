import { CommonModule } from '@angular/common';
import { Component, ElementRef, EventEmitter, Inject, OnInit, Optional, Output, ViewChild } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { UserService } from '@app/services/user.service';
import { INITIAL_DEFAULT_AVATAR } from '@common/constants';

@Component({
    selector: 'app-avatar-selection',
    templateUrl: './avatar-selection.component.html',
    styleUrl: './avatar-selection.component.scss',
    imports: [CommonModule, MatCardModule, MatButtonModule, MatDialogModule],
    standalone: true,
})
export class AvatarSelectionComponent implements OnInit {
    @Output() avatarChanged = new EventEmitter<string>();
    @ViewChild('avatarInput') avatarInput!: ElementRef;

    isEditing: boolean = false;
    currentAvatarUrl: string | null = null;

    selectedAvatarUrl: string | null = INITIAL_DEFAULT_AVATAR;
    predefinedAvatars: string[];
    errorMessage = '';
    selectedAvatarFile: File;

    // eslint-disable-next-line max-params
    constructor(
        @Optional() @Inject(MAT_DIALOG_DATA) public data: { isEditing: boolean; currentAvatar: string },
        @Optional() private dialogRef: MatDialogRef<AvatarSelectionComponent>,
        private userService: UserService,
        private snackBar: MatSnackBar,
    ) {}

    ngOnInit(): void {
        this.predefinedAvatars = this.userService.getDefaultAvatarUrls();
        this.selectedAvatarUrl = INITIAL_DEFAULT_AVATAR;
        this.avatarChanged.emit(this.selectedAvatarUrl);
        if (this.data) {
            this.isEditing = true;
            this.currentAvatarUrl = this.data.currentAvatar;
        } else {
            this.isEditing = false;
        }
    }

    selectAvatar(avatarSrc: string): void {
        this.selectedAvatarUrl = avatarSrc;
        this.avatarChanged.emit(avatarSrc);
    }

    saveAvatar(): void {
        if (!this.selectedAvatarUrl) {
            return;
        }

        if (this.selectedAvatarUrl === this.currentAvatarUrl) {
            this.dialogRef.close();
            this.snackBar.open($localize`Avatar is unchanged.`, $localize`Close`, {
                duration: 3000,
            });
            return;
        }

        this.userService.changeAvatar(this.selectedAvatarUrl).subscribe({
            next: () => {
                this.snackBar.open($localize`Avatar has been successfully updated.`, $localize`Close`, {
                    duration: 3000,
                });
                this.dialogRef.close();
            },
            error: () => {
                this.snackBar.open($localize`Failed to update the avatar.`, $localize`Close`, {
                    duration: 3000,
                });
            },
        });
    }

    async getAvatarUrl(): Promise<string> {
        if (this.selectedAvatarFile) {
            return (await this.userService.resizeAndConvertToBase64(this.selectedAvatarFile)) as string;
        } else if (this.selectedAvatarUrl) {
            return this.selectedAvatarUrl;
        } else {
            return INITIAL_DEFAULT_AVATAR;
        }
    }

    uploadAvatar(event: MouseEvent): void {
        event.stopPropagation();
        this.avatarInput.nativeElement.click();
    }

    onAvatarSelected(event: Event): void {
        event.stopPropagation();
        const file = (event.target as HTMLInputElement).files?.[0];
        if (!file) {
            return;
        }

        if (file.type !== 'image/png') {
            this.errorMessage = $localize`Only PNG files are accepted. Please select a PNG file.`;
            this.selectedAvatarUrl = null;
            return;
        }

        this.errorMessage = '';
        this.selectedAvatarFile = file;
        this.selectedAvatarUrl = null;
        const reader = new FileReader();
        reader.onload = (e) => {
            this.selectedAvatarUrl = (e.target?.result as string) ?? null;
            this.avatarChanged.emit(this.selectedAvatarUrl as string);
        };
        reader.readAsDataURL(file);
    }
}
