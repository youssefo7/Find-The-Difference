import { Jwt } from '@app/auth/auth.decorator';
import { AuthGuard } from '@app/auth/auth.guard';
import { AuthService } from '@app/auth/auth.service';
import { JwtPayloadDto } from '@common/auth.dto';
import { UsernameDto } from '@common/websocket/all-events.dto';
import { InGameEvent } from '@common/websocket/in-game.dto';
import { ChangeTeamDto, InstantiateGameDto, JoinGameDto, WaitingRoomEvent } from '@common/websocket/waiting-room.dto';
import { UseFilters, UseGuards, UsePipes, ValidationError, ValidationPipe } from '@nestjs/common';
import { BaseWsExceptionFilter, MessageBody, SubscribeMessage, WebSocketGateway, WsException } from '@nestjs/websockets';
import { WaitingGamesService } from './waiting-games.service';

export const exceptionFactory = (err: ValidationError[]) => new WsException(err);

@UseGuards(AuthGuard)
@UsePipes(new ValidationPipe({ exceptionFactory }))
@UseFilters(new BaseWsExceptionFilter())
@WebSocketGateway({ cors: true })
export class WaitingGamesGateway {
    constructor(
        private readonly waitingGamesService: WaitingGamesService,
        private readonly authService: AuthService,
    ) {
        this.authService.onUserDisconnect((username) => this.waitingGamesService.quitWaitingInstance(username));
    }

    @SubscribeMessage(InGameEvent.LeaveGame)
    async leave(@Jwt() jwt: JwtPayloadDto): Promise<void> {
        await this.waitingGamesService.quitWaitingInstance(jwt.sub);
    }

    @SubscribeMessage(WaitingRoomEvent.JoinGame)
    async join(@MessageBody() joinGameDto: JoinGameDto, @Jwt() jwt: JwtPayloadDto): Promise<void> {
        await this.waitingGamesService.join(joinGameDto, jwt.sub);
    }

    @SubscribeMessage(WaitingRoomEvent.InstantiateGame)
    async instantiate(@MessageBody() instantiateGameDto: InstantiateGameDto, @Jwt() jwt: JwtPayloadDto): Promise<void> {
        await this.waitingGamesService.instantiate(instantiateGameDto, jwt.sub);
    }

    @SubscribeMessage(WaitingRoomEvent.ApprovePlayer)
    approvePlayer(@MessageBody() usernameDto: UsernameDto, @Jwt() jwt: JwtPayloadDto): void {
        this.waitingGamesService.approvePlayer(usernameDto.username, jwt.sub);
    }

    @SubscribeMessage(WaitingRoomEvent.RejectPlayer)
    rejectPlayer(@MessageBody() usernameDto: UsernameDto, @Jwt() jwt: JwtPayloadDto): void {
        this.waitingGamesService.rejectPlayer(usernameDto.username, jwt.sub);
    }

    @SubscribeMessage(WaitingRoomEvent.GetWaitingGames)
    getWaitingGames(@Jwt() jwt: JwtPayloadDto): void {
        this.waitingGamesService.sendWaitingGames(jwt.sub);
    }

    @SubscribeMessage(WaitingRoomEvent.EndSelection)
    async endSelection(@Jwt() jwt: JwtPayloadDto): Promise<void> {
        this.waitingGamesService.endSelection(jwt.sub);
    }

    @SubscribeMessage(WaitingRoomEvent.ChangeTeam)
    async changeTeam(@MessageBody() changeTeamDto: ChangeTeamDto, @Jwt() jwt: JwtPayloadDto): Promise<void> {
        await this.waitingGamesService.changeTeam(jwt.sub, changeTeamDto.newTeam);
    }
}
