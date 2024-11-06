import { CommonModule } from '@angular/common';
import { Component, OnDestroy, OnInit } from '@angular/core';
import { FormBuilder, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialogModule } from '@angular/material/dialog';
import { MatDividerModule } from '@angular/material/divider';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTabsModule } from '@angular/material/tabs';
import { Router } from '@angular/router';
import { AvatarSelectionComponent } from '@app/components/avatar-selection/avatar-selection.component';
import { HttpError } from '@app/interfaces/http-error';
import { AuthService } from '@app/services/auth.service';
import { SocketIoService } from '@app/services/socket.io.service';
import { EnumTranslator } from '@app/utils/enum-translator';
import { Observable, throwError } from 'rxjs';

enum AuthAction {
    Login = 'login',
    Register = 'register',
}

const PASSWORD_MAX_LENGTH = 128;

@Component({
    selector: 'app-login-page',
    standalone: true,
    imports: [
        AvatarSelectionComponent,
        FormsModule,
        MatButtonModule,
        MatCardModule,
        MatDialogModule,
        MatDividerModule,
        MatFormFieldModule,
        MatIconModule,
        MatInputModule,
        MatTabsModule,
        ReactiveFormsModule,
        MatSelectModule,
        CommonModule,
    ],
    templateUrl: './login-page.component.html',
    styleUrl: './login-page.component.scss',
})
export class LoginPageComponent implements OnInit, OnDestroy {
    hidePassword = true;
    errorMessage = '';
    errorMessageLogin = '';
    errorMessageRegister = '';
    isSendingRequest = false;

    avatarUploadError: string;
    selectedAvatarUrl: string;

    loginForm = this.formBuilder.group({
        username: ['', Validators.required],
        password: ['', [Validators.required]],
    });

    registerForm = this.formBuilder.group({
        username: ['', Validators.required],
        password: ['', [Validators.required, Validators.maxLength(PASSWORD_MAX_LENGTH)]],
        email: ['', [Validators.required, Validators.pattern(/^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/)]],
    });

    // eslint-disable-next-line max-params
    constructor(
        private router: Router,
        private formBuilder: FormBuilder,
        private authService: AuthService,
        private socketIoService: SocketIoService,
    ) {}

    get usernameLogin() {
        return this.loginForm.get('username');
    }

    get passwordLogin() {
        return this.loginForm.get('password');
    }

    get usernameRegister() {
        return this.registerForm.get('username');
    }

    get passwordRegister() {
        return this.registerForm.get('password');
    }

    // eslint-disable-next-line @typescript-eslint/naming-convention
    get AuthAction() {
        return AuthAction;
    }

    ngOnInit(): void {
        if (this.socketIoService.isInitialized) this.router.navigate(['home']);
    }

    ngOnDestroy(): void {
        if (!this.socketIoService.isInitialized) this.router.navigate(['login']);
    }

    login(): void {
        const username = this.usernameLogin?.value?.trim();
        const password = this.passwordLogin?.value;
        if (!username || !password) return;

        if (this.isSendingRequest) return;
        this.isSendingRequest = true;

        this.authService.login(
            username,
            password,
            async () => {
                await this.socketIoService.connect();
            },
            (err) => this.handleError(AuthAction.Login, err),
        );
    }

    async register(): Promise<void> {
        const username = this.usernameRegister?.value?.trim();
        const password = this.passwordRegister?.value;

        if (!username || !password) return;
        const avatarUrl = this.selectedAvatarUrl;

        if (this.isSendingRequest) return;
        this.isSendingRequest = true;
        this.authService.register(
            {
                username,
                password,
                avatarUrl,
            },
            async () => {
                await this.socketIoService.connect();
            },
            (err) => this.handleError(AuthAction.Register, err),
        );
    }

    handleAvatarChange(newAvatarUrl: string): void {
        this.selectedAvatarUrl = newAvatarUrl;
    }

    getUsernameErrorMessage(action: AuthAction): string {
        const username = action === AuthAction.Login ? this.usernameLogin : this.usernameRegister;

        if (username?.hasError('required')) {
            return $localize`You must enter a value`;
        } else if (username?.hasError('pattern')) {
            return $localize`You must enter only lowercase letters and numbers`;
        }

        return '';
    }

    getPasswordErrorMessage(action: AuthAction): string {
        const password = action === AuthAction.Login ? this.passwordLogin : this.passwordRegister;

        if (password?.hasError('required')) {
            return $localize`You must enter a value`;
        } else if (password?.hasError('maxlength')) {
            return $localize`The value must be ${PASSWORD_MAX_LENGTH} characters or less`;
        }

        return '';
    }

    getEmailErrorMessage() {
        const email = this.registerForm.get('email');

        if (email?.hasError('required')) {
            return 'You must enter an email';
        } else if (email?.hasError('pattern')) {
            return 'Not a valid email';
        }
        return '';
    }

    private handleError(action: AuthAction, err: HttpError): Observable<never> {
        this.isSendingRequest = false;

        const msg: string = EnumTranslator.httpErrorMessageToMessage(err.error.message);

        if (action === AuthAction.Login) {
            this.errorMessageLogin = msg;
        } else {
            this.errorMessageRegister = msg;
        }
        return throwError(() => new Error(msg));
    }
}
