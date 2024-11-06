import { HttpAuth, Jwt } from '@app/auth/auth.decorator';
import { JwtPayloadDto } from '@common/auth.dto';
import { Username } from '@common/ingame-ids.types';
import { Controller, Get, HttpCode, HttpStatus, Param } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { FriendsService } from './friends.service';

@ApiTags('Friends')
@Controller('friends')
export class FriendsController {
    constructor(private readonly friendService: FriendsService) {}

    @HttpAuth()
    @HttpCode(HttpStatus.OK)
    @Get('friend-list')
    async getFriendList(@Jwt() jwt: JwtPayloadDto) {
        return this.friendService.getAllFriends(jwt.sub);
    }

    @HttpAuth()
    @HttpCode(HttpStatus.OK)
    @Get('friend-list/:username')
    async getFriendListByUsername(@Param('username') username: Username) {
        return this.friendService.getAllFriends(username);
    }

    @HttpAuth()
    @HttpCode(HttpStatus.OK)
    @Get('outgoing-request-list')
    async getOutgoingRequestList(@Jwt() jwt: JwtPayloadDto) {
        return this.friendService.getOutgoingRequests(jwt.sub);
    }

    @HttpAuth()
    @HttpCode(HttpStatus.OK)
    @Get('incoming-request-list')
    async getIncomingRequestList(@Jwt() jwt: JwtPayloadDto) {
        return this.friendService.getIncomingFriendRequests(jwt.sub);
    }
}
