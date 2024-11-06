import { Component } from '@angular/core';
import { DrawService } from '@app/services/draw.service';

@Component({
    selector: 'app-creation-page',
    templateUrl: './creation-page.component.html',
    styleUrls: ['./creation-page.component.scss'],
})
export class CreationPageComponent {
    constructor(public drawService: DrawService) {}
}
