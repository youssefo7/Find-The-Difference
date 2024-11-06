import { Component } from '@angular/core';
import { EnumTranslator } from '@app/utils/enum-translator';
import { SERVER_USERNAME } from '@common/constants';
import { Difficulty } from '@common/game-template';
import { GameplayService } from '@services/gameplay.service';

@Component({
    selector: 'app-sidebar',
    templateUrl: './sidebar.component.html',
    styleUrls: ['./sidebar.component.scss'],
})
export class SidebarComponent {
    constructor(public gameplayService: GameplayService) {}

    get difficultyString() {
        if (!this.gameplayService.gameTemplate) return $localize`Unknown`;
        return this.gameplayService.gameTemplate.difficulty === Difficulty.Hard ? $localize`Hard` : $localize`Easy`;
    }

    get isGameStarted(): boolean {
        return this.gameplayService.isGameStarted;
    }

    get gameMode(): string {
        return EnumTranslator.toGameModeString(this.gameplayService.gameMode);
    }

    get name(): string {
        if (!this.gameplayService.gameTemplate) return $localize`Unknown`;
        return this.gameplayService.gameTemplate.name;
    }

    get observers(): string {
        const noObserverString = $localize`No Observers`;
        let observers = [...this.gameplayService.observers];
        if (!observers) return noObserverString;
        observers = observers.filter((username) => username !== SERVER_USERNAME);
        if (!observers.length) return noObserverString;
        return observers.join(' | ');
    }

    get nGroups(): string {
        if (!this.gameplayService.gameTemplate) return $localize`Unknown`;
        return JSON.stringify(this.gameplayService.gameTemplate.nGroups);
    }
}
