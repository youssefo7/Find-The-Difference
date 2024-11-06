import { S3Module } from '@app/s3/s3.module';
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { User, userSchema } from './user.schema';
import { UsernameBlacklist, usernameBlacklistSchema } from './username-blacklist.schema';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: User.name, schema: userSchema },
            { name: UsernameBlacklist.name, schema: usernameBlacklistSchema },
        ]),
        S3Module,
    ],
    controllers: [UsersController],
    providers: [UsersService],
    exports: [UsersService],
})
export class UsersModule {}
