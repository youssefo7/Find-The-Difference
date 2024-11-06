import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { HistoryDto } from '@common/history';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
@Injectable({
    providedIn: 'root',
})
export class HistoryService {
    private readonly baseUrl: string = environment.serverUrl;
    constructor(private readonly http: HttpClient) {}

    findAll(): Observable<HistoryDto[]> {
        return this.http.get<HistoryDto[]>(`${this.baseUrl}/history/`);
    }

    clearHistory(): Observable<void> {
        return this.http.delete<void>(`${this.baseUrl}/history/`);
    }

    findByUsername(username: string): Observable<HistoryDto[]> {
        return this.http.get<HistoryDto[]>(`${this.baseUrl}/history/${username}`);
    }
}
