import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { LoggerServiceImpl } from './common/logger/logger.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  const logger = app.get(LoggerServiceImpl);

  // Get configuration
  const port = configService.get<number>('PORT') || 3000;
  const corsOrigin = configService.get<string[]>('CORS_ORIGIN') || [
    'http://localhost:8081',
    'http://192.168.0.122:3000',
    'http://10.203.184.116:3000',
  ];
  const appName = configService.get<string>('APP_NAME') || 'SwiftNest';

  // Enable CORS
  app.enableCors({
    origin: corsOrigin,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  // Add global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Use custom logger
  app.useLogger(logger);

  await app.listen(port, '0.0.0.0');
  logger.log(`🚀 ${appName} server running on port ${port}`, 'Bootstrap');
  logger.log(`📝 API Documentation: http://0.0.0.0:${port}/api`, 'Bootstrap');
}

bootstrap().catch((err) => {
  console.error('Failed to bootstrap application:', err);
  process.exit(1);
});
