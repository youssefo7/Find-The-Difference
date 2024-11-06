import { HttpAuth, Jwt } from '@app/auth/auth.decorator';
import { GameTemplate } from '@app/game-template/game-template.schema';
import { JwtPayloadDto } from '@common/auth.dto';
import { ErrorMessage, ErrorResponseDto } from '@common/error-response.dto';
import { BuyGameDto } from '@common/websocket/market.dto';
import { Body, Controller, Get, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { ApiBadRequestResponse, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { MarketService } from './market.service';

@ApiTags('Market')
@Controller('market')
export class MarketController {
    constructor(private marketService: MarketService) {}

    @HttpAuth()
    @ApiBadRequestResponse({ description: ErrorMessage.DtoInvalid, type: ErrorResponseDto })
    @HttpCode(HttpStatus.OK)
    @Post('buyGame')
    async buyGame(@Jwt() jwt: JwtPayloadDto, @Body() gameId: BuyGameDto) {
        return await this.marketService.buyGame(jwt.sub, gameId.gameTemplateId);
    }

    @HttpAuth()
    @HttpCode(HttpStatus.OK)
    @ApiOkResponse({ type: [GameTemplate] })
    @Get('buyableGames')
    async getBuyableGames(@Jwt() jwt: JwtPayloadDto) {
        return await this.marketService.getBuyableGames(jwt.sub);
    }

    @HttpAuth()
    @HttpCode(HttpStatus.OK)
    @ApiOkResponse({ type: [GameTemplate] })
    @Get('availableGames')
    async getAvailableGames(@Jwt() jwt: JwtPayloadDto) {
        return await this.marketService.getAvailableGames(jwt.sub);
    }
}
