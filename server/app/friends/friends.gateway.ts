import { Jwt } from '@app/auth/auth.decorator';
import { AuthGuard } from '@app/auth/auth.guard';
import { AuthService } from '@app/auth/auth.service';
import { exceptionFactory } from '@app/game-manager/game-manager.gateway';
import { JwtPayloadDto } from '@common/auth.dto';
import { UsernameDto } from '@common/websocket/all-events.dto';
import { FriendsEvent } from '@common/websocket/friends.dto';
import { Logger, UseFilters, UseGuards, UsePipes, ValidationPipe } from '@nestjs/common';
import { BaseWsExceptionFilter, MessageBody, SubscribeMessage, WebSocketGateway } from '@nestjs/websockets';
import { FriendsService } from './friends.service';

@UseGuards(AuthGuard)
@UsePipes(new ValidationPipe({ exceptionFactory }))
@UseFilters(new BaseWsExceptionFilter())
@WebSocketGateway({ cors: true })
export class FriendsGateway {
    private readonly logger = new Logger(FriendsGateway.name);

    constructor(
        private readonly friendService: FriendsService,
        private readonly authService: AuthService,
    ) {
        this.authService.onUserConnect(async (username) => this.friendService.sendNewRequests(username));
    }

    @SubscribeMessage(FriendsEvent.RefuseOrRemoveFriend)
    refuseOrRemoveFriend(@MessageBody() payload: UsernameDto, @Jwt() jwt: JwtPayloadDto): void {
        try {
            this.friendService.refuseOrRemoveFriend(payload.username, jwt.sub);
        } catch {
            this.logger.error(`refuseOrRemoveFriend ${payload.username} ${jwt.sub}`);
        }
    }

    @SubscribeMessage(FriendsEvent.RequestOrAcceptFriend)
    requestOrAcceptFriend(@MessageBody() payload: UsernameDto, @Jwt() jwt: JwtPayloadDto): void {
        try {
            this.friendService.requestOrAcceptFriend(payload.username, jwt.sub);
        } catch {
            this.logger.error(`requestOrAcceptFriend ${payload.username} ${jwt.sub}`);
        }
    }
}
