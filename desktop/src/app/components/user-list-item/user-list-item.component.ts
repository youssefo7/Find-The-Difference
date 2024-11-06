import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { FriendsService } from '@app/services/friends.service';
import { UserDto } from '@common/user.dto';
import { AuthService } from '@services/auth.service';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-user-list-item',
    templateUrl: './user-list-item.component.html',
    styleUrls: ['./user-list-item.component.scss'],
})
export class UserListItemComponent implements OnInit {
    @Input() user: UserDto;
    @Output() openProfile = new EventEmitter<UserDto>();

    isFriend: boolean = false;
    isOutgoingRequestPending: boolean = false;
    isIncomingRequestPending: boolean = false;

    private subs = new Subscription();

    constructor(
        private friendsService: FriendsService,
        private authService: AuthService,
    ) {}

    get isCurrentUser(): boolean {
        return this.authService.getUsername() === this.user.username;
    }
    ngOnInit(): void {
        this.subs.add(this.friendsService.isFriend(this.user.username).subscribe((status) => (this.isFriend = status)));
        this.subs.add(
            this.friendsService.isOutgoingRequestPending(this.user.username).subscribe((status) => (this.isOutgoingRequestPending = status)),
        );
        this.subs.add(
            this.friendsService.isIncomingRequestPending(this.user.username).subscribe((status) => (this.isIncomingRequestPending = status)),
        );
    }

    addFriend() {
        this.friendsService.addFriend(this.user.username);
    }

    removeFriend() {
        this.friendsService.removeFriend(this.user.username);
    }

    acceptFriendRequest() {
        this.friendsService.acceptFriendRequest(this.user.username);
    }

    declineFriendRequest() {
        this.friendsService.declineFriendRequest(this.user.username);
    }

    onOpenProfile(): void {
        if (this.isCurrentUser) return;
        this.openProfile.emit(this.user);
    }
}
