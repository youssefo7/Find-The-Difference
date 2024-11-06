import { Component } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { AvatarSelectionComponent } from '@app/components/avatar-selection/avatar-selection.component';
import { UserService } from '@app/services/user.service';
import { UserDto } from '@common/user.dto';
import { Observable } from 'rxjs';

@Component({
    selector: 'app-profile-card',
    templateUrl: './profile-card.component.html',
    styleUrl: './profile-card.component.scss',
})
export class ProfileCardComponent {
    profile$: Observable<UserDto | undefined> = this.userService.getProfile();
    isEditing = false;

    constructor(
        public dialog: MatDialog,
        private userService: UserService,
    ) {}

    openAvatarSelection(profile: UserDto): void {
        const dialogRef = this.dialog.open(AvatarSelectionComponent, {
            width: '300px',
            data: { currentAvatar: profile?.avatarUrl, isEditing: true },
        });
        dialogRef.afterClosed().subscribe();
    }
}
