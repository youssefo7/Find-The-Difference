import { Component, Input, OnInit } from '@angular/core';
import { GameLoaderService } from '@app/services/game-loader.service';
import { GameTemplateService } from '@app/services/game-template.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { IMAGE_HEIGHT, IMAGE_WIDTH } from '@common/constants';
import { GameMode, TIME_LIMIT_PREFIX } from '@common/game-template';
import { Username } from '@common/ingame-ids.types';
import { ObserverGameDto, WaitingGameDto } from '@common/websocket/waiting-room.dto';

@Component({
    selector: 'app-lobby-card',
    templateUrl: './lobby-card.component.html',
    styleUrl: './lobby-card.component.scss',
})
export class LobbyCardComponent implements OnInit {
    @Input() gameInfo: WaitingGameDto | ObserverGameDto;

    thumbnail: string;
    nDiffs: number;

    aspectRatio = `${IMAGE_WIDTH}/${IMAGE_HEIGHT}`;

    constructor(
        private gameLoaderService: GameLoaderService,
        private gameTemplateService: GameTemplateService,
    ) {}

    get creator(): Username | undefined {
        return (this.gameInfo as WaitingGameDto).creator;
    }

    get players(): Username[] {
        return this.gameInfo.players;
    }

    get hasObservers(): boolean | undefined {
        return (this.gameInfo as ObserverGameDto).hasObservers;
    }

    get isLobbyCard(): boolean {
        return 'creator' in this.gameInfo;
    }

    get buttonText(): string {
        return this.isLobbyCard ? $localize`Join` : $localize`Watch`;
    }

    get observersText(): Username {
        return this.hasObservers ? $localize`This game has observers` : $localize`This game does not have observers`;
    }

    get gameMode(): GameMode {
        return this.gameInfo.gameMode;
    }

    async ngOnInit() {
        await this.setAttributes();
    }

    joinWaitingGame(): void {
        if (!this.gameInfo) return;

        if (this.isLobbyCard) {
            this.gameLoaderService.joinWaitingGame(this.gameInfo as WaitingGameDto);
        } else {
            this.gameLoaderService.joinObserverGame(this.gameInfo as ObserverGameDto);
        }
    }

    gameModeToString(gameMode: GameMode): string {
        return EnumTranslator.toGameModeString(gameMode);
    }

    async setAttributes() {
        const gameMode = this.gameInfo.gameMode;

        if (gameMode.startsWith(TIME_LIMIT_PREFIX)) {
            this.thumbnail = 'https://polydiff.s3.ca-central-1.amazonaws.com/time_limited.png';
        } else {
            const gameTemplate = await this.gameTemplateService.getGameTemplate(this.gameInfo.templateId);
            this.thumbnail = gameTemplate.firstImage;
            this.nDiffs = gameTemplate.nGroups;
        }
    }
}
