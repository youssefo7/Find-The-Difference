import { AuthModule } from '@app/auth/auth.module';
import { ChatModule } from '@app/chat/chat.module';
import { GameTemplateModule } from '@app/game-template/game-template.module';
import { HistoryModule } from '@app/history/history.module';
import { UsersModule } from '@app/users/users.module';
import { forwardRef, Module } from '@nestjs/common';
import { GameManagerGateway } from './game-manager.gateway';
import { GameManagerService } from './game-manager.service';

@Module({
    imports: [forwardRef(() => GameTemplateModule), HistoryModule, AuthModule, ChatModule, UsersModule],
    providers: [GameManagerGateway, GameManagerService],
    exports: [GameManagerService],
})
export class GameManagerModule {}
