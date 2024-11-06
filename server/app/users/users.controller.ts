import { HttpAuth, Jwt } from '@app/auth/auth.decorator';
import { JwtPayloadDto } from '@common/auth.dto';
import { ErrorMessage, ErrorResponseDto } from '@common/error-response.dto';
import { LocaleDto } from '@common/locale.dto';
import { ReceiveReplayDto, ReplayId, SendReplayDto } from '@common/replay.dto';
import { Theme } from '@common/theme.dto';
import { ChangeAvatarDto, UserDto } from '@common/user.dto';
import { UsernameDto } from '@common/websocket/all-events.dto';
import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { ApiConflictResponse, ApiTags } from '@nestjs/swagger';
import { UserDocument } from './user.schema';
import { UsersService } from './users.service';
import { DifferenceFoundRatioDto } from '@common/statistics.dto';

@ApiTags('Users')
@Controller('user')
export class UsersController {
    constructor(private readonly usersService: UsersService) {}

    @Get()
    async findAll(): Promise<UserDocument[]> {
        return this.usersService.findAll();
    }

    @HttpAuth()
    @Get('profile')
    async getProfile(@Jwt() jwt: JwtPayloadDto): Promise<UserDto | undefined> {
        return (await this.usersService.getProfile(jwt.sub)) ?? undefined;
    }

    @HttpAuth()
    @Get('theme')
    async findTheme(@Jwt() jwt: JwtPayloadDto) {
        return await this.usersService.findTheme(jwt.sub);
    }

    @HttpAuth()
    @Get('stats/:username')
    async getStatistics(@Param('username') username: string) {
        return this.usersService.getDifferencesFound(username);
    }

    @HttpAuth()
    @Get('balance')
    async getBalance(@Jwt() jwt: JwtPayloadDto): Promise<number | undefined> {
        return this.usersService.getUserBalance(jwt.sub);
    }

    @HttpAuth()
    @Patch('stats')
    async updateDifferencesFoundPercentage(@Jwt() jwt: JwtPayloadDto, @Body() differencesFound: DifferenceFoundRatioDto) {
        return await this.usersService.updateDifferencesFound(jwt.sub, differencesFound.differenceFound);
    }

    @HttpAuth()
    @Patch('theme')
    async updateTheme(@Jwt() jwt: JwtPayloadDto, @Body() updateThemeDto: Theme) {
        return await this.usersService.updateTheme(jwt.sub, updateThemeDto);
    }

    @HttpAuth()
    @Get('replays')
    async getReplays(@Jwt() jwt: JwtPayloadDto): Promise<ReceiveReplayDto[] | undefined> {
        return (await this.usersService.getReplays(jwt.sub))?.replays;
    }

    @HttpAuth()
    @Post('addReplay')
    async addReplay(@Jwt() jwt: JwtPayloadDto, @Body() replayDto: SendReplayDto) {
        return await this.usersService.addReplay(jwt.sub, replayDto);
    }

    @HttpAuth()
    @Delete('deleteReplay/:replayId')
    async deleteReplay(@Jwt() jwt: JwtPayloadDto, @Param('replayId') replayId: ReplayId) {
        return await this.usersService.deleteReplay(jwt.sub, replayId);
    }

    @HttpAuth()
    @Get('locale')
    async findLocale(@Jwt() jwt: JwtPayloadDto) {
        return (await this.usersService.findLocale(jwt.sub)) ?? undefined;
    }

    @HttpAuth()
    @Patch('locale')
    async updateLocale(@Jwt() jwt: JwtPayloadDto, @Body() updateLocaleDto: LocaleDto) {
        return await this.usersService.updateLocale(jwt.sub, updateLocaleDto.locale);
    }

    @HttpAuth()
    @ApiConflictResponse({ description: ErrorMessage.UserExists, type: ErrorResponseDto })
    @Patch('username')
    async updateUsername(@Jwt() jwt: JwtPayloadDto, @Body() usernameDto: UsernameDto) {
        return await this.usersService.updateUsername(jwt.sub, usernameDto.username);
    }

    @HttpAuth()
    @Patch('change-avatar')
    async changeAvatar(@Jwt() jwt: JwtPayloadDto, @Body() changeAvatarDto: ChangeAvatarDto) {
        return this.usersService.changeAvatar(jwt.sub, changeAvatarDto.avatarUrl);
    }
}
