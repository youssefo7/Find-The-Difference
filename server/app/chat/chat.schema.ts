/* eslint-disable max-classes-per-file */
import { ChatId, Username } from '@common/ingame-ids.types';
import { Prop } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { ChatCreatorDto, ChatIdDto, ChatNameDto } from '@websocket/chat.dto';

export class ChatIdSchema implements ChatIdDto {
    @ApiProperty()
    @Prop({ required: true })
    chatId: ChatId;
}

export class ChatSchema implements ChatIdDto, ChatNameDto, ChatCreatorDto {
    @ApiProperty()
    @Prop({ required: true })
    chatId: ChatId;

    @ApiProperty()
    @Prop({ required: true })
    name: string;

    @ApiProperty()
    @Prop({ required: true })
    creator: Username;
}
