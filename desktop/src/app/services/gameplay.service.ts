/* eslint-disable max-lines */

import { Injectable } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { ModalEndgameComponent } from '@app/components/modal-endgame/modal-endgame.component';
import { ModalReplayComponent } from '@app/components/modal-replay/modal-replay.component';
import { AUDIO_VOLUME, DIFF_FOUND_PATH, DIFF_NOT_FOUND_PATH, ERROR_TIMEOUT } from '@app/constants/game-running';
import { MouseButton } from '@app/constants/mouse';
import { EndgameDialogData, ReplayDialogData } from '@app/interfaces/dialog-data';
import { HIGH_SCORE_MONEY, IMAGE_HEIGHT, IMAGE_WIDTH, MS_PER_SECOND } from '@common/constants';
import { GameMode, GameTemplate, ImageClicked, TIME_LIMIT_PREFIX, Vec2 } from '@common/game-template';
import { GameTemplateId, TeamIndex, Username } from '@common/ingame-ids.types';
import { DEFAULT_REWARD_TIME, DEFAULT_TOTAL_TIME } from '@common/time-config.constants';
import { TimeConfigDto } from '@common/websocket/waiting-room.dto';
import { BlinkService } from '@services/blink.service';
import { SocketIoService } from '@services/socket.io.service';
import { ChangeTemplateDto, DifferenceFoundDto, EndGameDto, InGameEvent, StartGameDto, StateDto, TimeEventDto } from '@websocket/in-game.dto';
import { AuthService } from './auth.service';
import { GameTemplateService } from './game-template.service';
import { ImageService } from './image.service';
import { ReplayService } from './replay.service';
import { StatisticsService } from './statistics.service';

interface PlayerData {
    teamIndex: TeamIndex;
    differencesFoundCount: number;
}

@Injectable({
    providedIn: 'root',
})
export class GameplayService {
    static usernameOverride: undefined | Username;
    static muted = false;
    static gameMode: GameMode;
    static gameTemplateId: GameTemplateId;
    static isObserver: boolean;
    static postInitCb: () => void;

    team2TimeSeconds?: number;
    timeSeconds: number;
    differencesToFind = 0;
    timeConfig: TimeConfigDto = {
        totalTime: DEFAULT_TOTAL_TIME,
        rewardTime: DEFAULT_REWARD_TIME,
        cheatModeAllowed: false,
    };
    teamIndicator: number = 0;

    observers: Set<Username> = new Set<Username>();
    teams: Record<TeamIndex, Username[]> = {};
    playerData: Record<Username, PlayerData> = {};
    isCheatModeEnabled = false;
    isGameStarted = false;
    gameTemplate: GameTemplate;

    nextFirstImage: Promise<HTMLImageElement>;
    nextSecondImage: Promise<HTMLImageElement>;
    nextGameTemplate: Promise<GameTemplate>;
    nextPixelsToRemove?: Vec2[];
    firstContext: CanvasRenderingContext2D;
    secondContext: CanvasRenderingContext2D;
    leftImage: HTMLImageElement;
    rightImage: HTMLImageElement;

    showError: Record<string, Vec2> = {};

    // eslint-disable-next-line max-params -- https://discord.com/channels/1054141487656472616/1054141488042356874/1074065304059117730
    constructor(
        private blinkService: BlinkService,
        private gameTemplateService: GameTemplateService,
        private imageService: ImageService,
        private socketIoService: SocketIoService,
        private dialog: MatDialog,
        private authService: AuthService,
        private replayService: ReplayService,
        private statisticsService: StatisticsService,
    ) {}

    get isTimeLimit(): boolean {
        return this.gameMode.startsWith(TIME_LIMIT_PREFIX);
    }
    get username(): Username {
        return GameplayService.usernameOverride ?? this.authService.getUsername();
    }
    get players(): Username[] {
        return Object.keys(this.playerData);
    }

    get isObserver() {
        return GameplayService.isObserver;
    }
    get gameTemplateId() {
        return GameplayService.gameTemplateId;
    }
    get gameMode() {
        return GameplayService.gameMode;
    }

    get teamIndex(): TeamIndex | undefined {
        return this.isObserver ? undefined : this.playerData[this.username].teamIndex;
    }

    get isInReplayMode(): boolean {
        return this.replayService.isInReplayMode;
    }

    connect(firstContext: CanvasRenderingContext2D, secondContext: CanvasRenderingContext2D): void {
        this.firstContext = firstContext;
        this.secondContext = secondContext;
        this.timeSeconds = 0;
        this.differencesToFind = 0;
        this.playerData = {};
        this.teams = {};
        this.isGameStarted = false;
        this.observers.clear();
    }

    removeListeners() {
        this.replayService.removeAllInGameListeners();
    }

    async init(firstContext: CanvasRenderingContext2D, secondContext: CanvasRenderingContext2D): Promise<void> {
        if (this.isObserver) this.listenOnObserverStateSync();
        else this.listenOnStartGame();

        this.listenOnTimeEvent();
        this.listenOnPlayerLeave();
        this.listenOnEndgame();
        this.listenOnDifferenceFound();
        this.listenOnShowError();
        this.listenOnRemovePixels(firstContext, secondContext);
        this.listenOnGameTemplateDeletion();
        this.listenOnCheatModePixels(firstContext, secondContext);
        this.listenOnObserverJoinedEvent();
        this.listenOnObserverLeaveEvent();

        if (this.isTimeLimit) {
            this.listenOnChangeTemplate();
        } else {
            this.gameTemplate = await this.gameTemplateService.getGameTemplate(this.gameTemplateId);
            this.leftImage = await this.imageService.fileToImage(this.gameTemplate.firstImage);
            this.rightImage = await this.imageService.fileToImage(this.gameTemplate.secondImage);
            this.draw(this.firstContext, this.leftImage);
            this.draw(this.secondContext, this.rightImage);
        }
        this.replayService.setUp();
        if (this.replayService.isInReplayMode) {
            this.openReplayDialog();
        }
        GameplayService.postInitCb();
    }

    mouseHitDetect(event: MouseEvent, imageClicked: string): void {
        if (this.isObserver) return;
        if (event.button === MouseButton.Left) {
            this.socketIoService.emit(InGameEvent.IdentifyDifference, {
                position: { x: event.offsetX, y: event.offsetY },
                imageClicked: imageClicked === 'left' ? ImageClicked.Left : ImageClicked.Right,
            });
        }
    }

    toggleCheatMode(): void {
        if (this.replayService.isInReplayMode) {
            return;
        }

        this.isCheatModeEnabled = !this.isCheatModeEnabled;
        if (this.isCheatModeEnabled) {
            this.socketIoService.emit(InGameEvent.CheatModeEvent, undefined);
        } else {
            this.blinkService.disableCheatModeBlink();
        }
    }

    private createWinLossTexts(endGameDto: EndGameDto): string[] {
        if (this.isObserver) return [$localize`Thanks for Watching`];
        const winner = $localize`Winner`;
        const loser = $localize`Loser`;
        const win = $localize`You win!`;
        const lose = $localize`You lost!`;
        const time = $localize`Time`;
        const seconds = $localize`seconds`;
        const money = $localize`You gained $${endGameDto.pointsReceived}`;
        const newHighScore = $localize`You created a new high score`;
        const winLossText = [$localize`Game over`];

        switch (this.gameMode) {
            case GameMode.ClassicMultiplayer:
            case GameMode.TeamClassic:
                winLossText.push(`${winner}: ${endGameDto.winners.join(', ')}`);
                winLossText.push(`${loser}: ${endGameDto.losers.join(', ')}`);
                winLossText.push(`${time}: ${Math.floor(endGameDto.totalTimeMs / MS_PER_SECOND)} ${seconds}`);
                break;
            case GameMode.TimeLimitTurnByTurn:
            case GameMode.TimeLimitSingleDiff:
            case GameMode.TimeLimitAugmented:
                winLossText.push($localize`Thanks for playing!`);
        }

        winLossText.push(endGameDto.winners.some((w: string) => w === this.username) ? win : lose);
        winLossText.push(money);
        if (endGameDto.pointsReceived === HIGH_SCORE_MONEY) {
            winLossText.push(newHighScore);
        }
        return winLossText;
    }

    private openEndgameDialog(texts: string[], showReplay: boolean): void {
        const showReplayDialog = showReplay && !this.gameMode.startsWith(TIME_LIMIT_PREFIX) && !this.isObserver;
        const openReplayDialog = showReplayDialog ? this.openReplayDialog.bind(this) : undefined;
        this.dialog.open(ModalEndgameComponent, {
            data: { texts, openReplayDialog } as EndgameDialogData,
            disableClose: true,
        });
    }

    private drawOriginalImages(): void {
        this.firstContext.drawImage(this.leftImage, 0, 0);
        this.secondContext.drawImage(this.rightImage, 0, 0);
    }

    private openReplayDialog(): void {
        this.dialog.open(ModalReplayComponent, {
            backdropClass: 'dialog-replay-backdrop',
            disableClose: true,
            position: { bottom: '2rem' },
            data: {
                drawOriginalImages: this.drawOriginalImages.bind(this),
            } as ReplayDialogData,
        });
    }

    private onDifferenceFound(data: DifferenceFoundDto): void {
        const { username } = data;
        this.teams[this.playerData[username].teamIndex].forEach((teamMember) => this.playerData[teamMember].differencesFoundCount++);
        if (username === this.username) {
            const audio = new Audio(DIFF_FOUND_PATH);
            audio.volume = AUDIO_VOLUME;
            audio.playbackRate = this.replayService.currentReplaySpeed;
            if (!GameplayService.muted) audio.play();
        }
    }

    private onShowError(imageClicked: ImageClicked, position: Vec2): void {
        const audio = new Audio(DIFF_NOT_FOUND_PATH);
        audio.volume = AUDIO_VOLUME;
        audio.playbackRate = this.replayService.currentReplaySpeed;
        if (!GameplayService.muted) audio.play();
        this.showError[imageClicked] = position;
        this.replayService.setTimeout(() => {
            delete this.showError[imageClicked];
        }, ERROR_TIMEOUT);
    }

    private onGameTemplateDeletion(): void {
        this.openEndgameDialog([$localize`This game has been deleted`, $localize`You will be redirected to the home page`], false);
    }

    private onStartGame({ nGroups, teams, timeConfig }: StartGameDto) {
        this.teams = teams;
        this.differencesToFind = nGroups;
        this.timeConfig = timeConfig;

        Object.entries(this.teams).forEach(([teamIndex, teamMembers]) => {
            teamMembers.forEach(
                (username) =>
                    (this.playerData[username] = {
                        differencesFoundCount: 0,
                        teamIndex: parseInt(teamIndex, 10),
                    }),
            );
        });

        this.isGameStarted = true;

        this.isCheatModeEnabled = false;
        this.blinkService.disableCheatModeBlink();
    }

    private listenOnStartGame(): void {
        this.socketIoService.on(InGameEvent.StartGame, (data) => this.onStartGame(data));
    }

    private listenOnObserverStateSync(): void {
        this.socketIoService.on(InGameEvent.ObserverStateSync, async (stateDto: StateDto) => {
            this.onStartGame(stateDto.startGameDto);

            Object.entries(stateDto.playerScore).forEach(([username, score]) => (this.playerData[username].differencesFoundCount = score));
            stateDto.observers.forEach((observer) => this.observers.add(observer));

            if (stateDto.timeLimitPreload) {
                await this.onChangeTemplate(stateDto.timeLimitPreload[0]);
                await this.onChangeTemplate(stateDto.timeLimitPreload[1]);
            } else {
                this.blinkService.removePixels(this.firstContext, this.secondContext, stateDto.pixelToRemove);
            }
        });
    }

    private listenOnEndgame(): void {
        this.socketIoService.on(InGameEvent.EndGame, (endGameDto) => {
            const differenceFoundRatio = this.playerData[this.username]?.differencesFoundCount / this.differencesToFind;
            this.statisticsService.updateDifferencesFoundPercentage(differenceFoundRatio);
            this.isCheatModeEnabled = false;
            this.blinkService.disableCheatModeBlink();
            if (!this.replayService.isInReplayMode) {
                this.openEndgameDialog(this.createWinLossTexts(endGameDto), true);
            }
        });
    }

    private listenOnDifferenceFound(): void {
        this.socketIoService.on(InGameEvent.DifferenceFound, this.onDifferenceFound.bind(this));
    }

    private listenOnShowError(): void {
        this.socketIoService.on(InGameEvent.ShowError, ({ position, imageClicked }) => {
            this.onShowError(imageClicked, position);
        });
    }

    private listenOnRemovePixels(firstContext: CanvasRenderingContext2D, secondContext: CanvasRenderingContext2D): void {
        this.socketIoService.on(InGameEvent.RemovePixels, ({ pixels }) => {
            this.blinkService.blinkPixelsAndRemove(firstContext, secondContext, pixels);
        });
    }

    private listenOnTimeEvent(): void {
        this.socketIoService.on(InGameEvent.TimeEvent, ({ timeMs, team2TimeMs }: TimeEventDto) => {
            this.timeSeconds = timeMs / MS_PER_SECOND;
            if (team2TimeMs !== undefined) {
                this.team2TimeSeconds = team2TimeMs / MS_PER_SECOND;
            } else {
                this.team2TimeSeconds = undefined;
            }
        });
    }

    private listenOnGameTemplateDeletion(): void {
        this.socketIoService.on(InGameEvent.InstanceDeletion, this.onGameTemplateDeletion.bind(this));
    }

    private listenOnCheatModePixels(firstContext: CanvasRenderingContext2D, secondContext: CanvasRenderingContext2D): void {
        this.socketIoService.on(InGameEvent.CheatModeEvent, ({ groupToPixels }) => {
            this.blinkService.enableCheatModeBlink(firstContext, secondContext, groupToPixels.flat());
        });
    }

    private async onChangeTemplate({ nextGameTemplateId, pixelsToRemove }: ChangeTemplateDto): Promise<void> {
        this.teamIndicator = this.teamIndicator === 0 ? 1 : 0;
        if (this.nextGameTemplate) {
            this.blinkService.blinkEndCallback();
            this.gameTemplate = await this.nextGameTemplate;
            if (this.isCheatModeEnabled) {
                this.toggleCheatMode();
                this.toggleCheatMode();
            }

            this.firstContext.clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
            this.firstContext.drawImage(await this.nextFirstImage, 0, 0);
            this.secondContext.clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
            this.secondContext.drawImage(await this.nextSecondImage, 0, 0);
            if (this.nextPixelsToRemove) this.blinkService.removePixels(this.firstContext, this.secondContext, this.nextPixelsToRemove);
        }
        if (nextGameTemplateId) {
            this.nextGameTemplate = this.loadNextImages(nextGameTemplateId, pixelsToRemove);
        }
    }

    private listenOnChangeTemplate(): void {
        this.socketIoService.on(InGameEvent.ChangeTemplate, async (data) => this.onChangeTemplate(data));
    }

    private listenOnPlayerLeave(): void {
        this.socketIoService.on(InGameEvent.PlayerLeave, ({ username }) => {
            const index = this.playerData[username].teamIndex;
            delete this.playerData[username];
            this.teams[index] = this.teams[index].filter((name) => name !== username);
            if (this.teams[index].length === 0) delete this.teams[index];
        });
    }

    private listenOnObserverJoinedEvent(): void {
        this.socketIoService.on(InGameEvent.ObserverJoinedEvent, ({ username }) => this.observers.add(username));
    }

    private listenOnObserverLeaveEvent(): void {
        this.socketIoService.on(InGameEvent.ObserverLeavedEvent, ({ username }) => this.observers.delete(username));
    }

    private draw(context: CanvasRenderingContext2D, image: HTMLImageElement): void {
        context.clearRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        context.drawImage(image, 0, 0);
    }

    private async loadNextImages(nextGameTemplateId: GameTemplateId, pixelsToRemove?: Vec2[]): Promise<GameTemplate> {
        const gameTemplate = await this.gameTemplateService.getGameTemplate(nextGameTemplateId);
        this.nextFirstImage = this.imageService.fileToImage(gameTemplate.firstImage);
        this.nextSecondImage = this.imageService.fileToImage(gameTemplate.secondImage);
        this.nextPixelsToRemove = pixelsToRemove;
        return gameTemplate;
    }
}
