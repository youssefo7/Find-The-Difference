import { Component, EventEmitter, Input, Output } from '@angular/core';
import { ThemeService } from '@app/services/theme.service';

@Component({
    selector: 'app-color-input',
    templateUrl: './color-input.component.html',
    styleUrls: ['./color-input.component.scss'],
})
export class ColorInputComponent {
    @Input() color: string;
    @Output() colorChange = new EventEmitter<string>();

    readonly baseColors: string[][] = [
        ['#FFFFFF', '#C0C0C0', '#808080', '#000000', '#FF0000', '#800000', '#FFFF00', '#808000'],
        ['#00FF00', '#008000', '#00FFFF', '#008080', '#0000FF', '#000080', '#FF00FF', '#800080'],
    ];

    constructor(private readonly themeService: ThemeService) {}

    get textColor(): string {
        // eslint-disable-next-line @typescript-eslint/no-magic-numbers
        if (!this.color || this.color.length !== 7) {
            return '#000000';
        }
        return this.themeService.getContrastColor(this.color);
    }

    onSelectedColorChange(event: Event): void {
        const target = event.target as HTMLInputElement;
        this.color = target.value;
        this.colorChange.emit(this.color);
    }

    onBaseColorClick(color: string): void {
        this.color = color;
        this.colorChange.emit(this.color);
    }
}
