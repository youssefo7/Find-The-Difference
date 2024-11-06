import { MS_PER_SECOND } from '@common/constants';
import { GameMode } from '@common/game-template';
import { GameTemplateId, TeamIndex } from '@common/ingame-ids.types';
import { ChangeTemplateDto, InGameEvent, TimeEventDto } from '@common/websocket/in-game.dto';
import { randomInt } from 'crypto';
import { ImagesDifferencesForGame, TimeLimitCreateInstance } from './../dto/create-game.dto';
import { SingleDiffGameTemplate } from './../dto/game-data.dto';
import { BaseInstanceManager } from './base-instance-manager.entity';

export class TimeLimitSingleDiffInstanceManager extends BaseInstanceManager {
    private static instances: Set<TimeLimitSingleDiffInstanceManager> = new Set<TimeLimitSingleDiffInstanceManager>();
    protected differencesToFind = 1;
    private gameTemplates: SingleDiffGameTemplate[];

    constructor(createDto: TimeLimitCreateInstance) {
        super(createDto, createDto.gameTemplates[createDto.gameTemplates.length - 1]);
        this.prepareGameTemplates(createDto.gameTemplates, createDto.gameMode);
        TimeLimitSingleDiffInstanceManager.instances.add(this);
        this.start();
    }

    static onTemplateDeletion(gameTemplateId: GameTemplateId) {
        TimeLimitSingleDiffInstanceManager.instances.forEach((instance) => {
            instance.gameTemplates = instance.gameTemplates.filter(
                // eslint-disable-next-line no-underscore-dangle -- from MongoDB
                (template, index) => !(template._id === gameTemplateId && index !== instance.gameTemplates.length - 1),
            );
        });
    }

    emitTick(): void {
        const timeEventDto: TimeEventDto = {
            timeMs: this.getRemainingTime(),
        };
        this.webSocketServer.in(this.instanceId).emit(InGameEvent.TimeEvent, timeEventDto);

        this.endGameIfTimeIsOver();
    }

    beforeRemoval(): void {
        super.beforeRemoval();
        TimeLimitSingleDiffInstanceManager.instances.delete(this);
    }

    protected getTimeLimitPreload(): [ChangeTemplateDto, ChangeTemplateDto] | undefined {
        const template: SingleDiffGameTemplate = this.differences as unknown as SingleDiffGameTemplate;
        const pixelsToRemove = template.groupToPixels.filter((_pixels, i) => i !== template.differenceToKeep).flat();
        const currentTemplate: ChangeTemplateDto = {
            // eslint-disable-next-line no-underscore-dangle -- from MongoDB
            nextGameTemplateId: template._id,
            pixelsToRemove,
        };
        return [currentTemplate, this.makeChangeTemplateDto()];
    }

    // eslint-disable-next-line no-unused-vars
    protected onDifferenceFound(team: TeamIndex): void {
        this.addDeltaTime(this.timeConfig.rewardTime);
        this.loadNextTemplate();
    }

    protected onPlayerLeave(): void {
        return;
    }

    protected onStart(): void {
        if (this.gameTemplates) this.webSocketServer.in(this.instanceId).emit(InGameEvent.ChangeTemplate, this.makeChangeTemplateDto());

        this.loadNextTemplate();
    }

    protected addDeltaTime(deltaTimeSeconds: number): void {
        super.addDeltaTime(deltaTimeSeconds);
        const timeLeft = this.getRemainingTime();
        if (timeLeft > this.timeConfig.totalTime * MS_PER_SECOND) this.clock.totalDeltaTime -= timeLeft - this.timeConfig.totalTime * MS_PER_SECOND;
        this.endGameIfTimeIsOver();
    }

    private loadNextTemplate() {
        const newGameTemplate = this.gameTemplates.pop();

        if (!newGameTemplate) {
            this.sendWinnersLosers([...this.usernames]);
            return;
        }

        this.webSocketServer.in(this.instanceId).emit(InGameEvent.ChangeTemplate, this.makeChangeTemplateDto());

        this.differences = newGameTemplate;
        this.discoveredDifferences.clear();
        for (let difference = 0; difference < newGameTemplate.nGroups; difference++) {
            this.discoveredDifferences.add(difference);
        }
        this.discoveredDifferences.delete(newGameTemplate.differenceToKeep);
    }

    private makeChangeTemplateDto(): ChangeTemplateDto {
        const template = this.gameTemplates[this.gameTemplates.length - 1];
        if (template) {
            const pixelsToRemove = template.groupToPixels.filter((_pixels, i) => i !== template.differenceToKeep).flat();
            return {
                // eslint-disable-next-line no-underscore-dangle -- from MongoDB
                nextGameTemplateId: template._id,
                pixelsToRemove,
            };
        }
        return {};
    }

    private prepareGameTemplates(gameTemplates: ImagesDifferencesForGame[], gameMode: GameMode) {
        if (gameMode === GameMode.TimeLimitSingleDiff) {
            this.gameTemplates = gameTemplates.map((value) => {
                return { differenceToKeep: randomInt(value.nGroups), ...value };
            });
        } else {
            this.gameTemplates = [];
            gameTemplates.forEach((value) => {
                for (let difference = 0; difference < value.nGroups; difference++) {
                    this.gameTemplates.push({ differenceToKeep: difference, ...value });
                }
            });
        }
        this.gameTemplates = this.gameTemplates.sort(() => Math.random() - 1 / 2);
        this.differencesToFind = this.gameTemplates.length;
    }
}
