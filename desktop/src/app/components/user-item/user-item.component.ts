import { Component, Input, OnInit } from '@angular/core';
import { UserService } from '@app/services/user.service';

import { INITIAL_DEFAULT_AVATAR } from '@common/constants';

@Component({
    selector: 'app-user-item',
    templateUrl: './user-item.component.html',
    styleUrls: ['./user-item.component.scss'],
})
export class UserItemComponent implements OnInit {
    @Input() username: string;
    @Input() isSelf?: boolean = false;

    constructor(private userService: UserService) {}

    get avatarUrl(): string {
        try {
            return this.userService.getUserByUsername(this.username).avatarUrl;
        } catch (e) {
            return INITIAL_DEFAULT_AVATAR;
        }
    }

    ngOnInit(): void {
        this.userService.fetchAllUsers();
    }
}
