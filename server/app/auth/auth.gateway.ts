import { exceptionFactory } from '@app/game-manager/game-manager.gateway';
import { UseFilters, UseGuards, UsePipes, ValidationPipe } from '@nestjs/common';
import { BaseWsExceptionFilter, OnGatewayConnection, OnGatewayDisconnect, WebSocketGateway } from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { AuthGuard } from './auth.guard';
import { AuthService } from './auth.service';

@UseGuards(AuthGuard)
@UsePipes(new ValidationPipe({ exceptionFactory }))
@UseFilters(new BaseWsExceptionFilter())
@WebSocketGateway({ cors: true })
export class AuthGateway implements OnGatewayConnection, OnGatewayDisconnect {
    constructor(private readonly authService: AuthService) {}

    handleConnection(client: Socket) {
        this.authService.connectWs(client);
    }
    handleDisconnect(client: Socket) {
        this.authService.disconnectWs(client);
    }
}
