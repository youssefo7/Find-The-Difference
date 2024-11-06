import { Username } from '@common/ingame-ids.types';
import { Controller, Delete, Get, Param } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { AccountHistory } from './account-history.schema';
import { AccountHistoryService } from './account-history.service';

@ApiTags('Account History')
@Controller('account-history')
export class AccountHistoryController {
    constructor(private readonly accountHistoryService: AccountHistoryService) {}

    @Get()
    async findAll(): Promise<AccountHistory[]> {
        return this.accountHistoryService.findAll();
    }

    @Delete()
    async removeAll(): Promise<void> {
        return this.accountHistoryService.removeAll();
    }

    @Get(':username')
    async findByUsername(@Param('username') username: Username): Promise<AccountHistory[]> {
        return this.accountHistoryService.findByUsername(username);
    }
}
