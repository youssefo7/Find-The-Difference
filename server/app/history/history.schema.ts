import { GameMode } from '@common/game-template';
import { HistoryDto } from '@common/history';
import { Username } from '@common/ingame-ids.types';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { Document } from 'mongoose';

export type HistoryDocument = History & Document;

@Schema()
export class History implements HistoryDto {
    @ApiProperty()
    @Prop({ required: true })
    startTime: number;

    @ApiProperty()
    @Prop({ required: true })
    totalTime: number;

    @ApiProperty()
    @Prop({ required: true })
    gameMode: GameMode;

    @ApiProperty()
    @Prop({ required: true })
    winners: Username[];

    @ApiProperty()
    @Prop({ required: true })
    losers: Username[];

    @ApiProperty()
    @Prop({ required: true })
    quitters: Username[];
}

export const historySchema = SchemaFactory.createForClass(History);
