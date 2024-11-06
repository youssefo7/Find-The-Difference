import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { HistoryService } from '@app/services/history.service';
import { StatisticsService } from '@app/services/statistics.service';
import { UserService } from '@app/services/user.service';
import { HUNDRED, MS_PER_SECOND } from '@common/constants';
import { DEFAULT_STATISTICS, Statistics } from '@common/statistics.dto';
import { EChartsOption } from 'echarts';
import { Subscription, first } from 'rxjs';

@Component({
    selector: 'app-profile-page',
    templateUrl: './profile-page.component.html',
    styleUrl: './profile-page.component.scss',
})
export class ProfilePageComponent implements OnInit, OnDestroy {
    username: string = '';
    statistics: Statistics = DEFAULT_STATISTICS;
    chartOption: EChartsOption;
    isLoading: boolean = true;
    timeDescription: string = $localize`seconds`;

    private subscriptions = new Subscription();
    // eslint-disable-next-line max-params
    constructor(
        private route: ActivatedRoute,
        private statisticsService: StatisticsService,
        private userService: UserService,
        private historyService: HistoryService,
    ) {}

    ngOnInit() {
        this.statistics = DEFAULT_STATISTICS;
        this.fetchAllUsers();
        this.setUserStatistics();
    }

    fetchAllUsers() {
        this.isLoading = true;

        const usersSubscription = this.userService.allUsers$.subscribe({
            next: () => {
                this.isLoading = false;
            },
        });

        this.userService.fetchAllUsers();
        this.subscriptions.add(usersSubscription);
    }

    ngOnDestroy() {
        this.subscriptions.unsubscribe();
    }

    setUserStatistics(): void {
        this.route.params.subscribe((params) => {
            this.username = params.username;
            this.statisticsService.getStatistics(this.username).subscribe((ratios) => {
                const sumOfRatios = ratios.reduce((acc, ratio) => acc + ratio, 0);
                this.statistics.differencesFoundRatio = (sumOfRatios / ratios.length) * HUNDRED;
            });
            const gameHistoryObservable = this.historyService.findByUsername(this.username);
            gameHistoryObservable.pipe(first()).subscribe((gameHistory) => {
                let sumOfDurations = 0;
                if (gameHistory) {
                    this.statistics.gamesPlayed = gameHistory.length;
                    this.statistics.gamesQuit = 0;
                    this.statistics.gamesWon = 0;
                    this.statistics.gamesLost = 0;
                    gameHistory.forEach((game) => {
                        if (game.winners.includes(this.username)) {
                            this.statistics.gamesWon++;
                        } else if (game.quitters.includes(this.username)) {
                            this.statistics.gamesQuit++;
                        } else {
                            this.statistics.gamesLost++;
                        }
                        sumOfDurations += game.totalTime;
                    });
                }
                if (this.statistics.gamesPlayed === 0) {
                    this.statistics.gamesDuration = 0;
                } else {
                    this.statistics.gamesDuration = sumOfDurations / MS_PER_SECOND / this.statistics.gamesPlayed;
                }
                this.setChartOption();
            });
        });
    }

    setChartOption(): void {
        this.chartOption = {
            title: { text: $localize`You` },
            tooltip: {
                trigger: 'item',
            },
            legend: {
                top: '5%',
                left: 'center',
            },
            series: [
                {
                    name: $localize`Access From`,
                    type: 'pie',
                    radius: ['40%', '70%'],
                    avoidLabelOverlap: false,
                    itemStyle: {
                        borderRadius: 10,
                        borderColor: '#fff',
                        borderWidth: 2,
                    },
                    label: {
                        show: false,
                        position: 'center',
                    },
                    emphasis: {
                        label: {
                            show: true,
                            fontSize: 20,
                            fontWeight: 'bold',
                        },
                    },
                    labelLine: {
                        show: false,
                    },
                    data: [
                        { value: this.statistics.gamesQuit, name: $localize`Abandon`, itemStyle: { color: '#D0BFFF' } },
                        { value: this.statistics.gamesWon, name: $localize`Victory`, itemStyle: { color: '#9DBC98' } },
                        { value: this.statistics.gamesLost, name: $localize`Defeat`, itemStyle: { color: '#DC8686' } },
                    ],
                },
            ],
        };
    }

    getAverageGameDuration(): number | string {
        const average = this.statistics.gamesDuration;
        if (average === 0) {
            return '-';
        }
        return average.toFixed(0);
    }

    getFoundDifferencesRatio(): string {
        if (this.statistics.gamesPlayed === 0) {
            return '-';
        }

        return this.statistics.differencesFoundRatio.toFixed(2);
    }

    getRatioVictory(): string {
        if (this.statistics.gamesPlayed === 0) {
            return '-';
        }
        const ratio = (this.statistics.gamesWon / this.statistics.gamesPlayed) * HUNDRED;
        return ratio.toFixed(2);
    }
}
