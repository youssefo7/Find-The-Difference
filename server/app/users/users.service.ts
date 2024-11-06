import { userRoomPrefix } from '@app/auth/auth.guard';
import { S3Service } from '@app/s3/s3.service';
import { ADMIN_USERNAME, HUNDRED } from '@common/constants';
import { ErrorMessage } from '@common/error-response.dto';
import { Username } from '@common/ingame-ids.types';
import { LocaleDto } from '@common/locale.dto';
import { SendReplayDto } from '@common/replay.dto';
import { Theme } from '@common/theme.dto';
import { UserDto } from '@common/user.dto';
import { UsernameDto } from '@common/websocket/all-events.dto';
import { FriendsEvent } from '@common/websocket/friends.dto';
import { MarketEvent } from '@common/websocket/market.dto';
import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { randomUUID } from 'crypto';
import { Model } from 'mongoose';
import { Server } from 'socket.io';
import { User, UserDocument } from './user.schema';
import { UsernameBlacklist, UsernameBlacklistDocument } from './username-blacklist.schema';

@WebSocketGateway({ cors: true })
@Injectable()
export class UsersService {
    private static onUsernameChange: ((oldUsername: Username, newUsername: Username) => Promise<void>)[] = [];
    @WebSocketServer() private server: Server;
    private updateUserBalanceSemaphore = new Map<Username, Promise<void>>();
    private s3BucketUrl: string = 'https://polydiff.s3.ca-central-1.amazonaws.com';
    constructor(
        @InjectModel(User.name) public userModel: Model<UserDocument>,
        @InjectModel(UsernameBlacklist.name) public usernameBlacklistModel: Model<UsernameBlacklistDocument>,
        private s3Service: S3Service,
    ) {}

    static addOnUsernameChangeCallback(cb: (oldUsername: Username, newUsername: Username) => Promise<void>) {
        this.onUsernameChange.push(cb);
    }

    async findOne(username: Username): Promise<UserDocument | null> {
        return this.userModel.findOne(
            { username },
            {
                _id: 0,
                username: 1,
                passwordHash: 1,
                avatarUrl: 1,
            },
        );
    }

    async getProfile(username: Username): Promise<UserDto | null> {
        return await this.userModel
            .findOne(
                { username },
                {
                    _id: 0,
                    username: 1,
                    avatarUrl: 1,
                },
            )
            .lean();
    }

    async exists(username: Username): Promise<boolean> {
        const result = await this.userModel.exists({ username });
        return Boolean(result);
    }

    async create(username: Username, passwordHash: string, avatarUrl: string): Promise<void> {
        try {
            await new this.usernameBlacklistModel({ username }).save();
        } catch {
            throw new ConflictException(ErrorMessage.UserExists);
        }

        const user = new this.userModel({ username, passwordHash, avatarUrl });
        await user.save();
        this.server.emit(FriendsEvent.NotifyNewUser, { username } as UsernameDto);
    }

    async findLocale(username: Username): Promise<LocaleDto | null> {
        const locale = await this.userModel.findOne({ username }, { locale: 1, _id: 0 });
        return locale;
    }

    async findTheme(username: Username): Promise<Theme | undefined> {
        const theme = await this.userModel.findOne({ username }, { theme: 1, _id: 0 });
        return theme?.theme;
    }

    async updateLocale(username: Username, locale: string): Promise<void> {
        await this.userModel.updateOne({ username }, { locale });
    }

    async deleteReplay(username: Username, replayId: string) {
        await this.userModel.updateOne({ username }, { $pull: { replays: { id: replayId } } });
    }

    async updateUsername(username: Username, newUsername: Username): Promise<void> {
        if (username === ADMIN_USERNAME) {
            throw new ConflictException(ErrorMessage.CannotRenameAdmin);
        }
        try {
            await new this.usernameBlacklistModel({ username: newUsername }).save();
        } catch {
            throw new ConflictException(ErrorMessage.UserExists);
        }
        this.server.to(userRoomPrefix + username).disconnectSockets(true);
        await this.userModel.updateOne({ username }, { username: newUsername });
        Promise.all(
            UsersService.onUsernameChange.map(async (cb) => {
                await cb(username, newUsername);
            }),
        );
    }

    async updateTheme(username: Username, theme: Partial<Theme>): Promise<void> {
        await this.userModel.updateOne({ username }, [{ $addFields: { theme } }]);
    }

    async changePassword(username: Username, newPasswordHash: string): Promise<void> {
        const user = await this.userModel.updateOne({ username }, { passwordHash: newPasswordHash });
        if (user.modifiedCount === 0) throw new NotFoundException(ErrorMessage.UserNotFound);
    }

    async changeAvatar(username: Username, newAvatarUrl: string): Promise<void> {
        const userAvatarUrl = await this.setAvatarUrl(newAvatarUrl);
        const user = await this.userModel.updateOne({ username }, { avatarUrl: userAvatarUrl });
        if (user.modifiedCount === 0) throw new NotFoundException(ErrorMessage.UserNotFound);
    }

    async addReplay(username: Username, replayDto: SendReplayDto) {
        const id = randomUUID();
        await this.userModel.updateOne({ username }, { $push: { replays: { ...replayDto, username, id } } });
    }

    async getReplays(username: Username) {
        return this.userModel.findOne({ username }, { replays: 1 }).lean();
    }

    async getDifferencesFound(username: Username): Promise<number[] | undefined> {
        return (await this.userModel.findOne({ username }, { differencesFound: 1, _id: 0 }).lean())?.differencesFound;
    }

    async updateDifferencesFound(username: string, differencesFound: number): Promise<void> {
        await this.userModel.updateOne({ username }, { $push: { differencesFound } });
    }

    async removeAll(): Promise<void> {
        await this.userModel.deleteMany({});
    }

    async findAll(): Promise<UserDocument[]> {
        return this.userModel.find({}, { _id: 0, username: 1, avatarUrl: 1 }).lean();
    }

    async getUserBalance(username: Username): Promise<number | undefined> {
        return (await this.userModel.findOne({ username }, { balance: 1, _id: 0 }).lean())?.balance;
    }

    // eslint-disable-next-line max-params
    async updateUserBalance(
        username: Username,
        balanceDifference: number,
        onSuccess: () => void,
        onFail: () => void = () => undefined,
    ): Promise<void> {
        let promise = this.updateUserBalanceSemaphore.get(username);
        while (promise !== undefined) {
            await promise;
            promise = this.updateUserBalanceSemaphore.get(username);
        }
        promise = new Promise((resolve) => {
            this.unsafeUpdateUserBalance(username, balanceDifference, onSuccess, onFail).finally(() => resolve());
        });
        this.updateUserBalanceSemaphore.set(username, promise);
        await promise;
        this.updateUserBalanceSemaphore.delete(username);
    }

    async updateUserInventory(username: Username, gameId: string): Promise<void> {
        await this.userModel.updateOne({ username }, { $push: { inventory: gameId } });
    }

    async getUserInventory(username: Username): Promise<string[] | undefined> {
        const inventory = await this.userModel.findOne({ username }, { inventory: 1, _id: 0 }).lean();
        return inventory?.inventory;
    }

    async setAvatarUrl(avatarUrl: string) {
        const isUploadedAvatar = this.checkAvatarType(avatarUrl);

        if (isUploadedAvatar) {
            const base64Data = avatarUrl.replace(/^data:image\/\w+;base64,/, '');
            const avatarFileName = `avatars/${randomUUID()}.png`;
            await this.s3Service.uploadImage(avatarFileName, base64Data);
            return avatarFileName;
        } else {
            const trimmedUrl = this.s3BucketUrl + '/';
            return avatarUrl.replace(trimmedUrl, '');
        }
    }

    checkAvatarType(avatarUrl: string): boolean {
        const regex = /^data:image\/\w+;base64,/;

        return regex.test(avatarUrl);
    }

    private getAverageDuration(gamesDuration: number[]): number {
        return gamesDuration.length === 0 ? 0 : gamesDuration.reduce((a, b) => a + b, 0) / gamesDuration.length;
    }

    private getAverageDifferencesFoundRatio(differencesFoundRatio: number[][]): number {
        return differencesFoundRatio.length === 0
            ? 0
            : (differencesFoundRatio.reduce((a, b) => a + b[1] / b[0], 0) / differencesFoundRatio.length) * HUNDRED;
    }

    // eslint-disable-next-line max-params
    private async unsafeUpdateUserBalance(username: Username, balanceDifference: number, onSuccess: () => void, onFail: () => void): Promise<void> {
        try {
            const user = await this.userModel.findOne({ username }, { balance: 1 });
            if (!user) return;
            user.balance += balanceDifference;
            await user.save();
            this.server.to(userRoomPrefix + username).emit(MarketEvent.UpdateBalance, { balance: user.balance });
            await onSuccess();
        } catch {
            await onFail();
            return;
        }
    }
}
