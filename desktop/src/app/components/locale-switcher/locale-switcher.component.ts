import { Component, EventEmitter, Inject, LOCALE_ID, OnInit, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatSelectModule } from '@angular/material/select';

@Component({
    selector: 'app-locale-switcher',
    standalone: true,
    imports: [FormsModule, MatSelectModule],
    templateUrl: './locale-switcher.component.html',
    styleUrl: './locale-switcher.component.scss',
})
export class LocaleSwitcherComponent implements OnInit {
    @Output() valueChange = new EventEmitter<string>();

    readonly locales = [
        { value: 'en', viewValue: 'English' },
        { value: 'fr', viewValue: 'Français' },
    ];

    constructor(@Inject(LOCALE_ID) public activeLocale: string) {}

    ngOnInit(): void {
        this.updateLocale(this.activeLocale);
    }

    async updateLocale(locale: string): Promise<void> {
        this.valueChange.emit(locale);
    }
}
