import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { MONEY_GAIN_PATH, MONEY_LOST_PATH } from '@app/constants/game-running';
import { HttpError } from '@app/interfaces/http-error';
import { NB_DEFAULT_AVATARS } from '@common/constants';
import { Username } from '@common/ingame-ids.types';
import { UserDto } from '@common/user.dto';
import { MarketEvent } from '@common/websocket/market.dto';
import { FriendsEvent } from '@websocket/friends.dto';
import { BehaviorSubject, Observable, catchError, first, map, startWith, tap } from 'rxjs';
import { environment } from 'src/environments/environment';
import { AuthService } from './auth.service';
import { SocketIoService } from './socket.io.service';

@Injectable({
    providedIn: 'root',
})
export class UserService {
    allUsers$: Observable<UserDto[]>;
    userBalance: number;

    private s3BucketUrl: string = environment.s3BucketUrl;
    private readonly serverUrl: string = environment.serverUrl;
    private allUsersSubject = new BehaviorSubject<UserDto[]>([]);

    private profileSubject = new BehaviorSubject<UserDto | undefined>(undefined);

    constructor(
        private http: HttpClient,
        private authService: AuthService,
        private socketIoService: SocketIoService,
    ) {
        this.allUsers$ = this.allUsersSubject.asObservable();
        this.socketIoService.onConnect(() => {
            this.getUserBalance();
        });
    }

    initialize() {
        this.socketIoService.onConnect(() => {
            this.listenForUserUpdates();
        });
    }

    listenForUserUpdates() {
        this.socketIoService.on(FriendsEvent.NotifyNewUser, () => {
            this.fetchAllUsers();
            this.updateProfile();
        });
        this.socketIoService.on(MarketEvent.UpdateBalance, (balance) => {
            const audio = this.userBalance < balance.balance ? new Audio(MONEY_GAIN_PATH) : new Audio(MONEY_LOST_PATH);
            this.userBalance = balance.balance;
            audio.volume = 0.1;
            audio.play();
            this.updateProfile();
        });
    }

    getDefaultAvatarUrls(): string[] {
        const avatarUrls: string[] = [];
        for (let i = 1; i <= NB_DEFAULT_AVATARS; i++) {
            avatarUrls.push(`${this.s3BucketUrl}/avatars/image${i}.png`);
        }
        return avatarUrls;
    }

    getUserByUsername(username: Username): UserDto {
        const foundUser = this.allUsersSubject.value.find((user) => user.username === username);
        if (!foundUser) {
            throw new Error(`User with username ${username} not found.`);
        }
        return foundUser;
    }

    getUserBalance(): void {
        const url = `${this.serverUrl}/user/balance`;

        this.http.get<number>(url).subscribe((balance) => {
            this.userBalance = balance;
        });
    }

    changeAvatar(newAvatarUrl: string): Observable<unknown> {
        const url = `${this.serverUrl}/user/change-avatar`;
        return this.http.patch(url, { avatarUrl: newAvatarUrl }).pipe(tap(() => this.updateProfile()));
    }

    async changeUsername(newUsername: Username): Promise<void | HttpError> {
        const url = `${this.serverUrl}/user/username`;
        return new Promise<void | HttpError>((resolve) => {
            this.http
                .patch<undefined>(url, { username: newUsername })
                .pipe(
                    first(),
                    catchError(async (err) => resolve(err as HttpError)),
                )
                .subscribe(() => resolve());
        });
    }

    getProfile(): Observable<UserDto | undefined> {
        this.getUserBalance();
        this.updateProfile();
        return this.profileSubject.asObservable().pipe(startWith(this.profileSubject.value));
    }

    fetchAllUsers(): void {
        this.http.get<UserDto[]>(`${this.serverUrl}/user/`).subscribe((users) => {
            const selfUsername = this.authService.getUsername();
            const configuredUsers = users.map((user) => {
                return {
                    ...user,
                    avatarUrl: this.configureAvatarUrl(user.avatarUrl),
                };
            });

            const selfUser = configuredUsers.find((user) => user.username === selfUsername);

            if (selfUser) {
                const otherUsers = configuredUsers.filter((user) => user.username !== selfUsername);
                this.allUsersSubject.next([selfUser, ...otherUsers]);
            } else {
                this.allUsersSubject.next(configuredUsers);
            }
        });
    }

    configureAvatarUrl(avatarUrl: string): string {
        if (avatarUrl && !avatarUrl.startsWith(environment.s3BucketUrl)) {
            return environment.s3BucketUrl + '/' + avatarUrl;
        }
        return avatarUrl;
    }

    async resizeAndConvertToBase64(file: File) {
        return new Promise((resolve, reject) => {
            const img = new Image();
            img.src = URL.createObjectURL(file);
            img.onload = () => {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');

                canvas.width = 128;
                canvas.height = 128;

                ctx?.drawImage(img, 0, 0, canvas.width, canvas.height);

                const resizedBase64 = canvas.toDataURL(file.type);
                resolve(resizedBase64);

                URL.revokeObjectURL(img.src);
            };
            img.onerror = (error) => {
                reject(error);
            };
        });
    }

    private updateProfile(): void {
        const url = `${this.serverUrl}/user/profile`;
        this.http
            .get<UserDto>(url)
            .pipe(
                map((profile: UserDto) => {
                    if (profile && profile.avatarUrl) {
                        profile.avatarUrl = environment.s3BucketUrl + '/' + profile.avatarUrl;
                    }
                    return profile;
                }),
            )
            .subscribe((profile) => this.profileSubject.next(profile));
    }
}
