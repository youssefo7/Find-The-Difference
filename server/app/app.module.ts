import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AccountHistoryModule } from './account-history/account-history.module';
import { AuthModule } from './auth/auth.module';
import { ChatModule } from './chat/chat.module';
import { FriendsModule } from './friends/friends.module';
import { GameManagerModule } from './game-manager/game-manager.module';
import { GameTemplateModule } from './game-template/game-template.module';
import { HistoryModule } from './history/history.module';
import { ImagesDifferencesModule } from './images-differences/images-differences.module';
import { S3Module } from './s3/s3.module';
import { UsersModule } from './users/users.module';
import { WaitingGamesModule } from './waiting-games/waiting-games.module';
import { MarketModule } from './market/market.module';

@Module({
    imports: [
        ConfigModule.forRoot({ isGlobal: true }),
        MongooseModule.forRootAsync({
            imports: [ConfigModule],
            inject: [ConfigService],
            useFactory: async (configService: ConfigService) => ({
                uri: configService.getOrThrow('DATABASE_CONNECTION_STRING'),
            }),
        }),
        GameTemplateModule,
        GameManagerModule,
        ImagesDifferencesModule,
        HistoryModule,
        AuthModule,
        UsersModule,
        ChatModule,
        FriendsModule,
        S3Module,
        AccountHistoryModule,
        WaitingGamesModule,
        MarketModule,
    ],
})
export class AppModule {}
