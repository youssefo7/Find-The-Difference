import { UsersModule } from '@app/users/users.module';
import { JWT_EXPIRATION_TIME_SECONDS } from '@common/constants';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import os from 'os';
import { AuthController } from './auth.controller';
import { AuthGateway } from './auth.gateway';
import { AuthService } from './auth.service';

@Module({
    imports: [
        UsersModule,
        JwtModule.registerAsync({
            global: true,
            imports: [ConfigModule],
            useFactory: async (configService: ConfigService) => {
                return {
                    secret: configService.getOrThrow('JWT_SECRET'),
                    signOptions: { expiresIn: JWT_EXPIRATION_TIME_SECONDS, issuer: os.hostname() },
                };
            },
            inject: [ConfigService],
        }),
    ],
    providers: [AuthService, AuthGateway],
    controllers: [AuthController],
    exports: [AuthService],
})
export class AuthModule {}
