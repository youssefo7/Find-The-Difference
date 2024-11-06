import { ReceiveReplayDto } from '@common/replay.dto';
import { DEFAULT_THEME, Theme } from '@common/theme.dto';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { ApiHideProperty, ApiProperty } from '@nestjs/swagger';
import { Document } from 'mongoose';

export type UserDocument = User & Document;

@Schema()
export class User {
    @ApiHideProperty()
    @Prop({ required: true })
    passwordHash: string;

    @ApiProperty()
    @Prop({ required: true, unique: true })
    username: string;

    @ApiProperty({ description: 'URL of the user avatar image' })
    @Prop({ required: true })
    avatarUrl: string;

    @ApiProperty()
    @Prop({ required: true, default: 'en' })
    locale: string;

    @ApiProperty()
    @Prop({ required: true, default: DEFAULT_THEME })
    theme: Theme;

    @ApiProperty()
    @Prop({ required: true, default: [] })
    differencesFound: number[];

    @ApiProperty()
    @Prop({ required: true, default: [] })
    replays: ReceiveReplayDto[]; // Do NOT update the username in this Dto on changeUsername!!

    @ApiProperty()
    @Prop({
        required: true,
        default: 50,
        min: 0,
    })
    balance: number;

    @ApiProperty()
    @Prop({ required: true, default: [] })
    inventory: string[];
}

export const userSchema = SchemaFactory.createForClass(User);
