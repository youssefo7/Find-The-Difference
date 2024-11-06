import { Injectable } from '@angular/core';
import { ObserverDrawHintComponent } from '@app/components/observer-draw-hint/observer-draw-hint.component';
import { HINT_WIDTH, RECT_POSITION_OFFSET, RECT_SIZE_OFFSET } from '@app/constants/game-running';
import { HintContext } from '@app/interfaces/hint-context';
import { HINT_COOLDOWN_TIME_MS, HINT_PRICE, SERVER_USERNAME } from '@common/constants';
import { Vec2 } from '@common/game-template';
import { Username } from '@common/ingame-ids.types';
import { MarketEvent } from '@common/websocket/market.dto';
import { InGameEvent, ReceiveHintDto, SendHintDto } from '@websocket/in-game.dto';
import { ReplayService } from './replay.service';
import { SocketIoService } from './socket.io.service';
import { UserService } from './user.service';

@Injectable({
    providedIn: 'root',
})
export class HintService {
    private buyCooldown = false;
    private hintContexts: HintContext[];

    constructor(
        private socketIoService: SocketIoService,
        private replayService: ReplayService,
        private userService: UserService,
    ) {}

    get buyDisabled() {
        return this.buyCooldown || this.userService.userBalance < HINT_PRICE;
    }

    connect(hintContexts: HintContext[]): void {
        this.hintContexts = hintContexts;
    }

    addContext(hintContext: HintContext) {
        this.hintContexts.push(hintContext);
    }

    removeContext(username: Username) {
        this.hintContexts = this.hintContexts.filter((hintContext) => hintContext.observer !== username);
    }

    removeListener() {
        this.socketIoService.removeListener(InGameEvent.ReceiveHint);
    }

    initSocket(): void {
        this.listenOnReceiveHint();
    }

    giveHint(hint: SendHintDto): void {
        this.socketIoService.emit(InGameEvent.SendHint, hint);
        ObserverDrawHintComponent.resetCanvas();
    }

    buyHint(): void {
        this.socketIoService.emit(MarketEvent.BuyHint, undefined);
        this.buyCooldown = true;
        this.replayService.setTimeout(() => {
            this.buyCooldown = false;
        }, HINT_COOLDOWN_TIME_MS);
    }

    private listenOnReceiveHint(): void {
        this.socketIoService.on(InGameEvent.ReceiveHint, (hintDto: ReceiveHintDto) => {
            this.showHint(hintDto);
        });
    }

    private showHint(hintDto: ReceiveHintDto): void {
        const { rect, sender } = hintDto;
        const contexts = this.hintContexts.filter((hintContext) => hintContext.observer === sender);
        if (contexts.length !== 2) return;
        this.rectangleHint(contexts[0].canvas.getContext(), rect, sender);
        this.rectangleHint(contexts[1].canvas.getContext(), rect, sender);
    }

    private rectangleHint(contextToUse: CanvasRenderingContext2D, rect: [Vec2, Vec2], sender: Username): void {
        contextToUse.clearRect(0, 0, contextToUse.canvas.width, contextToUse.canvas.height);
        contextToUse.strokeStyle = sender !== SERVER_USERNAME ? 'green' : 'blue';
        contextToUse.fillStyle = sender !== SERVER_USERNAME ? 'darkgreen' : 'darkblue';
        contextToUse.lineWidth = HINT_WIDTH;
        contextToUse.strokeRect(
            rect[0].x + RECT_POSITION_OFFSET,
            rect[0].y + RECT_POSITION_OFFSET,
            rect[1].x - RECT_SIZE_OFFSET,
            rect[1].y - RECT_SIZE_OFFSET,
        );
        contextToUse.font = '30px sans-serif';
        contextToUse.textAlign = 'start';
        contextToUse.textBaseline = 'top';
        if (sender !== SERVER_USERNAME)
            contextToUse.fillText(sender, rect[0].x + RECT_POSITION_OFFSET, rect[0].y + RECT_POSITION_OFFSET, rect[1].x - RECT_SIZE_OFFSET);
        this.replayService.setTimeout(() => {
            contextToUse.clearRect(0, 0, contextToUse.canvas.width, contextToUse.canvas.height);
        }, HINT_COOLDOWN_TIME_MS);
    }
}
