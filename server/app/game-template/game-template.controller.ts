import { ErrorMessage, ErrorResponseDto } from '@common/error-response.dto';
import { GameTemplateId } from '@common/ingame-ids.types';
import { BadRequestException, Body, Controller, Delete, Get, NotFoundException, Param, Post } from '@nestjs/common';
import { ApiBadRequestResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { isValidObjectId } from 'mongoose';
import { ServerCreateGameDto } from './dto/create-game-template.dto';
import { GameTemplate } from './game-template.schema';
import { GameTemplateService } from './game-template.service';
import { JwtPayloadDto } from '@common/auth.dto';
import { HttpAuth, Jwt } from '@app/auth/auth.decorator';

@ApiTags('Game Template')
@Controller('game-template')
export class GameTemplateController {
    constructor(private readonly gameTemplateService: GameTemplateService) {}

    @ApiOkResponse({ type: [GameTemplate] })
    @Get()
    async findAll() {
        return this.gameTemplateService.findAll();
    }

    @HttpAuth()
    @ApiBadRequestResponse({ description: ErrorMessage.DtoInvalid, type: ErrorResponseDto })
    @Post()
    async create(@Jwt() jwt: JwtPayloadDto, @Body() createGameDto: ServerCreateGameDto) {
        return this.gameTemplateService.create(jwt.sub, createGameDto);
    }

    @ApiOperation({ summary: 'Get the number of game templates that exist' })
    @Get('length')
    async getLength() {
        return this.gameTemplateService.getLength();
    }

    @ApiBadRequestResponse({ description: ErrorMessage.ObjectIdInvalid, type: ErrorResponseDto })
    @ApiNotFoundResponse({ description: ErrorMessage.MissingGameTemplate, type: ErrorResponseDto })
    @ApiOkResponse({ type: GameTemplate })
    @Get(':id')
    async findById(@Param('id') id: GameTemplateId) {
        this.validateObjectId(id);
        const gameTemplate = await this.gameTemplateService.findById(id);

        if (!gameTemplate) {
            throw new NotFoundException(ErrorMessage.MissingGameTemplate);
        }
        return gameTemplate;
    }

    @ApiBadRequestResponse({ description: ErrorMessage.PageNumberInvalid, type: ErrorResponseDto })
    @ApiOkResponse({ type: [GameTemplate] })
    @Get('page/:page')
    async findPage(@Param('page') page: string) {
        const pageNumber = +page;
        if (isNaN(pageNumber) || pageNumber < 0) {
            throw new BadRequestException(ErrorMessage.PageNumberInvalid);
        }
        return this.gameTemplateService.findPage(pageNumber);
    }

    @Delete()
    async removeAll() {
        await this.gameTemplateService.removeAll();
    }

    @ApiBadRequestResponse({ description: ErrorMessage.ObjectIdInvalid, type: ErrorResponseDto })
    @ApiNotFoundResponse({ description: ErrorMessage.MissingGameTemplate, type: ErrorResponseDto })
    @Delete(':id')
    async remove(@Param('id') id: GameTemplateId) {
        this.validateObjectId(id);
        return this.gameTemplateService.remove(id);
    }

    private validateObjectId(id: GameTemplateId): void {
        if (!isValidObjectId(id)) {
            throw new BadRequestException(ErrorMessage.ObjectIdInvalid);
        }
    }
}
