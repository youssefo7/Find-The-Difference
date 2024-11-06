export class Statistics {
    gamesPlayed: number;
    gamesWon: number;
    gamesLost: number;
    gamesQuit: number;
    gamesDuration: number;
    differencesFoundRatio: number;
}

export class DifferenceFoundRatioDto {
    differenceFound: number;
}

export const DEFAULT_STATISTICS: Statistics = {
    gamesPlayed: 0,
    gamesWon: 0,
    gamesLost: 0,
    gamesQuit: 0,
    gamesDuration: 0,
    differencesFoundRatio: 0,
};
