import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Username } from '@common/ingame-ids.types';
import { DifferenceFoundRatioDto } from '@common/statistics.dto';
import { catchError, first } from 'rxjs';
import { Observable } from 'rxjs/internal/Observable';
import { environment } from 'src/environments/environment';

@Injectable({
    providedIn: 'root',
})
export class StatisticsService {
    private readonly baseUrl: string = environment.serverUrl;
    constructor(private http: HttpClient) {}

    getStatistics(username: Username): Observable<number[]> {
        return this.http.get<number[]>(`${this.baseUrl}/user/stats/${username}`).pipe(
            catchError((error) => {
                throw error;
            }),
        );
    }

    async updateDifferencesFoundPercentage(differencesFound: number): Promise<void> {
        const url = `${this.baseUrl}/user/stats`;
        const body: DifferenceFoundRatioDto = {
            differenceFound: differencesFound,
        };

        return new Promise<void>((resolve) =>
            this.http
                .patch<void>(url, body)
                .pipe(first())
                .subscribe(() => {
                    resolve();
                }),
        );
    }
}
