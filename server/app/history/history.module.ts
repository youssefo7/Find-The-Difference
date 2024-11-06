import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { HistoryController } from './history.controller';
import { History, historySchema } from './history.schema';
import { HistoryService } from './history.service';

@Module({
    imports: [MongooseModule.forFeature([{ name: History.name, schema: historySchema }])],
    controllers: [HistoryController],
    providers: [HistoryService],
    exports: [HistoryService],
})
export class HistoryModule {}
