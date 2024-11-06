import { AuthGuard, userRoomPrefix } from '@app/auth/auth.guard';
import { UsersService } from '@app/users/users.service';
import { Username } from '@common/ingame-ids.types';
import { UsernameDto } from '@common/websocket/all-events.dto';
import { FriendsEvent } from '@common/websocket/friends.dto';
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Model } from 'mongoose';
import { Server } from 'socket.io';
import { FriendRequests, FriendRequestsDocument } from './friend-requests.schema';
import { Friends, FriendsDocument } from './friend.schema';

@WebSocketGateway({ cors: true })
@Injectable()
export class FriendsService {
    @WebSocketServer() private server: Server;
    constructor(
        @InjectModel(FriendRequests.name) public friendRequestsModel: Model<FriendRequestsDocument>,
        @InjectModel(Friends.name) public friendsModel: Model<FriendsDocument>,
    ) {
        UsersService.addOnUsernameChangeCallback(async (oldUsername: Username, newUsername: Username) => {
            await Promise.all([
                this.friendRequestsModel.updateMany({ source: oldUsername }, { source: newUsername }),
                this.friendRequestsModel.updateMany({ destination: oldUsername }, { destination: newUsername }),
                this.friendsModel.updateMany({ user1: oldUsername }, { user1: newUsername }),
                this.friendsModel.updateMany({ user2: oldUsername }, { user2: newUsername }),
            ]);
        });
    }

    async refuseOrRemoveFriend(destination: Username, source: Username): Promise<void> {
        const result1 = await this.friendRequestsModel.deleteOne({ source, destination });
        if (result1.deletedCount > 0) {
            // Remove request from self
            return;
        }
        const result2 = await this.friendRequestsModel.deleteOne({ source: destination, destination: source });
        if (result2.deletedCount > 0) {
            // Remove request from other
            this.server.to(userRoomPrefix + destination).emit(FriendsEvent.NotifyFriendRequestRefused, { username: source } as UsernameDto);
            return;
        }
        const result3 = await this.friendsModel.deleteOne(this.orderFriend(destination, source));
        if (result3.deletedCount > 0) {
            // End friendship :'(
            this.server.to(userRoomPrefix + destination).emit(FriendsEvent.NotifyFriendRemoved, { username: source } as UsernameDto);
            this.server.to(userRoomPrefix + source).emit(FriendsEvent.NotifyFriendRemoved, { username: destination } as UsernameDto);
            return;
        }
    }

    async requestOrAcceptFriend(destination: Username, source: Username): Promise<void> {
        const friend = await this.friendsModel.exists(this.orderFriend(source, destination));
        if (friend) return; // already friends
        const reverseRequest = await this.friendRequestsModel.findOne(
            { source: destination, destination: source },
            {
                source: 0,
                destination: 0,
            },
        );
        if (reverseRequest) {
            await reverseRequest.deleteOne();
            await new this.friendsModel(this.orderFriend(source, destination)).save(); // add friendship
            this.server.to(userRoomPrefix + destination).emit(FriendsEvent.NotifyNewFriend, { username: source } as UsernameDto);
            this.server.to(userRoomPrefix + source).emit(FriendsEvent.NotifyNewFriend, { username: destination } as UsernameDto);
            return;
        }
        const doc = await new this.friendRequestsModel({ source, destination }).save(); // create friend request
        this.notifyRequest(destination, source, doc);
    }

    async getOutgoingRequests(source: Username): Promise<Username[]> {
        const requests = await this.friendRequestsModel.find({ source }, { destination: 1 }).lean();
        return requests.map((req) => {
            return req.destination;
        });
    }

    async getIncomingFriendRequests(destination: Username): Promise<Username[]> {
        const requests = await this.friendRequestsModel.find({ destination }, { source: 1 }).lean();
        return requests.map((req) => {
            return req.source;
        });
    }

    async getAllFriends(destination: Username): Promise<Username[]> {
        const requests = await this.friendsModel.find({ $or: [{ user1: destination }, { user2: destination }] }, { user1: 1, user2: 1 }).lean();
        return requests.map((req) => {
            return req.user1 === destination ? req.user2 : req.user1;
        });
    }

    async sendNewRequests(destination: Username): Promise<void> {
        const requests = await this.friendRequestsModel.find({ destination, seen: false }, { source: 1 });
        await requests.forEach(async (request) => await this.notifyRequest(destination, request.source, request));
    }

    private async notifyRequest(destination: Username, source: Username, doc: FriendRequestsDocument) {
        if (AuthGuard.isUserConnected(destination)) {
            this.server.to(userRoomPrefix + destination).emit(FriendsEvent.NotifyNewFriendRequest, { username: source } as UsernameDto);
            doc.seen = true;
            doc.save();
        }
    }

    private orderFriend(user1: Username, user2: Username) {
        const sorted = [user1, user2].sort();
        return { user1: sorted[0], user2: sorted[1] };
    }
}
