import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { CreateGameDto, GameTemplate } from '@common/game-template';
import { GameTemplateId } from '@common/ingame-ids.types';
import { Observable, Subscription, first, firstValueFrom, map } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable({
    providedIn: 'root',
})
export class GameTemplateService {
    availableGames: GameTemplate[] = [];
    isLoading: boolean = true;
    private readonly baseUrl: string = environment.serverUrl;

    constructor(
        private readonly http: HttpClient,
        private router: Router,
    ) {}

    getAllGames(): void {
        const url = `${this.baseUrl}/game-template`;
        this.isLoading = true;
        this.http
            .get<GameTemplate[]>(url)
            .pipe(map((games) => this.updateURLs(games)))
            .pipe(first())
            .subscribe((data) => {
                this.availableGames = data;
                this.isLoading = false;
            });
    }

    getBuyableGames(): void {
        const url = `${this.baseUrl}/market/buyableGames`;
        this.isLoading = true;
        this.http
            .get<GameTemplate[]>(url)
            .pipe(map((games) => this.updateURLs(games)))
            .pipe(first())
            .subscribe((data) => {
                this.availableGames = data;
                this.isLoading = false;
            });
    }

    getAvailableGames(): void {
        const url = `${this.baseUrl}/market/availableGames`;
        this.isLoading = true;
        this.http
            .get<GameTemplate[]>(url)
            .pipe(map((games) => this.updateURLs(games)))
            .pipe(first())
            .subscribe((data) => {
                this.availableGames = data;
                this.isLoading = false;
            });
    }

    async getGameTemplate(id: GameTemplateId): Promise<GameTemplate> {
        const url = `${this.baseUrl}/game-template/${id}`;
        return firstValueFrom(this.http.get<GameTemplate>(url).pipe(map((game) => this.updateURLs([game])[0])));
    }

    getLength(): Observable<number> {
        const url = `${this.baseUrl}/game-template/length`;
        return this.http.get<number>(url);
    }

    createGameTemplate(createGameDto: CreateGameDto): Subscription {
        return this.http
            .post<void>(`${this.baseUrl}/game-template`, createGameDto)
            .pipe(first())
            .subscribe(() => {
                this.router.navigate(['/home']);
            });
    }

    deleteGame(id: string, callBack: () => void): void {
        const url = `${this.baseUrl}/game-template/${id}`;
        this.http.delete<void>(url).pipe(first()).subscribe(callBack);
    }

    private updateURLs(games: GameTemplate[]): GameTemplate[] {
        return games.map((game) => {
            return {
                ...game,
                firstImage: environment.s3BucketUrl + '/' + game.firstImage,
                secondImage: environment.s3BucketUrl + '/' + game.secondImage,
            };
        });
    }
}
