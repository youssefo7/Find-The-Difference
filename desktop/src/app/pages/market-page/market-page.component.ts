import { Component } from '@angular/core';
import { InfoCardConfig } from '@common/constants';

@Component({
    selector: 'app-market-page',
    templateUrl: './market-page.component.html',
    styleUrl: './market-page.component.scss',
})
export class MarketPageComponent {
    infoCardConfig: InfoCardConfig = InfoCardConfig.Market;
}
