import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { AccountHistoryDto } from '@common/account-history';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
@Injectable({
    providedIn: 'root',
})
export class AccountHistoryService {
    private readonly baseUrl: string = environment.serverUrl;
    constructor(private readonly http: HttpClient) {}

    findByUsername(username: string): Observable<AccountHistoryDto[]> {
        return this.http.get<AccountHistoryDto[]>(`${this.baseUrl}/account-history/${username}`);
    }
}
