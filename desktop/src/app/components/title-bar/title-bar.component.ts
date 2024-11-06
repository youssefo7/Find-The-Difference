import { Component, Input } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { IsActiveMatchOptions, Router } from '@angular/router';
import { SocketIoService } from '@app/services/socket.io.service';
import { UserService } from '@app/services/user.service';
// eslint-disable-next-line no-restricted-imports
import { ModalConfigurationPasswordComponent } from '@app/components/modal-configuration-password/modal-configuration-password.component';
import { UserDto } from '@common/user.dto';
import { Observable } from 'rxjs';

@Component({
    selector: 'app-title-bar',
    templateUrl: './title-bar.component.html',
    styleUrls: ['./title-bar.component.scss'],
})
export class TitleBarComponent {
    @Input() title: string;
    profile$: Observable<UserDto | undefined> = this.userService.getProfile();
    // eslint-disable-next-line max-params
    constructor(
        private readonly router: Router,
        private readonly socketIoService: SocketIoService,
        private userService: UserService,
        public dialog: MatDialog,
    ) {}

    get userBalance(): number {
        return this.userService.userBalance;
    }

    isActive(route: string): boolean {
        const options: IsActiveMatchOptions = { paths: 'exact', queryParams: 'exact', fragment: 'ignored', matrixParams: 'ignored' };
        return this.router.isActive(route, options);
    }

    logOut(): void {
        this.socketIoService.disconnect();
    }

    openDialog(): void {
        this.dialog.open(ModalConfigurationPasswordComponent);
    }
}
