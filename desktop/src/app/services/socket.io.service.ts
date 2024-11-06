import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { ClientToServerEventsMap, ServerToClientEventsMap } from '@websocket/all-events.dto';
import { Socket, io } from 'socket.io-client';
import { environment } from 'src/environments/environment';
import { AuthService } from './auth.service';

@Injectable({
    providedIn: 'root',
})
export class SocketIoService {
    private connectCallbacks: (() => unknown)[] = [async () => this.router.navigate(['home'])];
    private socket: Socket;

    constructor(
        private router: Router,
        private authService: AuthService,
    ) {
        this.connect();
    }

    get isInitialized() {
        return Boolean(this.socket) && this.socket.connected;
    }

    onConnect(callback: () => void): void {
        this.connectCallbacks.push(callback);
    }

    async connect(): Promise<void> {
        await this.authService.refreshToken();
        const jwt = this.authService.getJwt();

        if (!jwt) {
            this.toLoginPage();
            return;
        }
        if (this.isInitialized) {
            return;
        }
        // eslint-disable-next-line @typescript-eslint/naming-convention
        this.socket = io(environment.wsUrl, { reconnection: false, extraHeaders: { Authorization: `Bearer ${jwt}` } });
        this.socket.on('connect', () => this.connectCallbacks.forEach((cb) => cb()));
        this.onDisconnect(() => this.toLoginPage());
        this.listenOnException();
        return;
    }

    disconnect(): void {
        if (this.socket !== undefined) {
            this.socket.disconnect();
        }
        this.authService.logOut();
    }

    removeListener<K extends keyof ServerToClientEventsMap>(eventName: K) {
        if (this.isInitialized) this.socket.removeListener(eventName);
    }

    on<K extends keyof ServerToClientEventsMap>(eventName: K, callback: (data: ServerToClientEventsMap[K]) => void): void {
        if (this.isInitialized) this.socket.on(eventName as string, callback);
    }

    emit<K extends keyof ClientToServerEventsMap>(eventName: K, dto: ClientToServerEventsMap[K]): void {
        if (this.isInitialized) this.socket.emit(eventName, dto);
    }

    onDisconnect(callback: () => void): void {
        this.socket.on('disconnect', callback);
    }

    fakeOn(eventName: string, data: unknown): void {
        const callbacks = this.socket.listeners(eventName);
        for (const callback of callbacks) {
            callback(data);
        }
    }

    private toLoginPage() {
        this.router.navigate(['login']);
    }

    private listenOnException(): void {
        this.socket.on('exception', (err) => {
            // eslint-disable-next-line no-console -- nécessaire pour afficher les exceptions
            console.error(err);
        });
    }
}
