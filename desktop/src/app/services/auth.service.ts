import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { HttpError } from '@app/interfaces/http-error';
import { JwtPayloadDto, JwtTokenDto } from '@common/auth.dto';
import { MS_PER_SECOND } from '@common/constants';
import { UserDto } from '@common/user.dto';
import { Observable, catchError, first } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable({
    providedIn: 'root',
})
export class AuthService {
    private readonly baseUrl: string = environment.serverUrl;
    private tempJwt?: string; // do not use outside get/set unsafeJWT
    constructor(private readonly http: HttpClient) {}

    private get unsafeJWT() {
        if (this.tempJwt) return this.tempJwt;
        return localStorage.getItem('jwt') || undefined;
    }

    private set unsafeJWT(jwt: undefined | string) {
        if (this.tempJwt) {
            // If in a temporary session: don't change localStorage
            this.tempJwt = jwt;
            return;
        }
        if (jwt === undefined) {
            // if undefined: logout
            localStorage.removeItem('jwt');
            return;
        }
        const localStorageJwt = localStorage.getItem('jwt');
        if (!localStorageJwt) {
            // if not in temporary session and empty localStorage: login permanent session in localStorage
            localStorage.setItem('jwt', jwt);
            return;
        }
        if (this.parseJwt(localStorageJwt)?.sub === this.parseJwt(jwt)?.sub) {
            // if not in temporary session and user is the same as permanent session: refresh jwt of permanent session
            localStorage.setItem('jwt', jwt);
            return;
        }
        // if localStorage not empty and connecting with another user: start/update temporary session
        this.tempJwt = jwt;
    }

    // eslint-disable-next-line max-params
    login(username: string, password: string, successCallback: () => void, handleError: (err: HttpError) => Observable<never>): void {
        const url = `${this.baseUrl}/auth/login`;
        this.http
            .post<JwtTokenDto>(url, { username, password })
            .pipe(first(), catchError(handleError))
            .subscribe((data) => {
                this.unsafeJWT = data.accessToken;
                successCallback();
            });
    }

    register(user: UserDto & { password: string }, successCallback: () => void, handleError: (err: HttpError) => Observable<never>): void {
        const url = `${this.baseUrl}/auth/register`;
        this.http
            .post<JwtTokenDto>(url, user)
            .pipe(first(), catchError(handleError))
            .subscribe((data) => {
                this.unsafeJWT = data.accessToken;
                successCallback();
            });
    }

    logOut(): void {
        this.unsafeJWT = undefined;
    }

    getJwt() {
        const exp = this.parseJwt()?.exp;
        if (exp && exp * MS_PER_SECOND > Date.now()) {
            return this.unsafeJWT;
        }
        this.logOut();
    }

    getUsername() {
        return this.parseJwt()?.sub || '';
    }

    async refreshToken(): Promise<void> {
        const jwt = localStorage.getItem('jwt');
        if (!jwt) return;
        const url = `${this.baseUrl}/auth/refresh-jwt`;
        // eslint-disable-next-line @typescript-eslint/naming-convention
        const headers = { Authorization: `Bearer ${jwt}` };
        return new Promise((resolve) => {
            this.http
                .get<JwtTokenDto>(url, { headers })
                .pipe(first())
                .subscribe({
                    next: (data) => {
                        this.unsafeJWT = data.accessToken;
                        resolve();
                    },
                    error: () => {
                        this.logOut();
                        resolve();
                    },
                });
        });
    }

    private parseJwt(overrideJwt?: string): JwtPayloadDto | undefined {
        const jwt = overrideJwt || this.unsafeJWT;
        if (!jwt) return undefined;
        return JSON.parse(atob(jwt.split('.')[1]));
    }
}
