import { Username } from '@common/ingame-ids.types';

export class CreateUserDto {
    username: Username;
    avatarUrl: string;
    password: string;
}
