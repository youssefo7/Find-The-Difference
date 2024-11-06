import { Component, OnInit } from '@angular/core';
import { GameLoaderService } from '@app/services/game-loader.service';
import { ReplayService } from '@app/services/replay.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { GameMode } from '@common/game-template';
import { ReceiveReplayDto } from '@common/replay.dto';

type AugmentedReplayDto = ReceiveReplayDto & { buttonDisabled: boolean };

@Component({
    selector: 'app-replay-list',
    templateUrl: './replay-list.component.html',
    styleUrls: ['./replay-list.component.scss'],
})
export class ReplayListComponent implements OnInit {
    replays: AugmentedReplayDto[] = [];
    displayedColumns: string[] = ['gameMode', 'time', 'actions'];

    constructor(
        private replayService: ReplayService,
        private gameLoaderService: GameLoaderService,
    ) {}

    ngOnInit(): void {
        this.fetchReplays();
    }

    getReplayDate(unixDate: number): Date {
        const date = new Date(unixDate);
        return date;
    }

    async fetchReplays(): Promise<void> {
        this.replays = (await this.replayService.getReplays()).map((elem) => {
            return { ...elem, buttonDisabled: false };
        });
        this.replays.reverse();
    }

    gameModeToString(gameMode: GameMode): string {
        return EnumTranslator.toGameModeString(gameMode);
    }

    startReplay(replay: AugmentedReplayDto): void {
        replay.buttonDisabled = true;
        this.gameLoaderService.replayGame(replay);
    }

    async deleteReplay(replay: AugmentedReplayDto): Promise<void> {
        replay.buttonDisabled = true;
        await this.replayService.deleteReplay(replay.id);
        await this.fetchReplays();
    }
}
