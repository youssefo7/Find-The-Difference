import { Component, Input } from '@angular/core';

@Component({
    selector: 'app-statistic-card',
    templateUrl: './statistic-card.component.html',
    styleUrl: './statistic-card.component.scss',
})
export class StatisticCardComponent {
    @Input() title: string;
    @Input() value: number | string;
    @Input() description: string;
    @Input() icon: string;
}
