import { Username } from '@common/ingame-ids.types';
import { Controller, Delete, Get, Param } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { History } from './history.schema';
import { HistoryService } from './history.service';

@ApiTags('History')
@Controller('history')
export class HistoryController {
    constructor(private readonly historyService: HistoryService) {}

    @Get()
    async findAll(): Promise<History[]> {
        return this.historyService.findAll();
    }

    @Delete()
    async removeAll(): Promise<void> {
        return this.historyService.removeAll();
    }

    @Get(':username')
    async findByUsername(@Param('username') username: Username): Promise<History[]> {
        return this.historyService.findByUsername(username);
    }
}
