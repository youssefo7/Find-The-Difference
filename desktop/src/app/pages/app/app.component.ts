import { Component } from '@angular/core';
import { ChatService } from '@app/services/chat.service';
import { FriendsService } from '@app/services/friends.service';
import { NotificationService } from '@app/services/notification.service';
import { UserService } from '@app/services/user.service';

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent {
    // eslint-disable-next-line max-params
    constructor(
        private notificationService: NotificationService,
        private chatService: ChatService,
        private userService: UserService,
        private friendsService: FriendsService,
    ) {
        this.userService.initialize();
        this.notificationService.initialize();
        this.chatService.initialize();
        this.friendsService.initialize();
    }
}
