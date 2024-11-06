import { ErrorMessage } from '@common/error-response.dto';
import { Username } from '@common/ingame-ids.types';
import { CanActivate, ExecutionContext, Injectable, NotImplementedException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { WsException } from '@nestjs/websockets';
import { Request } from 'express';
import { Socket } from 'socket.io';

export const userRoomPrefix = 'UserRoom';
type SocketId = string;

@Injectable()
export class AuthGuard implements CanActivate {
    private static connectedUsers: Map<Username, SocketId> = new Map<Username, SocketId>();
    constructor(private jwtService: JwtService) {}

    static isUserConnected(username: Username) {
        return this.connectedUsers.has(username);
    }

    static connectUser(username: Username, socket: Socket) {
        if (this.isUserConnected(username)) return false;
        this.connectedUsers.set(username, socket.id);
        socket.join(userRoomPrefix + username);
        return true;
    }

    static disconnectUser(username: Username, socket: Socket) {
        if (!this.isUserConnected(username)) return false;
        if (this.connectedUsers.get(username) !== socket.id) return false;
        return this.connectedUsers.delete(username);
    }

    static extractTokenFromHeadersWs(context: Socket): string | undefined {
        const [type, token] = context.handshake.headers.authorization?.split(' ') ?? [];
        return type === 'Bearer' ? token : undefined;
    }
    static extractTokenFromHeadersHttp(context: Request): string | undefined {
        const [type, token] = context.headers.authorization?.split(' ') ?? [];
        return type === 'Bearer' ? token : undefined;
    }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const [request, token] = this.extractRequestFromContext(context);
        if (!token || !request) {
            this.throwError(context);
        }
        try {
            const payload = await this.jwtService.verifyAsync(token as string, { ignoreExpiration: true });
            // We're assigning the payload to the request object here
            // so that we can access it in our route handlers
            (request as unknown as { jwt: unknown })['jwt'] = payload;
        } catch {
            this.throwError(context);
        }
        return true;
    }

    private extractRequestFromContext(context: ExecutionContext) {
        if (context.getType() === 'ws') {
            const socket: Socket = context.switchToWs().getClient();
            return [socket, AuthGuard.extractTokenFromHeadersWs(socket)];
        } else if (context.getType() === 'http') {
            const request: Request = context.switchToHttp().getRequest();
            return [request, AuthGuard.extractTokenFromHeadersHttp(request)];
        } else {
            throw new NotImplementedException();
        }
    }

    private throwError(context: ExecutionContext) {
        if (context.getType() === 'ws') {
            throw new WsException('Auth failure');
        } else if (context.getType() === 'http') {
            throw new UnauthorizedException(ErrorMessage.JwtMissing);
        } else {
            throw new NotImplementedException();
        }
    }
}
