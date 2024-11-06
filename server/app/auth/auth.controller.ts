import { JwtPayloadDto, JwtTokenDto } from '@common/auth.dto';
import { ErrorMessage, ErrorResponseDto } from '@common/error-response.dto';
import { Body, Controller, Get, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { ApiBadRequestResponse, ApiConflictResponse, ApiNotFoundResponse, ApiOkResponse, ApiTags, ApiUnauthorizedResponse } from '@nestjs/swagger';
import { HttpAuth, Jwt } from './auth.decorator';
import { AuthService } from './auth.service';
import { ChangePasswordDto } from './dto/change-password.dto';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginDto } from './dto/login.dto';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) {}

    @ApiBadRequestResponse({ description: ErrorMessage.UserConnected, type: ErrorResponseDto })
    @ApiNotFoundResponse({ description: ErrorMessage.UserNotFound, type: ErrorResponseDto })
    @ApiUnauthorizedResponse({ description: ErrorMessage.PasswordInvalid, type: ErrorResponseDto })
    @HttpCode(HttpStatus.OK)
    @ApiOkResponse({ type: JwtTokenDto })
    @Post('login')
    async signIn(@Body() signInDto: LoginDto): Promise<JwtTokenDto> {
        return this.authService.signIn(signInDto);
    }

    @ApiConflictResponse({ description: ErrorMessage.UserExists + ' or ' + ErrorMessage.UserConnected, type: ErrorResponseDto })
    @ApiNotFoundResponse({ description: ErrorMessage.UserNotFound, type: ErrorResponseDto })
    @ApiUnauthorizedResponse({ description: ErrorMessage.PasswordInvalid, type: ErrorResponseDto })
    @HttpCode(HttpStatus.OK)
    @ApiOkResponse({ type: JwtTokenDto })
    @Post('register')
    async register(@Body() user: CreateUserDto) {
        return this.authService.register(user);
    }

    @HttpAuth()
    @HttpCode(HttpStatus.OK)
    @ApiOkResponse({ type: JwtTokenDto })
    @Get('refresh-jwt')
    async refreshJwt(@Jwt() jwt: JwtPayloadDto): Promise<JwtTokenDto> {
        return this.authService.refreshJwt(jwt);
    }

    @HttpAuth()
    @ApiNotFoundResponse({ description: ErrorMessage.UserNotFound, type: ErrorResponseDto })
    @HttpCode(HttpStatus.OK)
    @Post('changePassword')
    async changePassword(@Jwt() jwt: JwtPayloadDto, @Body() newPassword: ChangePasswordDto) {
        return this.authService.changePassword(jwt.sub, newPassword.password);
    }
}
