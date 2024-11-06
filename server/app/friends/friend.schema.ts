import { Username } from '@common/ingame-ids.types';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { Document } from 'mongoose';

export type FriendsDocument = Friends & Document;

@Schema()
export class Friends {
    @ApiProperty()
    @Prop({ required: true })
    user1: Username;

    @ApiProperty()
    @Prop({ required: true })
    user2: Username;
}

export const friendsSchema = SchemaFactory.createForClass(Friends);
friendsSchema.index({ user1: 1, user2: 1 }, { unique: true });
