import { Component } from '@angular/core';
import { InfoCardConfig } from '@common/constants';

@Component({
    selector: 'app-game-selection-page',
    templateUrl: './game-selection-page.component.html',
    styleUrls: ['./game-selection-page.component.scss'],
})
export class GameSelectionPageComponent {
    infoCardConfig: InfoCardConfig = InfoCardConfig.Creation;
}
