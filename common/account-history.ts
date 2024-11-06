import { AccountAction } from './account-action';
import { Username } from './ingame-ids.types';

export interface AccountHistoryDto {
    userName: Username;
    action: AccountAction;
    timestamp: number;
}
