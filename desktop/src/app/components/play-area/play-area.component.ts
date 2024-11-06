import { Component, ElementRef, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { HintService } from '@app/services/hint.service';
import { ImageService } from '@app/services/image.service';
import { HINT_PRICE, IMAGE_HEIGHT, IMAGE_WIDTH } from '@common/constants';
import { GameMode, Vec2 } from '@common/game-template';
import { Username } from '@common/ingame-ids.types';
import { GameplayService } from '@services/gameplay.service';

@Component({
    selector: 'app-play-area',
    templateUrl: './play-area.component.html',
    styleUrls: ['./play-area.component.scss'],
})
export class PlayAreaComponent implements OnInit, OnDestroy {
    @ViewChild('firstCanvas', { static: true }) firstCanvas: ElementRef<HTMLCanvasElement>;
    @ViewChild('secondCanvas', { static: true }) secondCanvas: ElementRef<HTMLCanvasElement>;

    hintToGive?: [Vec2, Vec2];
    hintTarget?: Username;
    gameMode: GameMode;

    protected imageWidth = IMAGE_WIDTH;
    protected imageHeight = IMAGE_HEIGHT;

    constructor(
        public gameplayService: GameplayService,
        private readonly imageService: ImageService,
        public hintService: HintService,
    ) {}

    get hintPrice() {
        return HINT_PRICE;
    }

    get isGameStarted(): boolean {
        return this.gameplayService.isGameStarted;
    }

    get teams(): Username[][] {
        return Object.values(this.gameplayService.teams);
    }

    get observers(): Username[] {
        return [...this.gameplayService.observers];
    }

    highlight(isCurrentUsersTeam: boolean) {
        if (this.gameplayService.isObserver) return false;
        const isCurrentUserTurn = this.gameplayService.playerData[this.gameplayService.username].teamIndex === this.gameplayService.teamIndicator;
        return this.gameMode === GameMode.TimeLimitTurnByTurn && isCurrentUserTurn === isCurrentUsersTeam;
    }

    toggleCheatMode(): void {
        this.gameplayService.toggleCheatMode();
    }

    ngOnDestroy(): void {
        this.gameplayService.removeListeners();
        this.hintService.removeListener();
    }

    async ngOnInit(): Promise<void> {
        this.gameMode = this.gameplayService.gameMode;
        const firstContext = this.imageService.getContext(this.firstCanvas.nativeElement);
        const secondContext = this.imageService.getContext(this.secondCanvas.nativeElement);

        this.gameplayService.connect(firstContext, secondContext);
        this.hintService.connect([]);
        await this.gameplayService.init(firstContext, secondContext);
        this.hintService.initSocket();
    }

    setSelectedHintTarget(hint: [Vec2, Vec2] | undefined): void {
        this.hintToGive = hint;
    }

    setHint(hint: [Vec2, Vec2] | undefined): void {
        this.hintToGive = hint;
        if (!this.hintToGive) return;
        this.hintService.giveHint({
            rect: this.hintToGive,
            player: this.hintTarget,
        });
    }

    buyHint(): void {
        this.hintService.buyHint();
    }
}
