export const GAME_TEMPLATE_PER_PAGE = 4;
export const PENALTY_COOLDOWN_TIME_MS = 1000;
export const HINT_COOLDOWN_TIME_MS = 3000;
export const MS_PER_SECOND = 1000;
export const SECONDS_PER_MINUTE = 60;
export const MINUTES_PER_HOUR = 60;
export const MAX_MS_TIME = MS_PER_SECOND * SECONDS_PER_MINUTE * 2;
export const TIME_SLICE_CONSTANT = 8;
export const MAX_MESSAGE_CHARACTERS = 200;
export const POSSIBLE_RADIUS_VALUES = [0, 3, 9, 15];
export const HUNDRED = 100;
export const REPLAY_BAR_STEP = HUNDRED;

export const IMAGE_WIDTH = 640;
export const IMAGE_HEIGHT = 480;
export const CANVAS_IMAGE_CHANNELS = 4;
export const PIXELS_CHANNELS = 3;
export const PIXELS_MAX_VALUES = 255;

export const DEFAULT_PORT = 3000;

export const JWT_EXPIRATION_TIME_SECONDS = 24 * 60 * 60;
export const NB_DEFAULT_AVATARS = 9;

export const HINT_PRICE = 5;
export const MINIMUM_GAME_PRICE = 10;

export const WIN_MONEY = 10;
export const HIGH_SCORE_MONEY = WIN_MONEY + 15;

export const INITIAL_DEFAULT_AVATAR = 'https://polydiff.s3.ca-central-1.amazonaws.com/avatars/image6.png';
export const GEN_CHAT_ID = 'general_chat';

export enum InfoCardConfig {
    Configuration,
    Market,
    Creation,
    GameSelection,
    Watch,
}
export const SERVER_USERNAME = 'complex-username-that-should-not-be-seen';

export const ADMIN_USERNAME = 'admin';
export const ADMIN_PASSWORD = 'leocarre';

export const LOBBIES_PER_PAGE = 4;

export const MAX_CHAT_NAME_LENGTH = 10;
export const MAX_GAME_TEMPLATE_NAME_LENGTH = 10;
