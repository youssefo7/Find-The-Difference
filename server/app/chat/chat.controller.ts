import { HttpAuth, Jwt } from '@app/auth/auth.decorator';
import { JwtPayloadDto } from '@common/auth.dto';
import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ChatIdSchema, ChatSchema } from './chat.schema';
import { ChatService } from './chat.service';

@ApiTags('Chat')
@Controller('chat')
export class ChatController {
    constructor(private readonly chatService: ChatService) {}

    @HttpAuth()
    @Get('available-chats')
    getAvailableChats(@Jwt() jwt: JwtPayloadDto): ChatSchema[] {
        return this.chatService.getAvailableChats(jwt.sub);
    }

    @HttpAuth()
    @Get('joined-chats')
    getJoinedChats(@Jwt() jwt: JwtPayloadDto): ChatIdSchema[] {
        return this.chatService.getJoinedChats(jwt.sub);
    }

    @HttpAuth()
    @Get('general-chat-id')
    getGeneralChatId(): ChatIdSchema {
        return { chatId: this.chatService.generalChatId };
    }
}
