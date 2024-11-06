import { AuthModule } from '@app/auth/auth.module';
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { FriendRequests, friendRequestSchema } from './friend-requests.schema';
import { Friends, friendsSchema } from './friend.schema';
import { FriendsController } from './friends.controller';
import { FriendsGateway } from './friends.gateway';
import { FriendsService } from './friends.service';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: FriendRequests.name, schema: friendRequestSchema },
            { name: Friends.name, schema: friendsSchema },
        ]),
        AuthModule,
    ],
    providers: [FriendsGateway, FriendsService],
    exports: [FriendsService],
    controllers: [FriendsController],
})
export class FriendsModule {}
