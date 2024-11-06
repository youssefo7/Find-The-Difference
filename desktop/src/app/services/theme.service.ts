/* eslint-disable @typescript-eslint/no-magic-numbers */

import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { DEFAULT_THEME, Theme } from '@common/theme.dto';
import { first } from 'rxjs';
import { environment } from 'src/environments/environment';
import { SocketIoService } from './socket.io.service';

@Injectable()
export class ThemeService {
    primaryColor: string;

    private readonly hues = ['50', '100', '200', '300', '400', '500', '600', '700', '800', '900', 'A100', 'A200', 'A400', 'A700'];
    private readonly baseUrl: string = environment.serverUrl;

    // eslint-disable-next-line max-params
    constructor(
        private readonly http: HttpClient,
        private _snackBar: MatSnackBar,
        private socketIoService: SocketIoService,
    ) {
        this.initTheme();
        this.socketIoService.onConnect(() => this.getThemeFromUserAccount());
    }

    initTheme(): void {
        setTimeout(() => {
            this.setPrimaryColor(DEFAULT_THEME.primaryColor);
        }, 0);
    }

    getThemeFromUserAccount(): void {
        const url = `${this.baseUrl}/user/theme`;
        // eslint-disable-next-line @typescript-eslint/naming-convention
        this.http
            .get<Theme>(url)
            .pipe(first())
            .subscribe(async (data) => {
                this.setPrimaryColor(data.primaryColor);
            });
    }

    async updateThemeForUserAccount(): Promise<void> {
        const url = `${this.baseUrl}/user/theme`;
        const body: Theme = {
            primaryColor: this.primaryColor,
        };

        return new Promise((resolve) =>
            this.http
                .patch<void>(url, body)
                .pipe(first())
                .subscribe(() => {
                    this._snackBar.open($localize`Theme changes saved`);
                    resolve();
                }),
        );
    }

    setPrimaryColor(primaryColor: string): void {
        this.primaryColor = primaryColor;

        for (const hue of this.hues) {
            this.setCssVariable('primary', hue, primaryColor);
        }
    }

    // https://stackoverflow.com/a/41491220
    getContrastColor(color: string): string {
        const [r, g, b] = this.parseColor(color);
        const l = r * 0.299 + g * 0.587 + b * 0.114;
        return l > 186 ? '#000000' : '#ffffff';
    }

    private setCssVariable(palette: string, hue: string, primaryColor: string): void {
        let percent;
        if (hue[0] === 'A') {
            percent = (500 - Number(hue.substring(1))) * 0.25;
        } else {
            percent = (500 - Number(hue)) * 0.25;
        }
        const color = this.shadeColor(primaryColor, percent);

        document.documentElement.style.setProperty(`--${palette}-${hue}`, color);

        const contrast = this.getContrastColor(color);
        document.documentElement.style.setProperty(`--${palette}-contrast-${hue}`, contrast);
    }

    private parseColor(color: string): [number, number, number] {
        color = color.substring(1, 7);
        const r = parseInt(color.substring(0, 2), 16);
        const g = parseInt(color.substring(2, 4), 16);
        const b = parseInt(color.substring(4, 6), 16);
        return [r, g, b];
    }

    private shadeColor(color: string, percent: number): string {
        const [r, g, b] = this.parseColor(color);

        const rr = this.shadeChannel(r, percent);
        const gg = this.shadeChannel(g, percent);
        const bb = this.shadeChannel(b, percent);
        return '#' + rr + gg + bb;
    }

    private shadeChannel(channel: number, percent: number): string {
        channel = channel * (1 + percent / 100);
        channel = this.clamp(channel, 0, 255);
        channel = Math.round(channel);

        return channel.toString(16).padStart(2, '0');
    }

    private clamp(n: number, lowerBound: number, upperBound: number): number {
        if (n < lowerBound) {
            return lowerBound;
        }
        if (n > upperBound) {
            return upperBound;
        }

        return n;
    }
}
