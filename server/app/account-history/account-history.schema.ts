import { Username } from '@common/ingame-ids.types';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type AccountHistoryDocument = AccountHistory & Document;

@Schema()
export class AccountHistory {
    @Prop({ required: true })
    username: Username;

    @Prop({ required: true })
    action: string;

    @Prop({ required: true, default: Date.now })
    timestamp: number;
}

export const accountHistorySchema = SchemaFactory.createForClass(AccountHistory);
