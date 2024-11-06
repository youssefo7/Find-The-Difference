import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { ADMIN_PASSWORD } from '@common/constants';
import { Router } from '@angular/router';

@Component({
    selector: 'app-modal-configuration-password',
    templateUrl: './modal-configuration-password.component.html',
    styleUrl: './modal-configuration-password.component.scss',
})
export class ModalConfigurationPasswordComponent {
    password: string = '';
    showError: boolean = false;
    constructor(
        public dialogRef: MatDialogRef<ModalConfigurationPasswordComponent>,
        private router: Router,
    ) {}

    get showPasswordError() {
        return this.showError;
    }
    checkPassword() {
        if (this.password === ADMIN_PASSWORD) {
            this.dialogRef.close();
            this.router.navigate(['/config']);
            this.showError = false;
        } else {
            this.showError = true;
        }
    }

    closeDialog() {
        this.dialogRef.close();
    }
}
