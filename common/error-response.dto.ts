export class ErrorResponseDto {
    statusCode: number;
    message: ErrorMessage;
    error: string;
}

export enum ErrorMessage {
    JwtMissing = 'Missing or bad JWT',
    CannotRenameAdmin = 'Cannot Rename Admin',
    UserConnected = 'User already connected',
    UserNotFound = 'User does not exist',
    UserExists = 'User already exists',
    PasswordInvalid = 'Password is invalid',
    MissingGameTemplate = 'Game template not found',
    PageNumberInvalid = 'Invalid page number, should be greater or equal to zero',
    ObjectIdInvalid = 'Invalid ObjectId',
    ImageInvalid = 'The base64 encoded images should be in bmp, jpg or png format',
    ImageNotFound = 'Image not found',
    DtoInvalid = 'Dto contains invalid field',
    NotEnoughMoney = 'Not enough money',
}
