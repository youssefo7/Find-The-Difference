import { Component } from '@angular/core';
import { InfoCardConfig } from '@common/constants';

@Component({
    selector: 'app-join-game-page',
    templateUrl: './join-game-page.component.html',
    styleUrls: ['./join-game-page.component.scss'],
})
export class JoinGamePageComponent {
    infoCardConfigJoin: InfoCardConfig = InfoCardConfig.GameSelection;
    infoCardConfigWatch: InfoCardConfig = InfoCardConfig.Watch;
}
