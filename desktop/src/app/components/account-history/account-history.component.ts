import { Component, OnInit } from '@angular/core';
import { DisplayAccountHistory } from '@app/interfaces/display-account-history';
import { TableColumn } from '@app/interfaces/table-column';
import { AccountHistoryService } from '@app/services/account-history.service';
import { AuthService } from '@app/services/auth.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { first, of } from 'rxjs';

@Component({
    selector: 'app-account-history',
    templateUrl: './account-history.component.html',
    styleUrl: './account-history.component.scss',
})
export class AccountHistoryComponent implements OnInit {
    accountHistoryArray: DisplayAccountHistory[] = [];
    columns: TableColumn[] = [
        { name: 'action', displayName: $localize`Action`, dataSource: 'action' },
        { name: 'date', displayName: $localize`Date`, dataSource: 'date' },
    ];
    columnNames = this.columns.map((column) => column.name);
    constructor(
        private accountHistoryService: AccountHistoryService,
        private authService: AuthService,
    ) {}

    ngOnInit(): void {
        const accountHistoryObservable = this.accountHistoryService.findByUsername(this.authService.getUsername()) ?? of(null);
        accountHistoryObservable.pipe(first()).subscribe((accountHistory) => {
            if (accountHistory) {
                this.accountHistoryArray = accountHistory.map((h) => ({
                    action: EnumTranslator.translateAccountAction(h.action),
                    date: new Date(h.timestamp).toLocaleString(),
                }));
            }
        });
    }
}
