import { MAX_MS_TIME } from '@common/constants';
import { TeamIndex } from '@common/ingame-ids.types';
import { InGameEvent, TimeEventDto } from '@common/websocket/in-game.dto';
import { ClassicTeamCreateInstance, ImagesDifferencesForGame } from './../dto/create-game.dto';
import { BaseInstanceManager } from './base-instance-manager.entity';

export class ClassicTeamInstanceManager extends BaseInstanceManager {
    private differenceLeft: number;
    private firstTeam: TeamIndex = 0;
    private secondTeam: TeamIndex = 1;

    constructor(joinDto: ClassicTeamCreateInstance, differences: ImagesDifferencesForGame) {
        super(joinDto, differences);
        this.differenceLeft = this.differences.nGroups;
        this.start();
    }

    protected get differencesToFind(): number {
        return this.differences.nGroups;
    }

    emitTick(): void {
        const timeEventDto: TimeEventDto = {
            timeMs: this.getRemainingTime(),
        };
        this.webSocketServer.in(this.instanceId).emit(InGameEvent.TimeEvent, timeEventDto);

        this.endGameIfTimeIsOver();
    }

    protected onStart(): void {
        return;
    }
    protected onDifferenceFound(team: TeamIndex): void {
        this.differenceLeft--;
        if (this.teams[team].score > this.teams[this.firstTeam].score) {
            this.secondTeam = this.firstTeam;
            this.firstTeam = team;
        } else if (this.teams[team].score > this.teams[this.secondTeam].score && team !== this.firstTeam) {
            this.secondTeam = team;
        }
        if (this.teams[this.firstTeam].score >= this.teams[this.secondTeam].score + this.differenceLeft) {
            this.sendWinnersLosers(this.teams[this.firstTeam].players);
            return;
        }
        this.addDeltaTime(this.timeConfig.rewardTime);
    }

    protected onPlayerLeave(): void {
        if (this.teams[this.secondTeam] && this.teams[this.firstTeam]) return;
        const teamIndexes = [...new Set<number>(Object.values(this.usernameToTeamIndex))];
        if (teamIndexes.length === 0) return;
        if (teamIndexes.length === 1) {
            this.firstTeam = teamIndexes[0];
            this.secondTeam = teamIndexes[0];
            return;
        }
        this.firstTeam = teamIndexes[0];
        teamIndexes.forEach((team) => {
            if (this.teams[team].score > this.teams[this.firstTeam].score) this.firstTeam = team;
        });

        const secondTeamCandidates = teamIndexes.filter((value) => value !== this.firstTeam);
        this.secondTeam = secondTeamCandidates[0];
        secondTeamCandidates.forEach((team) => {
            if (this.teams[team].score > this.teams[this.secondTeam].score) this.secondTeam = team;
        });
        return;
    }

    protected addDeltaTime(deltaTimeSeconds: number): void {
        super.addDeltaTime(deltaTimeSeconds);
        const timeLeft = this.getRemainingTime();
        if (timeLeft > MAX_MS_TIME) this.clock.totalDeltaTime -= timeLeft - MAX_MS_TIME;
        this.endGameIfTimeIsOver();
    }
}
