import { Component } from '@angular/core';
import { InfoCardConfig } from '@common/constants';

@Component({
    selector: 'app-config-page',
    templateUrl: './config-page.component.html',
    styleUrls: ['./config-page.component.scss'],
})
export class ConfigPageComponent {
    configMode = InfoCardConfig.Configuration;
}
