import { MS_PER_SECOND } from '@common/constants';
import { Vec2 } from '@common/game-template';
import { GameTemplateId, TeamIndex, UnixTimeMs, Username } from '@common/ingame-ids.types';
import { ChangeTemplateDto, InGameEvent, TimeEventDto } from '@common/websocket/in-game.dto';
import { WsException } from '@nestjs/websockets';
import { randomInt } from 'crypto';
import { ImagesDifferencesForGame, TimeLimitCreateInstance } from './../dto/create-game.dto';
import { SingleDiffGameTemplate } from './../dto/game-data.dto';
import { BaseInstanceManager } from './base-instance-manager.entity';

export class TimeLimitTurnByTurnInstanceManager extends BaseInstanceManager {
    private static instances: Set<TimeLimitTurnByTurnInstanceManager> = new Set<TimeLimitTurnByTurnInstanceManager>();
    // eslint-disable-next-line @typescript-eslint/no-magic-numbers
    protected differencesToFind = 1;
    private gameTemplates: SingleDiffGameTemplate[];
    private otherTeamLastPlayed: UnixTimeMs;
    private otherTeamTotalDeltaTime: number = 0;
    private otherTeamIndex: TeamIndex = 1;
    private currentTeamIndex: TeamIndex = 0;

    constructor(createDto: TimeLimitCreateInstance) {
        super(createDto, createDto.gameTemplates[createDto.gameTemplates.length - 1]);
        TimeLimitTurnByTurnInstanceManager.instances.add(this);
        this.prepareGameTemplates(createDto.gameTemplates);
        this.start();
        this.otherTeamLastPlayed = this.clock.startTime;
    }

    static onTemplateDeletion(gameTemplateId: GameTemplateId) {
        TimeLimitTurnByTurnInstanceManager.instances.forEach((instance) => {
            instance.gameTemplates = instance.gameTemplates.filter(
                // eslint-disable-next-line no-underscore-dangle -- from MongoDB
                (template, index) => !(template._id === gameTemplateId && index !== instance.gameTemplates.length - 1),
            );
        });
    }

    emitTick(): void {
        const [currentTeamTime, otherTeamTime] = this.getTimes();
        let timeEventDto: TimeEventDto;
        if (this.currentTeamIndex === 0) {
            timeEventDto = {
                timeMs: currentTeamTime,
                team2TimeMs: otherTeamTime,
            };
        } else {
            timeEventDto = {
                timeMs: otherTeamTime,
                team2TimeMs: currentTeamTime,
            };
        }
        this.webSocketServer.in(this.instanceId).emit(InGameEvent.TimeEvent, timeEventDto);

        this.endGameIfTimeIsOver();
    }

    beforeRemoval(): void {
        super.beforeRemoval();
        TimeLimitTurnByTurnInstanceManager.instances.delete(this);
    }

    identifyDifference(position: Vec2, username: Username): boolean {
        const teamIndex = this.usernameToTeamIndex[username];
        if (teamIndex === this.currentTeamIndex) return super.identifyDifference(position, username);
        throw new WsException('Wait for your turn');
    }

    // eslint-disable-next-line no-unused-vars
    protected onDifferenceFound(team: TeamIndex): void {
        this.loadNextTemplate();
        this.switchTeam();
    }

    protected onPlayerLeave(): void {
        this.sendWinnersLosers([...this.usernames]);
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

    protected endGameIfTimeIsOver(): void {
        if (this.getRemainingTime() === 0) {
            this.sendWinnersLosers(this.teams[this.otherTeamIndex].players);
        }
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

    private loadNextTemplate() {
        const newGameTemplate = this.gameTemplates.pop();

        if (!newGameTemplate) {
            const [currentTeamTime, otherTeamTime] = this.getTimes();
            if (currentTeamTime > otherTeamTime) this.sendWinnersLosers([...this.teams[this.currentTeamIndex].players]);
            else this.sendWinnersLosers([...this.teams[this.otherTeamIndex].players]);
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

    private switchTeam() {
        const deltaTime = this.clock.totalDeltaTime;
        this.clock.totalDeltaTime = this.otherTeamTotalDeltaTime;
        this.otherTeamTotalDeltaTime = deltaTime;

        this.clock.totalDeltaTime += Date.now() - this.otherTeamLastPlayed;
        this.otherTeamLastPlayed = Date.now();

        const tempOtherTeamIndex = this.otherTeamIndex;
        this.otherTeamIndex = this.currentTeamIndex;
        this.currentTeamIndex = tempOtherTeamIndex;
    }

    private getTimes(): [number, number] {
        return [
            this.getRemainingTime(),
            Math.max(this.timeConfig.totalTime * MS_PER_SECOND - (this.otherTeamLastPlayed - this.clock.startTime - this.otherTeamTotalDeltaTime), 0),
        ];
    }

    private prepareGameTemplates(gameTemplates: ImagesDifferencesForGame[]) {
        this.gameTemplates = gameTemplates.map((value) => {
            return { differenceToKeep: randomInt(value.nGroups), ...value };
        });
        this.gameTemplates = this.gameTemplates.sort(() => Math.random() - 1 / 2);
        if (this.gameTemplates.length % 2 === 1) this.gameTemplates.pop();
        this.differencesToFind = this.gameTemplates.length;
    }
}
