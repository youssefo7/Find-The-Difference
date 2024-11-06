import { Component, EventEmitter, Input, Output } from '@angular/core';
import { DEFAULT_REWARD_TIME, DEFAULT_TOTAL_TIME, MAX_GAME_TIME, MAX_TIME_JUMP, MIN_GAME_TIME, MIN_TIME_JUMP } from '@common/time-config.constants';
import { TimeConfigDto } from '@common/websocket/waiting-room.dto';

@Component({
    selector: 'app-config-parameters',
    templateUrl: './config-parameters.component.html',
    styleUrl: './config-parameters.component.scss',
})
export class ConfigParametersComponent {
    @Input({ required: true }) config: TimeConfigDto;
    @Output() configChange = new EventEmitter<TimeConfigDto>();

    @Input() showBonusTimeSlider = true;

    readonly minTimeJump: number = MIN_TIME_JUMP;
    readonly maxTimeJump: number = MAX_TIME_JUMP;
    readonly minGameTime: number = MIN_GAME_TIME;
    readonly maxGameTime: number = MAX_GAME_TIME;

    resetConfig(): void {
        this.config = {
            totalTime: DEFAULT_TOTAL_TIME,
            rewardTime: DEFAULT_REWARD_TIME,
            cheatModeAllowed: false,
        };
    }
}
