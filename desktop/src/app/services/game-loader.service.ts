import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { ReceiveReplayDto } from '@common/replay.dto';
import { InGameEvent } from '@common/websocket/in-game.dto';
import { InstantiateGameDto, ObserverGameDto, WaitingGameDto, WaitingRoomEvent } from '@websocket/waiting-room.dto';
import { GameplayService } from './gameplay.service';
import { ReplayService } from './replay.service';
import { SocketIoService } from './socket.io.service';

@Injectable({
    providedIn: 'root',
})
export class GameLoaderService {
    constructor(
        private router: Router,
        private socketIoService: SocketIoService,
        private replayService: ReplayService,
    ) {}

    joinWaitingGame(waitingGameDto: WaitingGameDto): void {
        GameplayService.gameTemplateId = waitingGameDto.templateId;
        GameplayService.gameMode = waitingGameDto.gameMode;
        GameplayService.isObserver = false;
        GameplayService.usernameOverride = undefined;
        GameplayService.postInitCb = () =>
            this.socketIoService.emit(WaitingRoomEvent.JoinGame, {
                instanceId: waitingGameDto.instanceId,
            });
        this.router.navigate(['/game']);
    }

    joinObserverGame(waitingGameDto: ObserverGameDto): void {
        GameplayService.gameTemplateId = waitingGameDto.templateId;
        GameplayService.gameMode = waitingGameDto.gameMode;
        GameplayService.isObserver = true;
        GameplayService.usernameOverride = undefined;
        GameplayService.postInitCb = () =>
            this.socketIoService.emit(InGameEvent.JoinGameObserver, {
                instanceId: waitingGameDto.instanceId,
            });
        this.router.navigate(['/game']);
    }

    createGame(instantiateGameDto: InstantiateGameDto): void {
        GameplayService.gameTemplateId = instantiateGameDto.gameTemplateId;
        GameplayService.gameMode = instantiateGameDto.gameMode;
        GameplayService.isObserver = false;
        GameplayService.usernameOverride = undefined;
        GameplayService.postInitCb = () => this.socketIoService.emit(WaitingRoomEvent.InstantiateGame, instantiateGameDto);
        this.router.navigate(['/game']);
    }

    replayGame(replayDto: ReceiveReplayDto): void {
        GameplayService.gameTemplateId = replayDto.gameTemplateId;
        GameplayService.gameMode = replayDto.gameMode;
        GameplayService.isObserver = false;
        GameplayService.usernameOverride = replayDto.username;
        this.replayService.loadReplay(replayDto);
        GameplayService.postInitCb = () => undefined;
        this.router.navigate(['/game']);
    }
}
