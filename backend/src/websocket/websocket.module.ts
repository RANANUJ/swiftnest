import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ChatWebSocketGateway } from './websocket.gateway';
import { WebSocketAuthGuard } from './guards/websocket-auth.guard';
import { ChatModule } from '../chat/chat.module';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get('JWT_SECRET'),
      }),
    }),
    ChatModule,
  ],
  providers: [ChatWebSocketGateway, WebSocketAuthGuard],
  exports: [ChatWebSocketGateway],
})
export class WebSocketModule {}
