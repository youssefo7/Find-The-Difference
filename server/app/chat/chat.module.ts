import { AuthModule } from '@app/auth/auth.module';
import { UsersModule } from '@app/users/users.module';
import { Module } from '@nestjs/common';
import { ChatController } from './chat.controller';
import { ChatGateway } from './chat.gateway';
import { ChatService } from './chat.service';

@Module({
    providers: [ChatGateway, ChatService],
    imports: [AuthModule, UsersModule],
    exports: [ChatGateway, ChatService],
    controllers: [ChatController],
})
export class ChatModule {}
