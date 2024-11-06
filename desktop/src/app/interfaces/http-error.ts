import { ErrorResponseDto } from '@common/error-response.dto';

export interface HttpError {
    status: number;
    error: ErrorResponseDto;
}
