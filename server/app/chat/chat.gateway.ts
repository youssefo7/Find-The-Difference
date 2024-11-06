import { Jwt } from '@app/auth/auth.decorator';
import { AuthGuard } from '@app/auth/auth.guard';
import { JwtPayloadDto } from '@common/auth.dto';
import { UseGuards } from '@nestjs/common';
import { MessageBody, SubscribeMessage, WebSocketGateway } from '@nestjs/websockets';
import { ChatEvent, ClientToServerChatEventsMap } from '@websocket/chat.dto';
import { ChatService } from './chat.service';

@UseGuards(AuthGuard)
@WebSocketGateway({ cors: true })
export class ChatGateway {
    constructor(private readonly chatService: ChatService) {}

    @SubscribeMessage(ChatEvent.CreateChat)
    createChat(@Jwt() jwt: JwtPayloadDto, @MessageBody() data: ClientToServerChatEventsMap[ChatEvent.CreateChat]) {
        this.chatService.createChat(data.name, jwt.sub, false);
    }

    @SubscribeMessage(ChatEvent.DeleteChat)
    deleteChat(@Jwt() jwt: JwtPayloadDto, @MessageBody() data: ClientToServerChatEventsMap[ChatEvent.DeleteChat]) {
        this.chatService.deleteChat(data.chatId, jwt.sub);
    }

    @SubscribeMessage(ChatEvent.JoinChat)
    joinChat(@Jwt() jwt: JwtPayloadDto, @MessageBody() data: ClientToServerChatEventsMap[ChatEvent.JoinChat]) {
        this.chatService.addUserToChat(data.chatId, jwt.sub);
    }

    @SubscribeMessage(ChatEvent.LeaveChat)
    leaveChat(@Jwt() jwt: JwtPayloadDto, @MessageBody() data: ClientToServerChatEventsMap[ChatEvent.LeaveChat]) {
        this.chatService.removeUserFromChat(data.chatId, jwt.sub);
    }

    @SubscribeMessage(ChatEvent.Message)
    message(@Jwt() jwt: JwtPayloadDto, @MessageBody() data: ClientToServerChatEventsMap[ChatEvent.Message]) {
        this.chatService.addMessageToChat(data.chatId, jwt.sub, data.content);
    }
}
