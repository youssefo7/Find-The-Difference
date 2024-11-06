import { Component } from '@angular/core';
import { SECONDS_PER_MINUTE } from '@common/constants';
import { GameplayService } from '@services/gameplay.service';

@Component({
    selector: 'app-timer',
    templateUrl: './timer.component.html',
    styleUrls: ['./timer.component.scss'],
})
export class TimerComponent {
    constructor(private gameplayService: GameplayService) {}

    get timeSeconds(): number {
        if (this.gameplayService.isObserver || !this.has2Clocks) return this.gameplayService.timeSeconds || 0;
        return this.gameplayService.teamIndex === 0 ? this.gameplayService.timeSeconds || 0 : this.gameplayService.team2TimeSeconds || 0;
    }

    get timeSecondsOtherTeam(): number {
        if (this.gameplayService.isObserver) return this.gameplayService.team2TimeSeconds || 0;
        return this.gameplayService.teamIndex === 0 ? this.gameplayService.team2TimeSeconds || 0 : this.gameplayService.timeSeconds || 0;
    }

    get has2Clocks(): boolean {
        return this.gameplayService.team2TimeSeconds !== undefined;
    }

    formatTime(time: number): string {
        time = Math.floor(time);
        const minutes = Math.floor(time / SECONDS_PER_MINUTE);
        const seconds = time % SECONDS_PER_MINUTE;
        const paddedSeconds = (seconds + '').padStart(2, '0');
        return `${minutes}:${paddedSeconds}`;
    }
}
