import { ErrorMessage, ErrorResponseDto } from '@common/error-response.dto';
import { ExecutionContext, NotImplementedException, UseGuards, applyDecorators, createParamDecorator } from '@nestjs/common';
import { ApiBearerAuth, ApiUnauthorizedResponse } from '@nestjs/swagger';
import { AuthGuard } from './auth.guard';

// eslint-disable-next-line @typescript-eslint/naming-convention
export const Jwt = createParamDecorator((data: unknown, context: ExecutionContext) => {
    if (context.getType() === 'ws') {
        return context.switchToWs().getClient()['jwt'];
    } else if (context.getType() === 'http') {
        return context.switchToHttp().getRequest()['jwt'];
    } else {
        throw new NotImplementedException();
    }
});

// eslint-disable-next-line @typescript-eslint/naming-convention
export const HttpAuth = () =>
    applyDecorators(UseGuards(AuthGuard), ApiBearerAuth(), ApiUnauthorizedResponse({ description: ErrorMessage.JwtMissing, type: ErrorResponseDto }));
