import { Component, OnDestroy, OnInit } from '@angular/core';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { MODAL_HEIGHT, MODAL_WIDTH } from '@app/constants/modal-size';
import { FriendsService } from '@app/services/friends.service';
import { UserService } from '@app/services/user.service';
import { UserDto } from '@common/user.dto';
import { UserFriendsModalComponent } from '@components/user-friends-modal/user-friends-modal.component';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-user-search-modal',
    templateUrl: './user-search-modal.component.html',
    styleUrl: './user-search-modal.component.scss',
})
export class UserSearchModalComponent implements OnInit, OnDestroy {
    searchQuery: string = '';
    subscriptions: Subscription = new Subscription();

    allUsers: UserDto[];

    // eslint-disable-next-line max-params
    constructor(
        private friendsService: FriendsService,
        private userService: UserService,

        public dialogRef: MatDialogRef<UserSearchModalComponent>,
        public dialog: MatDialog,
    ) {}

    get filteredUsers(): UserDto[] {
        if (!this.searchQuery) {
            return this.allUsers;
        }
        return this.allUsers.filter((user) => user.username.toLowerCase().includes(this.searchQuery.toLowerCase()));
    }

    ngOnInit(): void {
        this.subscriptions.add(this.userService.allUsers$.subscribe((users) => (this.allUsers = users)));

        this.userService.fetchAllUsers();
        this.friendsService.fetchOutgoingFriendRequests();
    }

    openUserProfile(user: UserDto): void {
        this.dialog.open(UserFriendsModalComponent, {
            width: MODAL_WIDTH,
            height: MODAL_HEIGHT,
            data: { user },
        });
    }

    ngOnDestroy(): void {
        this.subscriptions.unsubscribe();
    }
}
