import { GameMode } from '@common/game-template';
import { GameTemplateId } from '@common/ingame-ids.types';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiProperty } from '@nestjs/swagger';
import { Document, ObjectId } from 'mongoose';

export type HighScoreDocument = HighScore & Document;

@Schema()
export class HighScore {
    @ApiProperty({ type: String })
    _id: ObjectId;

    @Prop({ required: true })
    time: number;

    @Prop({ required: true })
    gameMode: GameMode;

    @Prop({ required: false, default: null })
    gameTemplateId: GameTemplateId;
}

export const highScoreSchema = SchemaFactory.createForClass(HighScore);
