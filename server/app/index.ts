import { AppModule } from '@app/app.module';
import { DEFAULT_PORT } from '@common/constants';
import { Logger, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { EventEmitter } from 'events';
import { RequestHandler, json, urlencoded } from 'express';

const loggerMiddleware: RequestHandler = (req, _res, next) => {
    const logger = new Logger('HTTP');
    const { method, originalUrl } = req;
    const userAgent = req.get('user-agent') || '';

    logger.log(`${method} ${originalUrl} ${userAgent}`);
    next();
};

const corsHeaderMiddleware: RequestHandler = (_req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
};

const bootstrap = async () => {
    EventEmitter.defaultMaxListeners = 15;
    const app = await NestFactory.create<NestExpressApplication>(AppModule);

    app.use(loggerMiddleware);
    app.use(corsHeaderMiddleware);

    app.setGlobalPrefix('api');
    app.useGlobalPipes(new ValidationPipe());
    app.use(json({ limit: '50mb' }));
    app.use(urlencoded({ limit: '50mb', extended: true }));
    app.enableCors();

    const config = new DocumentBuilder()
        .addBearerAuth()
        .setTitle('Cadriciel Serveur')
        .setDescription('Serveur du projet de base pour le cours de LOG3900')
        .setVersion('1.0.0')
        .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
    SwaggerModule.setup('', app, document);

    await app.listen(process.env.PORT || DEFAULT_PORT);
};

bootstrap();
