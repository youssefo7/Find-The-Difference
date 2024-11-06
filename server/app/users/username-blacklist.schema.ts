import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { Document } from 'mongoose';

export type UsernameBlacklistDocument = UsernameBlacklist & Document;

@Schema()
export class UsernameBlacklist {
    @ApiProperty()
    @Prop({ required: true, unique: true })
    username: string;
}

export const usernameBlacklistSchema = SchemaFactory.createForClass(UsernameBlacklist);
