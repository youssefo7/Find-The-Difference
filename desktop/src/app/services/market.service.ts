import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { buyGameDto } from '@common/game-template';
import { Subscription, first } from 'rxjs';
import { environment } from 'src/environments/environment';
import { GameTemplateService } from './game-template.service';
@Injectable({
    providedIn: 'root',
})
export class MarketService {
    private readonly baseUrl: string = environment.serverUrl;
    constructor(
        private http: HttpClient,
        private gameTemplateService: GameTemplateService,
    ) {}
    async buyGame(gameId: buyGameDto): Promise<Subscription> {
        const url = `${this.baseUrl}/market/buyGame`;
        return await this.http
            .post<void>(url, gameId)
            .pipe(first())
            .subscribe(() => {
                this.gameTemplateService.getBuyableGames();
            });
    }
}
