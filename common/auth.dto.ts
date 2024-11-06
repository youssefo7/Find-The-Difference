import { Username } from './ingame-ids.types';

export class JwtTokenDto {
    accessToken: string;
}

// https://en.wikipedia.org/wiki/JSON_Web_Token#Standard_fields
export class JwtPayloadDto {
    iss: string;
    sub: Username;
    iat: number;
    exp: number;
}
