import { Difficulty } from '@common/game-template';
import { CreateDiffResult } from '@common/images-differences';

export class ServerCreateDiffResult implements CreateDiffResult {
    nGroups: number;
    difficulty: Difficulty;
    diffImage: string;
}
