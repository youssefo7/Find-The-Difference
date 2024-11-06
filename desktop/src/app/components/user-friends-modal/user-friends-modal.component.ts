import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialog, MatDialogRef } from '@angular/material/dialog';
import { MODAL_HEIGHT, MODAL_WIDTH } from '@app/constants/modal-size';
import { FriendsService } from '@app/services/friends.service';
import { UserService } from '@app/services/user.service';
import { Username } from '@common/ingame-ids.types';
import { UserDto } from '@common/user.dto';

@Component({
    selector: 'app-user-friends-modal',
    templateUrl: './user-friends-modal.component.html',
    styleUrl: './user-friends-modal.component.scss',
})
export class UserFriendsModalComponent implements OnInit {
    friendsList: Username[] = [];
    userDto: UserDto;
    // eslint-disable-next-line max-params
    constructor(
        @Inject(MAT_DIALOG_DATA) public data: { user: UserDto },
        private friendsService: FriendsService,
        private userService: UserService,
        public dialogRef: MatDialogRef<UserFriendsModalComponent>,
        public dialog: MatDialog,
    ) {
        this.userDto = data.user;
    }
    ngOnInit(): void {
        this.fetchAllFriends();
    }

    fetchAllFriends(): void {
        this.friendsService.findAllFriendsByUsername(this.data.user.username).subscribe((friends) => {
            this.friendsList = friends;
        });
    }

    openUserProfile(user: UserDto): void {
        this.dialog.open(UserFriendsModalComponent, {
            width: MODAL_WIDTH,
            height: MODAL_HEIGHT,
            data: { user },
        });
    }

    getUser(username: Username): UserDto {
        return this.userService.getUserByUsername(username);
    }
}
