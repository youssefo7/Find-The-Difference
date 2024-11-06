import { HttpClient } from '@angular/common/http';
import { Inject, Injectable, LOCALE_ID } from '@angular/core';
import { first } from 'rxjs';
import { environment } from 'src/environments/environment';
import { SocketIoService } from './socket.io.service';

@Injectable({ providedIn: 'root' })
export class LocaleService {
    private readonly baseUrl: string = environment.serverUrl;

    constructor(
        private readonly http: HttpClient,
        private socketIoService: SocketIoService,
        @Inject(LOCALE_ID) private locale: string,
    ) {
        this.socketIoService.onConnect(() => this.getLocale());
    }

    get currentLocale(): string {
        return this.locale;
    }

    getLocale(): void {
        const url = `${this.baseUrl}/user/locale`;
        this.http
            .get<{ locale: string }>(url)
            .pipe(first())
            .subscribe(async (data) => {
                this._updateLocale(data.locale);
            });
    }

    async updateLocale(locale: string): Promise<void> {
        const url = `${this.baseUrl}/user/locale`;
        return new Promise((resolve) =>
            this.http
                .patch<void>(url, { locale })
                .pipe(first())
                .subscribe(() => {
                    this._updateLocale(locale);
                    resolve();
                }),
        );
    }

    private _updateLocale(locale: string): void {
        if (locale !== this.locale) {
            // If the locale changed, redirect to /en or /fr
            // Do not use Router.navigate, since Router can only navigate
            // inside the single page app
            // and we need to load a completely different page
            window.location.href = `/${locale}`;
        }
    }
}
