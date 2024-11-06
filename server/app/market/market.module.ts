import { UsersModule } from '@app/users/users.module';
import { Module } from '@nestjs/common';
import { MarketController } from './market.controller';
import { MarketService } from './market.service';
import { GameTemplateModule } from '@app/game-template/game-template.module';

@Module({
    imports: [UsersModule, GameTemplateModule],
    providers: [MarketService],
    exports: [MarketService],
    controllers: [MarketController],
})
export class MarketModule {}
