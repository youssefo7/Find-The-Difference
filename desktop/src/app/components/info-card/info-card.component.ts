import { Component, Input, OnDestroy, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';

import { MarketConfirmationDialogComponent } from '@app/components/market-confirmation-dialog/market-confirmation-dialog.component';
import { ModalGameChooserComponent } from '@app/components/modal-game-chooser/modal-game-chooser.component';
import { GameChooserDialogData } from '@app/interfaces/dialog-data';
import { GameTemplateService } from '@app/services/game-template.service';
import { MarketService } from '@app/services/market.service';
import { SocketIoService } from '@app/services/socket.io.service';
import { UserService } from '@app/services/user.service';
import { IMAGE_HEIGHT, IMAGE_WIDTH, InfoCardConfig, MS_PER_SECOND, SECONDS_PER_MINUTE } from '@common/constants';
import { GameMode, GameTemplate } from '@common/game-template';
import { WaitingRoomEvent } from '@common/websocket/waiting-room.dto';
import { first } from 'rxjs';

interface ButtonProps {
    text: string;
    onClick: () => void;
}

@Component({
    selector: 'app-info-card',
    templateUrl: './info-card.component.html',
    styleUrls: ['./info-card.component.scss'],
})
export class InfoCardComponent implements OnInit, OnDestroy {
    static classicGameMode: GameMode = GameMode.ClassicMultiplayer;
    @Input() fetchGames: () => void;
    @Input() gameTemplate: GameTemplate;
    @Input() configMode: InfoCardConfig;

    button: ButtonProps;

    aspectRatio = `${IMAGE_WIDTH}/${IMAGE_HEIGHT}`;

    isUsed: boolean;

    // eslint-disable-next-line max-params -- élément central de l'application
    constructor(
        public dialog: MatDialog,
        private gameTemplateService: GameTemplateService,
        private socketIoService: SocketIoService,
        private marketService: MarketService,
        private userSerice: UserService,
    ) {}

    get isMarket(): boolean {
        return this.configMode === InfoCardConfig.Market;
    }

    ngOnDestroy(): void {
        this.socketIoService.removeListener(WaitingRoomEvent.WaitingGames);
    }

    ngOnInit(): void {
        this.initActionButtons();
    }

    startGame(gameMode: GameMode) {
        const data: GameChooserDialogData = { gameName: this.gameTemplate.name, gameTemplateId: this.gameTemplate._id, gameMode };
        this.dialog
            .open(ModalGameChooserComponent, {
                data,
            })
            .afterClosed()
            .pipe(first())
            .subscribe(() => {
                this.isUsed = false;
            });
    }

    formatTime(time: number): string {
        const totalSeconds = Math.floor(time / MS_PER_SECOND);
        const minutes = Math.floor(totalSeconds / SECONDS_PER_MINUTE);
        const seconds = totalSeconds % SECONDS_PER_MINUTE;
        const paddedSeconds = (seconds + '').padStart(2, '0');
        return `${minutes}:${paddedSeconds}`;
    }

    range(repetitions: number): number[] {
        return Array.from({ length: repetitions }, (_, i) => i);
    }

    isButtonDisabled(): boolean {
        return (this.isMarket && this.userSerice.userBalance < this.gameTemplate.price) || this.isUsed;
    }

    private initActionButtons(): void {
        if (this.configMode === InfoCardConfig.Configuration) {
            this.button = {
                text: $localize`Delete`,
                onClick: () => {
                    this.isUsed = true;
                    // eslint-disable-next-line no-underscore-dangle -- underscore inherited from mongoDB.
                    this.gameTemplateService.deleteGame(this.gameTemplate._id, this.fetchGames);
                },
            };
        } else if (this.configMode === InfoCardConfig.Creation) {
            this.button = {
                text: $localize`Play`,
                onClick: () => {
                    this.isUsed = true;
                    this.startGame(InfoCardComponent.classicGameMode);
                },
            };
        } else {
            this.button = {
                text: $localize`Buy ` + this.gameTemplate.price + '$',
                onClick: () => {
                    this.isUsed = true;
                    const dialogRef = this.dialog.open(MarketConfirmationDialogComponent, {
                        data: { price: this.gameTemplate.price },
                    });
                    dialogRef.afterClosed().subscribe((result) => {
                        if (result) {
                            this.marketService.buyGame({ gameTemplateId: this.gameTemplate._id });
                        } else {
                            this.isUsed = false;
                        }
                    });
                },
            };
        }
    }
}
