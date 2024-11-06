/* eslint-disable @typescript-eslint/naming-convention */
import { DeleteObjectCommand, PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class S3Service {
    private s3: S3Client;
    private bucketName: string;

    constructor(configService: ConfigService) {
        this.bucketName = configService.getOrThrow('BUCKET_NAME');
        const region = configService.getOrThrow('BUCKET_REGION');
        const accessKeyId = configService.getOrThrow('ACCESS_ID');
        const secretAccessKey = configService.getOrThrow('SECRET_ACCESS_KEY');

        this.s3 = new S3Client({
            credentials: {
                accessKeyId,
                secretAccessKey,
            },
            region,
        });
    }

    async uploadImage(fileName: string, imageBase64: string): Promise<void> {
        const command = new PutObjectCommand({
            Bucket: this.bucketName,
            Key: fileName,
            Body: Buffer.from(imageBase64, 'base64'),
            ContentType: 'image/png',
            ContentEncoding: 'base64',
        });
        await this.s3.send(command);
    }

    async deleteImage(fileName: string): Promise<void> {
        const command = new DeleteObjectCommand({
            Bucket: this.bucketName,
            Key: fileName,
        });
        await this.s3.send(command);
    }
}
