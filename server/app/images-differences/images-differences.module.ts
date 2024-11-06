import { Module } from '@nestjs/common';
import { ImagesDifferencesController } from './images-differences.controller';
import { ImagesDifferencesService } from './images-differences.service';

@Module({
    controllers: [ImagesDifferencesController],
    providers: [ImagesDifferencesService],
    exports: [ImagesDifferencesService],
})
export class ImagesDifferencesModule {}
