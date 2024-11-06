import { UsersService } from '@app/users/users.service';
import { JwtPayloadDto, JwtTokenDto } from '@common/auth.dto';
import { ADMIN_PASSWORD, ADMIN_USERNAME, MS_PER_SECOND } from '@common/constants';
import { ErrorMessage } from '@common/error-response.dto';
import { Username } from '@common/ingame-ids.types';
import { ConflictException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { Socket } from 'socket.io';
import { AuthGuard } from './auth.guard';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
    private onUserSocketAuthConnect: ((user: Username) => void)[] = [];
    private onUserSocketAuthDisconnect: ((user: Username) => void)[] = [];
    private saltRounds: number;

    // eslint-disable-next-line max-params
    constructor(
        private usersService: UsersService,
        private jwtService: JwtService,
        configService: ConfigService,
    ) {
        const saltRounds = configService.getOrThrow<string>('SALT_ROUNDS');
        this.saltRounds = Number(saltRounds);
        this.createAdminAccount();
    }

    async changePassword(username: string, newPassword: string) {
        const passwordHash = await bcrypt.hash(newPassword, this.saltRounds);
        await this.usersService.changePassword(username, passwordHash);
    }

    async register(user: CreateUserDto): Promise<JwtTokenDto> {
        const passwordHash = await bcrypt.hash(user.password, this.saltRounds);

        const userAvatarUrl = await this.usersService.setAvatarUrl(user.avatarUrl);

        await this.usersService.create(user.username, passwordHash, userAvatarUrl);

        return this.signIn(user);
    }

    async signIn(login: LoginDto): Promise<JwtTokenDto> {
        const user = await this.usersService.findOne(login.username);
        if (!user) throw new NotFoundException(ErrorMessage.UserNotFound);

        if (AuthGuard.isUserConnected(login.username)) throw new ConflictException(ErrorMessage.UserConnected);
        if (!(await bcrypt.compare(login.password, user.passwordHash))) {
            throw new UnauthorizedException(ErrorMessage.PasswordInvalid);
        }

        return await this.createJwt(user.username);
    }

    async refreshJwt(jwt: JwtPayloadDto): Promise<JwtTokenDto> {
        if (jwt.exp * MS_PER_SECOND <= Date.now()) throw new UnauthorizedException(ErrorMessage.JwtMissing);
        const user = await this.usersService.findOne(jwt.sub);
        if (!user) throw new NotFoundException(ErrorMessage.UserNotFound);

        return await this.createJwt(user.username);
    }

    onUserConnect(callback: (user: Username) => void) {
        this.onUserSocketAuthConnect.push(callback);
    }

    onUserDisconnect(callback: (user: Username) => void) {
        this.onUserSocketAuthDisconnect.push(callback);
    }

    async connectWs(socket: Socket) {
        const token = AuthGuard.extractTokenFromHeadersWs(socket);
        if (!token) {
            socket.disconnect();
        }
        try {
            const payload: JwtPayloadDto = await this.jwtService.verifyAsync(token as string);

            const userExist = await this.usersService.exists(payload.sub);
            if (!userExist) socket.disconnect();

            if (AuthGuard.connectUser(payload.sub, socket)) {
                this.onUserSocketAuthConnect.forEach((fn) => fn(payload.sub));
            } else {
                socket.disconnect();
            }
        } catch {
            socket.disconnect();
        }
    }

    async disconnectWs(socket: Socket) {
        const token = AuthGuard.extractTokenFromHeadersWs(socket);
        if (!token) {
            return;
        }
        try {
            const payload: JwtPayloadDto = await this.jwtService.verifyAsync(token as string, { ignoreExpiration: true });

            const userExist = await this.usersService.exists(payload.sub);
            if (!userExist) return;

            if (AuthGuard.disconnectUser(payload.sub, socket)) {
                this.onUserSocketAuthDisconnect.forEach((fn) => fn(payload.sub));
            }
        } catch {
            return;
        }
    }

    private async createJwt(username: string): Promise<JwtTokenDto> {
        return {
            accessToken: await this.jwtService.signAsync({ sub: username }),
        };
    }

    private async createAdminAccount() {
        const adminUsername = ADMIN_USERNAME;
        const adminAvatarUrl = 'avatars/admin.png';
        const adminPasswordHash = await bcrypt.hash(ADMIN_PASSWORD, this.saltRounds);
        try {
            await this.usersService.create(adminUsername, adminPasswordHash, adminAvatarUrl);
        } catch {
            // Admin already exists
        }
    }
}
