import { Username } from '@common/ingame-ids.types';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { Document } from 'mongoose';

export type FriendRequestsDocument = FriendRequests & Document;

@Schema()
export class FriendRequests {
    @ApiProperty()
    @Prop({ required: true })
    source: Username;

    @ApiProperty()
    @Prop({ required: true })
    destination: Username;

    @ApiProperty()
    @Prop({ required: true, default: false })
    seen: boolean;
}

export const friendRequestSchema = SchemaFactory.createForClass(FriendRequests);
friendRequestSchema.index({ source: 1, destination: 1 }, { unique: true });
