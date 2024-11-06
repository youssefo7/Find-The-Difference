import { Difficulty, Vec2 } from '@common/game-template';
import { DifferencesGroups } from '@common/images-differences';
import { Username } from '@common/ingame-ids.types';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiHideProperty, ApiProperty } from '@nestjs/swagger';
import { Document, ObjectId } from 'mongoose';

export type GameTemplateDocument = GameTemplate & Document;

@Schema()
export class GameTemplate {
    @Prop({ required: true })
    name: string;

    @Prop({ required: true, default: false })
    deleted: boolean;

    @Prop({ required: true })
    difficulty: Difficulty;

    @Prop({ required: true })
    firstImage: string;

    @Prop({ required: true })
    secondImage: string;

    @Prop({ required: true })
    price: number;

    @Prop({ required: true })
    creator: Username;

    @ApiHideProperty()
    @Prop({ required: true })
    groupToPixels: Vec2[][];

    @Prop({ required: true })
    nGroups: number;

    @ApiHideProperty()
    @Prop({ required: true })
    pixelToGroup: DifferencesGroups;

    @ApiProperty({ type: String })
    _id: ObjectId;
}

export const gameTemplateSchema = SchemaFactory.createForClass(GameTemplate);
