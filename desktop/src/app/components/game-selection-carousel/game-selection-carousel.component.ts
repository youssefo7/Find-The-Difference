import { Component, Input, OnInit } from '@angular/core';
import { GameTemplateService } from '@app/services/game-template.service';
import { SocketIoService } from '@app/services/socket.io.service';
import { GAME_TEMPLATE_PER_PAGE, InfoCardConfig, LOBBIES_PER_PAGE } from '@common/constants';
import { GameTemplate } from '@common/game-template';
import { ObserverGameDto, WaitingGameDto, WaitingGamesListDto, WaitingRoomEvent } from '@common/websocket/waiting-room.dto';

@Component({
    selector: 'app-game-selection-carousel',
    templateUrl: './game-selection-carousel.component.html',
    styleUrls: ['./game-selection-carousel.component.scss'],
})
export class GameSelectionCarouselComponent implements OnInit {
    @Input() configMode: InfoCardConfig;
    protected waitingGames: WaitingGameDto[];
    protected observersGames: ObserverGameDto[];

    protected isLoading = false;
    private index = 0;

    constructor(
        private gameTemplateService: GameTemplateService,
        private socketIoService: SocketIoService,
    ) {}

    get elementsList(): (GameTemplate | WaitingGameDto | ObserverGameDto)[] {
        switch (this.configMode) {
            case InfoCardConfig.Configuration:
            case InfoCardConfig.Creation:
            case InfoCardConfig.Market:
                return this.gameTemplateService.availableGames;
            case InfoCardConfig.GameSelection:
                return this.waitingGames;
            case InfoCardConfig.Watch:
                return this.observersGames;
        }
    }

    get isLobby() {
        switch (this.configMode) {
            case InfoCardConfig.Configuration:
            case InfoCardConfig.Creation:
            case InfoCardConfig.Market:
                return false;
            case InfoCardConfig.GameSelection:
            case InfoCardConfig.Watch:
                return true;
        }
    }

    get isGameTemplate() {
        return !this.isLobby;
    }

    get lobbyPage(): (WaitingGameDto | ObserverGameDto)[] {
        if (!this.isLobby) return [];
        return this.elementsList.slice(this.index, this.index + LOBBIES_PER_PAGE) as (WaitingGameDto | ObserverGameDto)[];
    }

    get gameTemplatePage(): GameTemplate[] {
        if (!this.isGameTemplate) return [];
        return this.elementsList.slice(this.index, this.index + GAME_TEMPLATE_PER_PAGE) as GameTemplate[];
    }

    get isEmpty(): boolean {
        return !this.elementsList || this.elementsList.length === 0;
    }

    ngOnInit(): void {
        this.listenWaitingGames();
        this.socketIoService.emit(WaitingRoomEvent.GetWaitingGames, undefined);
        this.isLoading = true;
        this.fetchGames();
    }

    fetchGames(): void {
        if (this.configMode === InfoCardConfig.Market) {
            this.gameTemplateService.getBuyableGames();
        } else if (this.configMode === InfoCardConfig.Creation) {
            this.gameTemplateService.getAvailableGames();
        } else {
            this.gameTemplateService.getAllGames();
        }
        this.index = 0;
        this.isLoading = false;
    }

    changePage(delta: number): void {
        this.index += delta * LOBBIES_PER_PAGE;
    }

    isPrevDisabled(): boolean {
        return this.isEmpty || this.index === 0;
    }

    isNextDisabled(): boolean {
        return this.isEmpty || this.index + LOBBIES_PER_PAGE >= this.elementsList.length;
    }

    private listenWaitingGames(): void {
        this.socketIoService.on(WaitingRoomEvent.WaitingGames, (waitingGamesListDto: WaitingGamesListDto) => {
            this.waitingGames = waitingGamesListDto.waitingGames;
            this.observersGames = waitingGamesListDto.observerGames;
        });
    }
}
