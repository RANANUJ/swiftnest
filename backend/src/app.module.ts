import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { WebSocketModule } from './websocket/websocket.module';
import { ChatModule } from './chat/chat.module';
import { LoggerServiceImpl } from './common/logger/logger.service';
import { AllExceptionsFilter } from './common/filters/http-exception.filter';
import { APP_FILTER } from '@nestjs/core';
import { appConfig } from './config/app.config';
import { mongooseConfig } from './config/database.config';

@Module({
  imports: [
    // Environment configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '.env.local'],
      load: [appConfig],
    }),

    // MongoDB connection
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => {
        const config = mongooseConfig();
        console.log(`🗄️  Connecting to MongoDB: ${config.uri}`);
        return config;
      },
    }),

    // Feature modules
    AuthModule,
    ChatModule,
    WebSocketModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    LoggerServiceImpl,
    {
      provide: APP_FILTER,
      useClass: AllExceptionsFilter,
    },
  ],
})
export class AppModule {}
