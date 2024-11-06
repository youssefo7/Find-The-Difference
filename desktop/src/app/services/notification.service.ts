import { Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { UsernameDto } from '@common/websocket/all-events.dto';
import { FriendsEvent } from '@common/websocket/friends.dto';
import { AuthService } from './auth.service';
import { SocketIoService } from './socket.io.service';

interface SnackBarMessage {
    text: string;
}

@Injectable({
    providedIn: 'root',
})
export class NotificationService {
    private messageQueue: SnackBarMessage[] = [];
    private isDisplaying = false;

    // eslint-disable-next-line max-params
    constructor(
        private snackBar: MatSnackBar,
        private router: Router,
        private socketIoService: SocketIoService,
        private authService: AuthService,
    ) {}

    initialize() {
        this.socketIoService.onConnect(() => this.listenForFriendUpdates());
    }

    enqueueSnackBar(text: string): void {
        this.messageQueue.push({ text });
        this.displayNext();
    }

    listenForFriendUpdates(): void {
        this.socketIoService.on(FriendsEvent.NotifyNewFriend, (data: UsernameDto) => {
            this.enqueueSnackBar($localize`${data.username} is now your friend!`);
        });

        this.socketIoService.on(FriendsEvent.NotifyFriendRemoved, (data: UsernameDto) => {
            this.enqueueSnackBar($localize`${data.username} is no longer your friend.`);
        });

        this.socketIoService.on(FriendsEvent.NotifyNewFriendRequest, (data: UsernameDto) => {
            this.enqueueSnackBar($localize`${data.username} sent you a friend request!`);
        });

        this.socketIoService.on(FriendsEvent.NotifyFriendRequestRefused, (data: UsernameDto) => {
            this.enqueueSnackBar($localize`${data.username} rejected your friend request.`);
        });
    }
    private displayNext(): void {
        if (this.isDisplaying || this.messageQueue.length === 0) {
            return;
        }
        this.isDisplaying = true;
        const message = this.messageQueue.shift() || { text: '' };

        const isProfilePage = this.router.url.includes(`/profile/${this.authService.getUsername()}`);

        const actionLabel = isProfilePage ? undefined : $localize`See my profile`;

        const snackBarRef = this.snackBar.open(message.text, actionLabel, {
            horizontalPosition: 'right',
            verticalPosition: 'bottom',
        });

        if (!isProfilePage) {
            snackBarRef.onAction().subscribe(() => {
                this.isDisplaying = false;
                this.messageQueue = [];
                const username = this.authService.getUsername();
                this.router.navigate(['/profile', username]);
                snackBarRef.dismiss();
            });
        }

        snackBarRef.afterDismissed().subscribe(() => {
            this.isDisplaying = false;
            this.displayNext();
        });
    }
}
