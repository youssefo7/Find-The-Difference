import { Jwt } from '@app/auth/auth.decorator';
import { AuthGuard } from '@app/auth/auth.guard';
import { AuthService } from '@app/auth/auth.service';
import { JwtPayloadDto } from '@common/auth.dto';
import { IdentifyDifferenceDto, InGameEvent, SendHintDto } from '@common/websocket/in-game.dto';
import { MarketEvent } from '@common/websocket/market.dto';
import { JoinGameDto } from '@common/websocket/waiting-room.dto';
import { Logger, UseFilters, UseGuards, UsePipes, ValidationError, ValidationPipe } from '@nestjs/common';
import {
    BaseWsExceptionFilter,
    MessageBody,
    OnGatewayConnection,
    OnGatewayDisconnect,
    SubscribeMessage,
    WebSocketGateway,
    WsException,
    WsResponse,
} from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { GameManagerService } from './game-manager.service';

export const exceptionFactory = (err: ValidationError[]) => new WsException(err);

@UseGuards(AuthGuard)
@UsePipes(new ValidationPipe({ exceptionFactory }))
@UseFilters(new BaseWsExceptionFilter())
@WebSocketGateway({ cors: true })
export class GameManagerGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private readonly logger = new Logger(GameManagerGateway.name);

    constructor(
        private readonly gameManagerService: GameManagerService,
        private readonly authService: AuthService,
    ) {
        this.authService.onUserDisconnect((username) => this.gameManagerService.quitGame(username));
    }

    @SubscribeMessage(MarketEvent.BuyHint)
    buyHint(@Jwt() jwt: JwtPayloadDto): void {
        this.gameManagerService.buyHint(jwt.sub);
    }

    @SubscribeMessage(InGameEvent.JoinGameObserver)
    joinGameObserver(@MessageBody() joinGameDto: JoinGameDto, @Jwt() jwt: JwtPayloadDto): void {
        this.gameManagerService.joinGameObserver(jwt.sub, joinGameDto.instanceId);
    }

    @SubscribeMessage(InGameEvent.LeaveGame)
    async leave(@Jwt() jwt: JwtPayloadDto): Promise<void> {
        await this.gameManagerService.quitGame(jwt.sub);
    }

    @SubscribeMessage(InGameEvent.SendHint)
    async sendHint(@MessageBody() sendHintDto: SendHintDto, @Jwt() jwt: JwtPayloadDto): Promise<void> {
        await this.gameManagerService.sendHint(sendHintDto, jwt.sub);
    }

    @SubscribeMessage(InGameEvent.IdentifyDifference)
    identifyDifference(@MessageBody() difference: IdentifyDifferenceDto, @Jwt() jwt: JwtPayloadDto): WsResponse<IdentifyDifferenceDto> | void {
        const result = this.gameManagerService.identifyDifference(difference, jwt.sub);
        if (!result) return { event: InGameEvent.ShowError, data: difference };
    }

    @SubscribeMessage(InGameEvent.CheatModeEvent)
    enableCheatMode(@Jwt() jwt: JwtPayloadDto): void {
        this.gameManagerService.sendCheatModePixels(jwt.sub);
    }

    handleConnection(socket: Socket) {
        this.logger.log(`Connected to socket: ${socket.id}`);

        socket.use(([event, ...data], next) => {
            this.logger.log(`${socket.id} ${event} ${JSON.stringify(data)}`);
            next();
        });
    }

    handleDisconnect(socket: Socket) {
        this.logger.log(`Disconnected from socket: ${socket.id}`);
    }
}
