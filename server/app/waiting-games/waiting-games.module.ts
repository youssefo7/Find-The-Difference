import { AuthModule } from '@app/auth/auth.module';
import { ChatModule } from '@app/chat/chat.module';
import { GameManagerModule } from '@app/game-manager/game-manager.module';
import { Module, forwardRef } from '@nestjs/common';
import { WaitingGamesGateway } from './waiting-games.gateway';
import { WaitingGamesService } from './waiting-games.service';

@Module({
    imports: [AuthModule, forwardRef(() => GameManagerModule), ChatModule],
    providers: [WaitingGamesGateway, WaitingGamesService],
    exports: [WaitingGamesService],
})
export class WaitingGamesModule {}
