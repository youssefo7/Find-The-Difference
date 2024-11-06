import { Component, OnInit } from '@angular/core';
import { TableColumn } from '@app/interfaces/table-column';
import { AuthService } from '@app/services/auth.service';
import { HistoryService } from '@app/services/history.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { first } from 'rxjs';

@Component({
    selector: 'app-profile-game-history',
    templateUrl: './profile-game-history.component.html',
    styleUrl: './profile-game-history.component.scss',
})
export class ProfileGameHistoryComponent implements OnInit {
    gameHistoryArray: { gameMode: string; status: string; start: string }[] = [];

    columns: TableColumn[] = [
        { name: 'gameMode', displayName: $localize`Game mode`, dataSource: 'gameMode' },
        { name: 'status', displayName: $localize`Status`, dataSource: 'status' },
        { name: 'start', displayName: $localize`Start`, dataSource: 'start' },
    ];
    columnNames = this.columns.map((column) => column.name);
    constructor(
        private historyService: HistoryService,
        private authService: AuthService,
    ) {}

    ngOnInit(): void {
        this.refreshHistory();
    }
    refreshHistory(): void {
        const username = this.authService.getUsername();
        const gameHistoryObservable = this.historyService.findByUsername(username);
        gameHistoryObservable.pipe(first()).subscribe((gameHistory) => {
            if (gameHistory) {
                this.gameHistoryArray = gameHistory.map((h) => {
                    let status = $localize`Unknown`;
                    if (h.winners.includes(username)) {
                        status = $localize`Winner`;
                    } else if (h.losers.includes(username)) {
                        status = $localize`Loser`;
                    } else if (h.quitters.includes(username)) {
                        status = $localize`Quitter`;
                    }
                    return {
                        gameMode: EnumTranslator.toGameModeString(h.gameMode),
                        status,
                        start: new Date(h.startTime).toLocaleString(),
                    };
                });
            }
        });
    }
}
