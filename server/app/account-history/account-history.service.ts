import { AuthService } from '@app/auth/auth.service';
import { UsersService } from '@app/users/users.service';
import { AccountAction } from '@common/account-action';
import { Username } from '@common/ingame-ids.types';
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { AccountHistory, AccountHistoryDocument } from './account-history.schema';

@Injectable()
export class AccountHistoryService {
    constructor(
        @InjectModel(AccountHistory.name) private accountHistoryModel: Model<AccountHistoryDocument>,
        private authService: AuthService,
    ) {
        this.registerAuthEvents();

        UsersService.addOnUsernameChangeCallback(async (oldUsername: Username, newUsername: Username) => {
            await this.accountHistoryModel.updateMany({ username: oldUsername }, { username: newUsername });
        });
    }
    async logAccountEvent(username: Username, action: AccountAction): Promise<void> {
        const logAction = new this.accountHistoryModel({
            username,
            action,
        });
        await logAction.save();
    }
    async findAll(): Promise<AccountHistoryDocument[]> {
        return this.accountHistoryModel.find();
    }

    async removeAll(): Promise<void> {
        await this.accountHistoryModel.collection.drop();
    }

    async findByUsername(username: Username): Promise<AccountHistoryDocument[]> {
        return this.accountHistoryModel.find({ username });
    }

    private registerAuthEvents(): void {
        this.authService.onUserConnect((username) => {
            this.logAccountEvent(username, AccountAction.Login);
        });

        this.authService.onUserDisconnect((username) => {
            this.logAccountEvent(username, AccountAction.Logout);
        });
    }
}
