import { Component, OnInit } from '@angular/core';
import { DisplayHistory } from '@app/interfaces/display-history';
import { TableColumn } from '@app/interfaces/table-column';
import { HistoryService } from '@app/services/history.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { first, of } from 'rxjs';
@Component({
    selector: 'app-history',
    templateUrl: './history.component.html',
    styleUrls: ['./history.component.scss'],
})
export class HistoryComponent implements OnInit {
    historyArray: DisplayHistory[] = [];

    columns: TableColumn[] = [
        { name: 'gameMode', displayName: $localize`Game mode`, dataSource: 'gameMode' },
        { name: 'winners', displayName: $localize`Winners`, dataSource: 'winners' },
        { name: 'losers', displayName: $localize`Losers`, dataSource: 'losers' },
        { name: 'quitters', displayName: $localize`Quitters`, dataSource: 'quitters' },
        { name: 'startTime', displayName: $localize`Start time`, dataSource: 'startTime' },
        { name: 'totalTime', displayName: $localize`Total time`, dataSource: 'totalTime' },
    ];
    columnNames = this.columns.map((column) => column.name);
    constructor(private historyService: HistoryService) {}

    get allowHistorySuppression(): boolean {
        return this.historyArray.length > 0;
    }

    ngOnInit(): void {
        this.refreshHistory();
    }
    refreshHistory(): void {
        const totalTimeOptions: Intl.DateTimeFormatOptions = {
            minute: 'numeric',
            second: 'numeric',
        };
        const historyObservable = this.historyService.findAll() ?? of(null);
        historyObservable.pipe(first()).subscribe((history) => {
            if (history) {
                this.historyArray = history.map((h) => ({
                    ...h,
                    startTime: new Date(h.startTime).toLocaleString(),
                    totalTime: new Date(h.totalTime).toLocaleString(undefined, totalTimeOptions),
                    gameMode: EnumTranslator.toGameModeString(h.gameMode),
                }));
            }
        });
    }
    clearHistory(): void {
        const clearHistoryObservable = this.historyService.clearHistory() ?? of(null);
        clearHistoryObservable.pipe(first()).subscribe(() => {
            this.refreshHistory();
        });
    }
}
