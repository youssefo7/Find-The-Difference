import { GameTemplateService } from '@app/game-template/game-template.service';
import { UsersService } from '@app/users/users.service';
import { ErrorMessage } from '@common/error-response.dto';
import { GameTemplate } from '@common/game-template';
import { GameTemplateId, Username } from '@common/ingame-ids.types';
import { Inject, Injectable, NotFoundException, forwardRef } from '@nestjs/common';

@Injectable()
export class MarketService {
    constructor(
        @Inject(forwardRef(() => GameTemplateService)) private gameTemplateService: GameTemplateService,
        @Inject(forwardRef(() => UsersService)) private usersService: UsersService,
    ) {}

    async buyGame(client: Username, gameId: GameTemplateId): Promise<void> {
        const gamePrice = await this.gameTemplateService.getPrice(gameId);
        const seller = await this.gameTemplateService.getCreator(gameId);
        if (gamePrice !== undefined && seller) {
            await this.usersService.updateUserBalance(client, -gamePrice, async () => {
                await this.usersService.updateUserBalance(seller, gamePrice, () => undefined);
                await this.usersService.updateUserInventory(client, gameId);
            });
        }
    }

    async getBuyableGames(client: Username): Promise<GameTemplate[]> {
        const inventory = await this.usersService.getUserInventory(client);
        if (inventory) {
            return this.gameTemplateService.getBuyableGames(client, inventory);
        }
        throw new NotFoundException(ErrorMessage.UserNotFound);
    }

    async getAvailableGames(client: Username): Promise<GameTemplate[]> {
        const inventory = await this.usersService.getUserInventory(client);
        if (inventory) {
            return this.gameTemplateService.getAvailableGames(client, inventory);
        }
        throw new NotFoundException(ErrorMessage.UserNotFound);
    }
}
