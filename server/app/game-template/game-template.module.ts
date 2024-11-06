import { ImagesDifferencesModule } from '@app/images-differences/images-differences.module';
import { S3Module } from '@app/s3/s3.module';
import { WaitingGamesModule } from '@app/waiting-games/waiting-games.module';
import { forwardRef, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { GameTemplateController } from './game-template.controller';
import { GameTemplate, gameTemplateSchema } from './game-template.schema';
import { GameTemplateService } from './game-template.service';
import { HighScore, highScoreSchema } from './high-score.schema';

@Module({
    imports: [
        ImagesDifferencesModule,
        S3Module,
        MongooseModule.forFeature([
            { name: GameTemplate.name, schema: gameTemplateSchema },
            { name: HighScore.name, schema: highScoreSchema },
        ]),
        forwardRef(() => WaitingGamesModule),
    ],
    controllers: [GameTemplateController],
    providers: [GameTemplateService],
    exports: [GameTemplateService],
})
export class GameTemplateModule {}
