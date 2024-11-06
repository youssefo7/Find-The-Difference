import { PartialType } from '@nestjs/swagger';
import { ServerCreateGameDto } from './create-game-template.dto';

export class UpdateGameDto extends PartialType(ServerCreateGameDto) {}
