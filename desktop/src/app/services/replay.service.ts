import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { FRAMES_PER_SECOND, POSSIBLE_REPLAY_SPEEDS } from '@app/constants/game-running';
import { MS_PER_SECOND } from '@common/constants';
import { ReceiveReplayDto, ReplayEvent, SendReplayDto } from '@common/replay.dto';
import { InGameEvent } from '@common/websocket/in-game.dto';
import { first } from 'rxjs';
import { environment } from 'src/environments/environment';
import { GameplayService } from './gameplay.service';
import { SocketIoService } from './socket.io.service';

@Injectable({
    providedIn: 'root',
})
export class ReplayService {
    isLoaded = false;
    isInReplayMode = false;
    isReplaying = false;

    private _currentReplaySpeed = POSSIBLE_REPLAY_SPEEDS[0];
    private lastPauseTimeStamp = 0;
    private currentEventIndex = 0;
    private events: ReplayEvent[] = [];
    private timestampLastReplayEvent: number = 0;
    private intervalId: ReturnType<typeof setInterval>;
    private readonly baseUrl: string = environment.serverUrl;

    constructor(
        private socketIoService: SocketIoService,
        private readonly http: HttpClient,
    ) {}

    get currentFraction(): number {
        return (this.previousEventTime - this.firstEventTime + this.timeSincePreviousEvent) / this.duration;
    }

    get currentReplaySpeed(): number {
        return this._currentReplaySpeed;
    }

    private get currentTime() {
        return this.isReplaying ? Date.now() : this.lastPauseTimeStamp;
    }

    private get timeSincePreviousEvent() {
        return (this.currentTime - this.timestampLastReplayEvent) * this.currentReplaySpeed;
    }

    private get firstEventTime() {
        return this.events[0]?.time || 0;
    }

    private get lastEventTime() {
        return this.events[this.events.length - 1]?.time || 0;
    }

    private get previousEventTime() {
        return this.events[this.currentEventIndex]?.time || 0;
    }

    private get duration() {
        return this.lastEventTime - this.firstEventTime;
    }

    // eslint-disable-next-line @typescript-eslint/adjacent-overload-signatures
    set currentReplaySpeed(newCurrentReplaySpeed: number) {
        this.timestampLastReplayEvent =
            (-(this.currentTime - this.timestampLastReplayEvent) * this.currentReplaySpeed) / newCurrentReplaySpeed + this.currentTime;
        this._currentReplaySpeed = newCurrentReplaySpeed;
    }

    // eslint-disable-next-line @typescript-eslint/adjacent-overload-signatures
    set currentFraction(fraction: number) {
        this.stopPlayback();
        this.socketIoService.fakeOn(this.events[0].name, this.events[0].data);
        this.currentEventIndex = 0;
        this.timestampLastReplayEvent = Date.now() - (this.duration * fraction) / this.currentReplaySpeed;
        this.repeat();
        this.lastPauseTimeStamp = Date.now();
    }

    async getReplays(): Promise<ReceiveReplayDto[]> {
        const url = `${this.baseUrl}/user/replays`;
        return new Promise((resolve) =>
            this.http
                .get<ReceiveReplayDto[]>(url)
                .pipe(first())
                .subscribe((data) => {
                    resolve(data);
                }),
        );
    }

    async uploadReplay(): Promise<void> {
        return new Promise((resolve) =>
            this.http
                .post<SendReplayDto>(`${this.baseUrl}/user/addReplay`, {
                    events: this.events,
                    gameMode: GameplayService.gameMode,
                    gameTemplateId: GameplayService.gameTemplateId,
                } as SendReplayDto)
                .pipe(first())
                .subscribe(() => resolve()),
        );
    }

    async deleteReplay(replayId: string): Promise<void> {
        return new Promise((resolve) => {
            this.http
                .delete(`${this.baseUrl}/user/deleteReplay/${replayId}`)
                .pipe(first())
                .subscribe(() => resolve());
        });
    }

    isAtEndOfReplay(): boolean {
        return this.currentEventIndex + 1 >= this.events.length || this.events[this.currentEventIndex + 1].name === InGameEvent.EndGame;
    }

    startPlayback(): void {
        if (this.isReplaying) return;
        GameplayService.muted = false;
        this.timestampLastReplayEvent += Date.now() - this.lastPauseTimeStamp;
        this.isReplaying = true;
        this.intervalId = setInterval(() => {
            this.repeat();
        }, MS_PER_SECOND / FRAMES_PER_SECOND);
    }

    stopPlayback(): void {
        if (!this.isReplaying) return;
        GameplayService.muted = true;
        this.isReplaying = false;
        this.lastPauseTimeStamp = Date.now();
        clearInterval(this.intervalId);
    }

    togglePlayback(): void {
        if (this.isReplaying) {
            this.stopPlayback();
        } else {
            this.startPlayback();
        }
    }

    setUp() {
        this.lastPauseTimeStamp = 0;
        this.isReplaying = false;
        if (!this.isInReplayMode) this.isLoaded = false;
        this.currentReplaySpeed = POSSIBLE_REPLAY_SPEEDS[0];
        this.currentEventIndex = 0;
        if (!this.isInReplayMode) this.events = [];
        this.timestampLastReplayEvent = 0;
        clearInterval(this.intervalId);

        this.listenAllInGameEvents();
    }

    loadReplay(replayDto: ReceiveReplayDto) {
        this.isInReplayMode = true;
        this.setUp();
        this.isLoaded = true;
        this.events = replayDto.events;
        this.currentFraction = 0;
    }

    removeAllInGameListeners() {
        GameplayService.muted = false;
        clearInterval(this.intervalId);
        Object.values(InGameEvent).forEach((event) => {
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            this.socketIoService.removeListener(event as any);
        });
    }

    setInterval(callback: () => void, timeMs: number): ReturnType<typeof setInterval> {
        return setInterval(() => {
            if (!this.isInReplayMode || this.isReplaying) {
                callback();
            }
        }, timeMs / this.currentReplaySpeed);
    }

    setTimeout(callback: () => void, timeMs: number): ReturnType<typeof setTimeout> {
        return setTimeout(callback, timeMs / this.currentReplaySpeed);
    }

    private saveReceivedEvent(eventName: string, data: unknown): void {
        if (this.isInReplayMode || eventName === InGameEvent.CheatModeEvent) {
            return;
        }
        this.events.push({ name: eventName, time: Date.now(), data });
    }

    private listenAllInGameEvents() {
        Object.values(InGameEvent).forEach((event) => {
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            this.socketIoService.on(event as any, (data) => {
                this.saveReceivedEvent(event, data);
            });
        });
    }

    private repeat(): void {
        const event = this.events[this.currentEventIndex + 1];

        if (!event || event.name === InGameEvent.EndGame) {
            this.stopPlayback();
            return;
        }

        const timeToNextEvent = event.time - this.previousEventTime;

        if (this.timeSincePreviousEvent < timeToNextEvent) {
            return;
        }

        this.socketIoService.fakeOn(event.name, event.data);
        this.timestampLastReplayEvent += timeToNextEvent / this.currentReplaySpeed;

        this.currentEventIndex++;
        this.repeat();
    }
}
