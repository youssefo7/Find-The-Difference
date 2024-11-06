import { AccountAction } from '@common/account-action';
import { ErrorMessage } from '@common/error-response.dto';
import { GameMode } from '@common/game-template';

export namespace EnumTranslator {
    export const httpErrorMessageToMessage = (errorMessage: ErrorMessage): string => {
        switch (errorMessage) {
            case ErrorMessage.DtoInvalid:
                return $localize`Dto contains invalid field`;
            case ErrorMessage.ImageInvalid:
                return $localize`The base64 encoded images should be in bmp, jpg or png format`;
            case ErrorMessage.ImageNotFound:
                return $localize`Image not found`;
            case ErrorMessage.JwtMissing:
                return $localize`Missing or bad JWT`;
            case ErrorMessage.MissingGameTemplate:
                return $localize`Game template not found`;
            case ErrorMessage.NotEnoughMoney:
                return $localize`Not enough money`;
            case ErrorMessage.ObjectIdInvalid:
                return $localize`Invalid ObjectId`;
            case ErrorMessage.PageNumberInvalid:
                return $localize`Invalid page number, should be greater or equal to zero`;
            case ErrorMessage.PasswordInvalid:
                return $localize`Invalid password`;
            case ErrorMessage.UserConnected:
                return $localize`User already connected`;
            case ErrorMessage.UserExists:
                return $localize`User already exists`;
            case ErrorMessage.UserNotFound:
                return $localize`User does not exist`;
            case ErrorMessage.CannotRenameAdmin:
                return $localize`Cannot rename admin account`;
        }
    };

    export const toGameModeString = (gameMode: GameMode): string => {
        switch (gameMode) {
            case GameMode.TeamClassic:
                return $localize`Team Classic`;
            case GameMode.TimeLimitSingleDiff:
                return $localize`Limited Time Single Diff`;
            case GameMode.ClassicMultiplayer:
                return $localize`Classic Multiplayer`;
            case GameMode.TimeLimitAugmented:
                return $localize`Limited Time Augmented`;
            case GameMode.TimeLimitTurnByTurn:
                return $localize`Limited Time Turn Based`;
        }
    };

    export const translateAccountAction = (action: AccountAction): string => {
        switch (action) {
            case AccountAction.Login:
                return $localize`Login`;
            case AccountAction.Logout:
                return $localize`Logout`;
        }
    };
}
