import { Component, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MODAL_HEIGHT, MODAL_WIDTH } from '@app/constants/modal-size';
import { FriendsService } from '@app/services/friends.service';
import { UserService } from '@app/services/user.service';
import { Username } from '@common/ingame-ids.types';
import { UserDto } from '@common/user.dto';
import { UserFriendsModalComponent } from '@components/user-friends-modal/user-friends-modal.component';
import { UserSearchModalComponent } from '@components/user-search-modal/user-search-modal.component';
import { Observable } from 'rxjs';

@Component({
    selector: 'app-friend-list',
    templateUrl: './friend-list.component.html',
    styleUrl: './friend-list.component.scss',
})
export class FriendListComponent implements OnInit {
    isAuthProfile = true;

    constructor(
        private friendsService: FriendsService,
        private userService: UserService,
        public dialog: MatDialog,
    ) {}

    get friends$(): Observable<Username[]> {
        return this.friendsService.friendList$;
    }

    ngOnInit(): void {
        this.friendsService.fetchFriendList();
    }

    openSearchModal(): void {
        this.dialog.open(UserSearchModalComponent, {
            width: MODAL_WIDTH,
            height: MODAL_HEIGHT,
        });
    }

    getUser(username: Username): UserDto {
        return this.userService.getUserByUsername(username);
    }

    openUserProfile(user: UserDto): void {
        this.dialog.open(UserFriendsModalComponent, {
            width: MODAL_WIDTH,
            height: MODAL_HEIGHT,
            data: { user },
        });
    }
}
