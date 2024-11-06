import { ImagesDifferencesForGame } from '@app/game-manager/dto/create-game.dto';
import { ImagesDifferencesService } from '@app/images-differences/images-differences.service';
import { S3Service } from '@app/s3/s3.service';
import { UsersService } from '@app/users/users.service';
import { WaitingGamesService } from '@app/waiting-games/waiting-games.service';
import { ADMIN_USERNAME, GAME_TEMPLATE_PER_PAGE } from '@common/constants';
import { ErrorMessage } from '@common/error-response.dto';
import { GameTemplate as CommonGameTemplate, GameMode } from '@common/game-template';
import { ImagesDifferences } from '@common/images-differences';
import { DEFAULT_RADIUS } from '@common/images-differences.constants';
import { GameTemplateId, Username } from '@common/ingame-ids.types';
import { Inject, Injectable, Logger, NotFoundException, forwardRef } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { readFile } from 'fs/promises';
import { Model } from 'mongoose';
import { ServerCreateGameDto } from './dto/create-game-template.dto';
import { DEFAULT_IMAGES_PATH } from './game-template.constants';
import { GameTemplate, GameTemplateDocument } from './game-template.schema';
import { HighScore, HighScoreDocument } from './high-score.schema';

@Injectable()
export class GameTemplateService {
    private readonly logger = new Logger(GameTemplateService.name);

    // eslint-disable-next-line max-params
    constructor(
        @InjectModel(GameTemplate.name) public gameTemplateModel: Model<GameTemplateDocument>,
        @InjectModel(HighScore.name) public highScoreModel: Model<HighScoreDocument>,
        @Inject(forwardRef(() => WaitingGamesService)) private waitingGamesService: WaitingGamesService,
        private imagesDifferencesService: ImagesDifferencesService,
        private s3Service: S3Service,
    ) {
        this.start();

        UsersService.addOnUsernameChangeCallback(async (oldUsername: Username, newUsername: Username) => {
            await this.gameTemplateModel.updateMany({ creator: oldUsername }, { creator: newUsername });
        });
    }

    async create(username: Username, createGameDto: ServerCreateGameDto): Promise<void> {
        const { firstImage: image1Base64, secondImage: image2Base64, radius, name, price } = createGameDto;
        const diff = await this.imagesDifferencesService.computeDiff({ image1Base64, image2Base64, radius });

        const gameTemplate = new this.gameTemplateModel({ name, firstImage: image1Base64, secondImage: image2Base64, ...diff });

        const firstImageFileName = `game-templates/${gameTemplate.id}_first.png`;
        const secondImageFileName = `game-templates/${gameTemplate.id}_second.png`;

        const task1 = this.s3Service.uploadImage(firstImageFileName, image1Base64);
        const task2 = this.s3Service.uploadImage(secondImageFileName, image2Base64);
        await Promise.all([task1, task2]);

        gameTemplate.firstImage = firstImageFileName;
        gameTemplate.secondImage = secondImageFileName;
        gameTemplate.price = price;
        gameTemplate.creator = username;

        await gameTemplate.save();
    }

    async findAll(): Promise<GameTemplateDocument[]> {
        return this.gameTemplateModel.find({ deleted: false }, { groupToPixels: 0, pixelToGroup: 0 }).sort({ _id: -1 }).lean();
    }

    async findAllImagesDifferencesForGame(user: Username, inventory: string[]): Promise<ImagesDifferencesForGame[]> {
        return this.gameTemplateModel
            .find(
                {
                    $or: [
                        { _id: { $in: inventory }, deleted: false },
                        { creator: 'admin', deleted: false },
                        { creator: user, deleted: false },
                    ],
                },
                {
                    nGroups: 1,
                    pixelToGroup: 1,
                    difficulty: 1,
                    groupToPixels: 1,
                    name: 1,
                    _id: 1,
                },
            )
            .lean();
    }

    async getImagesDifferencesForGame(id: GameTemplateId): Promise<ImagesDifferencesForGame | null> {
        return this.gameTemplateModel
            .findOne(
                { _id: id, deleted: false },
                {
                    _id: 1,
                    name: 1,
                    difficulty: 1,
                    groupToPixels: 1,
                    nGroups: 1,
                    pixelToGroup: 1,
                },
            )
            .lean();
    }

    async findById(id: GameTemplateId): Promise<CommonGameTemplate | null> {
        return this.gameTemplateModel.findById(id, { groupToPixels: 0, pixelToGroup: 0 });
    }

    async getPrice(id: GameTemplateId): Promise<number | undefined> {
        return (await this.gameTemplateModel.findById(id, { _id: 0, price: 1 }).lean())?.price;
    }

    async getCreator(id: GameTemplateId): Promise<Username | undefined> {
        return (await this.gameTemplateModel.findById(id, { _id: 0, creator: 1 }).lean())?.creator;
    }

    async getImagesDifferences(id: GameTemplateId): Promise<ImagesDifferences | null> {
        return this.gameTemplateModel
            .findOne(
                { _id: id, deleted: false },
                {
                    _id: 0,
                    difficulty: 1,
                    groupToPixels: 1,
                    nGroups: 1,
                    pixelToGroup: 1,
                },
            )
            .lean();
    }

    async findPage(page: number): Promise<CommonGameTemplate[]> {
        return this.gameTemplateModel
            .find({ deleted: false }, { groupToPixels: 0, pixelToGroup: 0 })
            .sort({ _id: -1 })
            .skip(page * GAME_TEMPLATE_PER_PAGE)
            .limit(GAME_TEMPLATE_PER_PAGE);
    }

    async findAllPages(): Promise<CommonGameTemplate[]> {
        return this.gameTemplateModel.find({ deleted: false }, { groupToPixels: 0, pixelToGroup: 0 });
    }

    async getBuyableGames(client: string, inventory: string[]): Promise<CommonGameTemplate[]> {
        return this.gameTemplateModel
            .find(
                {
                    _id: { $nin: inventory },
                    creator: { $nin: ['admin', client] },
                    deleted: false,
                },
                { groupToPixels: 0, pixelToGroup: 0 },
            )
            .sort({ _id: -1 })
            .lean();
    }

    async getAvailableGames(user: Username, inventory: string[]): Promise<CommonGameTemplate[]> {
        return this.gameTemplateModel
            .find(
                {
                    $or: [
                        { _id: { $in: inventory }, deleted: false },
                        { creator: 'admin', deleted: false },
                        { creator: user, deleted: false },
                    ],
                },
                { groupToPixels: 0, pixelToGroup: 0 },
            )
            .sort({ _id: -1 });
    }

    async getLength(): Promise<number> {
        return this.gameTemplateModel.countDocuments({ deleted: false });
    }

    async remove(id: GameTemplateId): Promise<void> {
        const gameTemplate = await this.gameTemplateModel.findByIdAndUpdate(id, { deleted: true });
        if (!gameTemplate) throw new NotFoundException(ErrorMessage.MissingGameTemplate);

        this.waitingGamesService.onTemplateDeletion(id);
    }

    async removeAll(): Promise<void> {
        const gameTemplates = await this.gameTemplateModel.find();
        await Promise.all(gameTemplates.map(async (gameTemplate) => this.remove(gameTemplate.id)));
    }

    async isHighScore(gameMode: GameMode, time: number, gameTemplateId: GameTemplateId | undefined): Promise<boolean> {
        const highScore: HighScoreDocument | null = gameTemplateId
            ? await this.highScoreModel.findOne({ gameMode, gameTemplateId })
            : await this.highScoreModel.findOne({ gameMode });
        if (!highScore) {
            await this.highScoreModel.create({ gameMode, gameTemplateId, time });
            return true;
        }
        if (highScore.time <= time) return false;

        highScore.time = time;
        await highScore.save();
        return true;
    }

    private async start(): Promise<void> {
        if ((await this.getLength()) === 0) {
            await this.populateDB();
        }
    }

    private async populateDB(): Promise<void> {
        for (const [firstPath, secondPath] of DEFAULT_IMAGES_PATH) {
            const defaultCreateGameDto: ServerCreateGameDto = {
                name: '',
                price: 0,
                firstImage: (await readFile(firstPath)).toString('base64'),
                secondImage: (await readFile(secondPath)).toString('base64'),
                radius: DEFAULT_RADIUS,
            };

            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            const name = firstPath.split('_')[2]!!;

            await this.create(ADMIN_USERNAME, { ...defaultCreateGameDto, name });
        }

        this.logger.log('THIS ADDS DATA TO THE DATABASE, DO NOT USE OTHERWISE');
    }
}
