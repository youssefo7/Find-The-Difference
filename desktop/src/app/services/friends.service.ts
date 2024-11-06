import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Username } from '@common/ingame-ids.types';
import { FriendsEvent } from '@common/websocket/friends.dto';
import { BehaviorSubject, Observable, map } from 'rxjs';
import { environment } from 'src/environments/environment';
import { AuthService } from './auth.service';
import { SocketIoService } from './socket.io.service';

@Injectable({
    providedIn: 'root',
})
export class FriendsService {
    friendList$: Observable<Username[]>;
    outgoingRequestList$: Observable<Username[]>;
    incomingRequestList$: Observable<Username[]>;

    private friendListSubject = new BehaviorSubject<Username[]>([]);
    private outgoingRequestListSubject = new BehaviorSubject<Username[]>([]);
    private incomingRequestListSubject = new BehaviorSubject<Username[]>([]);

    private readonly baseUrl: string = environment.serverUrl;

    constructor(
        private readonly http: HttpClient,
        private socketIoService: SocketIoService,
        private authService: AuthService,
    ) {
        this.friendList$ = this.friendListSubject.asObservable();
        this.outgoingRequestList$ = this.outgoingRequestListSubject.asObservable();
        this.incomingRequestList$ = this.incomingRequestListSubject.asObservable();
    }

    sortUserList(users: Username[]): Username[] {
        const selfUsername = this.authService.getUsername();
        const selfUser = users.find((user) => user === selfUsername);

        if (selfUser) {
            const otherUsers = users.filter((user) => user !== selfUsername);
            return [selfUser, ...otherUsers];
        } else {
            return users;
        }
    }

    fetchFriendList(): void {
        this.http.get<Username[]>(`${this.baseUrl}/friends/friend-list/`).subscribe((friends) => {
            this.friendListSubject.next(friends);
        });
    }

    fetchOutgoingFriendRequests(): void {
        this.http.get<Username[]>(`${this.baseUrl}/friends/outgoing-request-list/`).subscribe((requests) => {
            this.outgoingRequestListSubject.next(requests);
        });
    }

    fetchIncomingFriendRequests(): void {
        this.http.get<Username[]>(`${this.baseUrl}/friends/incoming-request-list/`).subscribe((requests) => {
            this.incomingRequestListSubject.next(requests);
        });
    }

    findAllFriendsByUsername(username: Username): Observable<Username[]> {
        return this.http.get<Username[]>(`${this.baseUrl}/friends/friend-list/${username}`).pipe(map((friends) => this.sortUserList(friends)));
    }

    addFriend(username: Username) {
        this.socketIoService.emit(FriendsEvent.RequestOrAcceptFriend, { username });
        this.addUserToOutgoingRequestList(username);
    }

    removeFriend(username: Username) {
        this.socketIoService.emit(FriendsEvent.RefuseOrRemoveFriend, { username });
        this.removeUserFromFriendList(username);
    }

    isFriend(username: Username): Observable<boolean> {
        return this.friendList$.pipe(map((friends) => friends.includes(username)));
    }

    isOutgoingRequestPending(username: Username): Observable<boolean> {
        return this.outgoingRequestList$.pipe(map((reqs) => reqs.includes(username)));
    }

    isIncomingRequestPending(username: Username): Observable<boolean> {
        return this.incomingRequestList$.pipe(map((reqs) => reqs.includes(username)));
    }

    declineFriendRequest(username: Username) {
        this.socketIoService.emit(FriendsEvent.RefuseOrRemoveFriend, { username });
        this.removeUserFromIncomingRequestList(username);
    }
    acceptFriendRequest(username: Username) {
        this.socketIoService.emit(FriendsEvent.RequestOrAcceptFriend, { username });
        this.addUserToFriendList(username);
        this.removeUserFromIncomingRequestList(username);
    }

    addUserToFriendList(username: Username): void {
        const currentFriends = this.friendListSubject.value;
        if (!currentFriends.includes(username)) {
            this.friendListSubject.next([...currentFriends, username]);
        }
    }

    removeUserFromFriendList(username: Username): void {
        const updatedFriends = this.friendListSubject.value.filter((user) => user !== username);
        this.friendListSubject.next(updatedFriends);
    }

    addUserToOutgoingRequestList(username: Username): void {
        const currentRequests = this.outgoingRequestListSubject.value;
        if (!currentRequests.includes(username)) {
            this.outgoingRequestListSubject.next([...currentRequests, username]);
        }
    }

    addUserToIncomingRequestList(username: Username): void {
        const currentRequests = this.incomingRequestListSubject.value;
        if (!currentRequests.includes(username)) {
            this.incomingRequestListSubject.next([...currentRequests, username]);
        }
    }

    removeUserFromIncomingRequestList(username: Username): void {
        const updatedRequests = this.incomingRequestListSubject.value.filter((user) => user !== username);
        this.incomingRequestListSubject.next(updatedRequests);
    }
    removeUserFromOutgoingRequestList(username: Username): void {
        const updatedRequests = this.outgoingRequestListSubject.value.filter((user) => user !== username);
        this.outgoingRequestListSubject.next(updatedRequests);
    }

    initialize() {
        this.socketIoService.onConnect(() => {
            this.reset();
            this.listenForFriendUpdates();
        });
    }

    reset() {
        this.friendListSubject.next([]);
        this.outgoingRequestListSubject.next([]);
        this.incomingRequestListSubject.next([]);
    }

    private listenForFriendUpdates(): void {
        this.socketIoService.on(FriendsEvent.NotifyNewFriend, () => {
            this.fetchFriendList();
            this.fetchOutgoingFriendRequests();
        });
        this.socketIoService.on(FriendsEvent.NotifyFriendRemoved, () => {
            this.fetchFriendList();
        });
        this.socketIoService.on(FriendsEvent.NotifyNewFriendRequest, () => {
            this.fetchIncomingFriendRequests();
        });
        this.socketIoService.on(FriendsEvent.NotifyFriendRequestRefused, () => {
            this.fetchOutgoingFriendRequests();
        });
    }
}
