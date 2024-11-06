import { CreateDiffDto } from '@common/images-differences';
import { IsBase64, IsNumber } from 'class-validator';

export class CreateImagesDifferencesDto implements CreateDiffDto {
    @IsBase64()
    image1Base64: string;

    @IsBase64()
    image2Base64: string;

    @IsNumber()
    radius: number;
}
