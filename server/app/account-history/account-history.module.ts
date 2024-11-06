import { AuthModule } from '@app/auth/auth.module';
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AccountHistoryController } from './account-history.controller';
import { AccountHistory, accountHistorySchema } from './account-history.schema';
import { AccountHistoryService } from './account-history.service';

@Module({
    imports: [AuthModule, MongooseModule.forFeature([{ name: AccountHistory.name, schema: accountHistorySchema }])],
    controllers: [AccountHistoryController],
    providers: [AccountHistoryService],
    exports: [AccountHistoryService],
})
export class AccountHistoryModule {}
