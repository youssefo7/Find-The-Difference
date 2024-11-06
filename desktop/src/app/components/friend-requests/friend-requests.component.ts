import { Component, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MODAL_HEIGHT, MODAL_WIDTH } from '@app/constants/modal-size';
import { FriendsService } from '@app/services/friends.service';
import { UserService } from '@app/services/user.service';
import { Username } from '@common/ingame-ids.types';
import { UserDto } from '@common/user.dto';
import { UserFriendsModalComponent } from '@components/user-friends-modal/user-friends-modal.component';
import { Observable } from 'rxjs';

@Component({
    selector: 'app-friend-requests',
    templateUrl: './friend-requests.component.html',
    styleUrl: './friend-requests.component.scss',
})
export class FriendRequestsComponent implements OnInit {
    constructor(
        private friendsService: FriendsService,
        private userService: UserService,
        public dialog: MatDialog,
    ) {}

    get incomingFriendRequests$(): Observable<Username[]> {
        return this.friendsService.incomingRequestList$;
    }

    ngOnInit(): void {
        this.friendsService.fetchIncomingFriendRequests();
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
