import { ErrorMessage, ErrorResponseDto } from '@common/error-response.dto';
import { Body, Controller, Post } from '@nestjs/common';
import { ApiBadRequestResponse, ApiTags } from '@nestjs/swagger';
import { ServerCreateDiffResult } from './dto/create-diff-result.dto';
import { CreateImagesDifferencesDto } from './dto/create-images-differences.dto';
import { ImagesDifferencesService } from './images-differences.service';

@ApiTags('Images Differences')
@Controller('images-differences')
export class ImagesDifferencesController {
    constructor(private readonly imagesDifferencesService: ImagesDifferencesService) {}

    @ApiBadRequestResponse({ description: ErrorMessage.ImageInvalid, type: ErrorResponseDto })
    @Post()
    async createDiffImage(@Body() createImagesDifferencesDto: CreateImagesDifferencesDto): Promise<ServerCreateDiffResult> {
        const diff = await this.imagesDifferencesService.computeDiff(createImagesDifferencesDto);
        return {
            difficulty: diff.difficulty,
            nGroups: diff.nGroups,
            diffImage: await this.imagesDifferencesService.toBlackAndWhite(diff),
        };
    }
}
