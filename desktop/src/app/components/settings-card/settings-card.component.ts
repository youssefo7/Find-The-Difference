import { Component, Inject, LOCALE_ID, OnInit } from '@angular/core';
import { AuthService } from '@app/services/auth.service';
import { LocaleService } from '@app/services/locale.service';
import { ThemeService } from '@app/services/theme.service';
import { UserService } from '@app/services/user.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { Username } from '@common/ingame-ids.types';
import { DEFAULT_THEME_COLORS } from '@common/theme.dto';

@Component({
    selector: 'app-settings-card',
    templateUrl: './settings-card.component.html',
    styleUrl: './settings-card.component.scss',
})
export class SettingsCardComponent implements OnInit {
    themeColors = DEFAULT_THEME_COLORS;
    primaryColor: string;
    locale: string;
    username: Username;
    isSaving = false;
    errorMessage: string | undefined;

    // eslint-disable-next-line max-params
    constructor(
        private themeService: ThemeService,
        private localeService: LocaleService,
        @Inject(LOCALE_ID) public activeLocale: string,
        private authService: AuthService,
        private userService: UserService,
    ) {}

    get isUsernameInvalid(): boolean {
        const pattern = /^[a-z0-9]*$/;
        return !this.username || this.username.length === 0 || !pattern.test(this.username);
    }

    get canSave(): boolean {
        const sameLocale = this.locale === this.activeLocale;
        const samePrimaryColor = this.primaryColor === this.themeService.primaryColor;
        const sameUsername = this.username === this.authService.getUsername();

        return !this.isSaving && !this.isUsernameInvalid && (!sameLocale || !samePrimaryColor || !sameUsername);
    }

    ngOnInit(): void {
        if (this.isSaving) return;
        this.primaryColor = this.themeService.primaryColor;
        this.username = this.authService.getUsername();
    }

    setPrimaryColor(color: string): void {
        this.primaryColor = color;
    }

    async onSave(): Promise<void> {
        if (this.isSaving) return;
        this.isSaving = true;
        this.errorMessage = undefined;
        await Promise.all([
            this.themeService.setPrimaryColor(this.primaryColor),
            this.themeService.updateThemeForUserAccount(),
            this.localeService.updateLocale(this.locale),
        ]);
        const sameUsername = this.username === this.authService.getUsername();
        if (!sameUsername) {
            const error = await this.userService.changeUsername(this.username);
            if (error) {
                this.errorMessage = EnumTranslator.httpErrorMessageToMessage(error.error.message);
                return;
            }
        }
        this.isSaving = false;
    }
}
