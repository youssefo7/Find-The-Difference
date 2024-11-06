import { UsersService } from '@app/users/users.service';
import { HistoryDto } from '@common/history';
import { Username } from '@common/ingame-ids.types';
import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { History, HistoryDocument } from './history.schema';
@Injectable()
export class HistoryService {
    private readonly logger = new Logger(HistoryService.name);

    constructor(@InjectModel(History.name) public historyModel: Model<HistoryDocument>) {
        UsersService.addOnUsernameChangeCallback(async (oldUsername: Username, newUsername: Username) => {
            await Promise.all([
                this.historyModel.updateMany(
                    { winners: { $elemMatch: { $eq: oldUsername } } },
                    {
                        // eslint-disable-next-line @typescript-eslint/naming-convention
                        $set: { 'winners.$': newUsername },
                    },
                ),
                this.historyModel.updateMany(
                    { losers: { $elemMatch: { $eq: oldUsername } } },
                    {
                        // eslint-disable-next-line @typescript-eslint/naming-convention
                        $set: { 'losers.$': newUsername },
                    },
                ),
                this.historyModel.updateMany(
                    { quitters: { $elemMatch: { $eq: oldUsername } } },
                    {
                        // eslint-disable-next-line @typescript-eslint/naming-convention
                        $set: { 'quitters.$': newUsername },
                    },
                ),
            ]);
        });
    }

    async create(createHistoryDto: HistoryDto): Promise<void> {
        const { startTime, totalTime, gameMode, winners, losers, quitters } = createHistoryDto;
        await this.historyModel.create({ startTime, totalTime, gameMode, winners, losers, quitters });
    }

    async findAll(): Promise<HistoryDocument[]> {
        return this.historyModel.find();
    }

    async removeAll(): Promise<void> {
        await this.historyModel.collection.drop();
    }

    async findByUsername(username: Username): Promise<HistoryDocument[]> {
        return this.historyModel.find({
            $or: [{ winners: username }, { losers: username }, { quitters: username }],
        });
    }
}
