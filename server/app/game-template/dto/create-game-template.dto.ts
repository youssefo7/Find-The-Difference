import { POSSIBLE_RADIUS_VALUES } from '@common/constants';
import { CreateGameDto } from '@common/game-template';
import { GAME_TEMPLATE_NAME_MAX_LENGTH } from '@common/game-template.constants';
import { IsBase64, Max, MaxLength, Min } from 'class-validator';

export class ServerCreateGameDto implements CreateGameDto {
    @MaxLength(GAME_TEMPLATE_NAME_MAX_LENGTH)
    name: string;

    @IsBase64()
    firstImage: string;

    @IsBase64()
    secondImage: string;

    @Min(POSSIBLE_RADIUS_VALUES[0])
    @Max(POSSIBLE_RADIUS_VALUES[3])
    radius: number;

    @Min(0)
    price: number;
}
