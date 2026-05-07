# 🚀 Socket.IO Setup Guide - SwiftNest Backend

**Stage**: 5 - Real-Time Chat Implementation  
**Date**: April 25, 2026  
**Status**: Planning & Setup

---

## 📋 Overview

Socket.IO enables **real-time, bidirectional communication** between your NestJS backend and Flutter frontend. This guide walks through the complete setup.

---

## 🎯 Where Socket.IO Is Used in SwiftNest

### 1. **Real-Time Messaging** (One-to-One & Group Chat)
```
User A sends message → Socket.IO → User B receives instantly
```
- **Event**: `message:send` → User receives via `message:receive`
- **Stored in**: MongoDB (messages collection)
- **Cached in**: Redis (recent messages, user online status)

### 2. **Typing Indicators**
```
User A is typing... → Socket.IO → User B sees typing indicator
```
- **Event**: `chat:typing` → Other user sees `chat:typing:update`
- **Timeout**: Auto-clear after 3 seconds of inactivity

### 3. **Message Read Receipts**
```
User A reads message → Socket.IO → User B sees "read" status
```
- **Event**: `message:read` → Sender sees `message:read:update`
- **Stored in**: MongoDB (message read_at timestamp)

### 4. **User Online/Offline Status**
```
User A comes online → Redis tracks → Socket.IO notifies contacts
```
- **Event**: `user:online` / `user:offline`
- **Cached in**: Redis (user sessions)
- **Visible in**: Chat list, contacts, user profile

### 5. **Notifications**
```
Event happens → Socket.IO → User gets real-time notification
```
- **Events**: `notification:new`, `notification:dismiss`
- **Types**: New message, friend request, group invite, etc.

### 6. **Connection Management**
- **Auto-reconnect**: Socket.IO handles dropped connections
- **Rooms**: Each chat has its own room
- **Namespaces**: `/chat`, `/notifications`, `/presence`

---

## 📦 Step 1: Install Dependencies

```bash
cd backend
npm install socket.io @nestjs/websockets @nestjs/platform-socket.io
npm install socket.io-redis socket.io-redis-adapter --save
```

**What each package does:**
- `socket.io` - WebSocket library
- `@nestjs/websockets` - NestJS integration
- `@nestjs/platform-socket.io` - Platform adapter for Socket.IO
- `socket.io-redis-adapter` - Allows Socket.IO to work across multiple servers using Redis

---

## 📂 Step 2: Create Socket.IO Module Structure

Create these files in your backend:

```
backend/src/
├── websocket/
│   ├── websocket.gateway.ts          ← Main gateway
│   ├── websocket.module.ts           ← Module
│   ├── decorators/
│   │   └── socket-user.decorator.ts  ← Get user from socket
│   ├── guards/
│   │   └── websocket-auth.guard.ts   ← Verify JWT token
│   └── events/
│       ├── chat.events.ts            ← Chat events handler
│       ├── presence.events.ts        ← Online/offline events
│       └── notification.events.ts    ← Notification events
├── chat/
│   ├── chat.controller.ts
│   ├── chat.service.ts
│   ├── schemas/
│   │   ├── message.schema.ts         ← Message model
│   │   ├── conversation.schema.ts    ← Chat/conversation model
│   │   └── chat-participant.schema.ts
│   └── chat.module.ts
└── app.module.ts (updated)
```

---

## 🔧 Step 3: Implementation Files

### 1. **Socket Auth Guard** (`src/websocket/guards/websocket-auth.guard.ts`)

Verifies JWT token when Socket.IO client connects:

```typescript
import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Socket } from 'socket.io';

@Injectable()
export class WebSocketAuthGuard {
  constructor(private jwtService: JwtService) {}

  async validateConnection(client: Socket): Promise<any> {
    try {
      const token = client.handshake.headers.authorization?.split(' ')[1];
      
      if (!token) {
        throw new Error('No token provided');
      }

      const user = await this.jwtService.verifyAsync(token);
      return user;
    } catch (error) {
      throw new Error('Unauthorized');
    }
  }
}
```

### 2. **Socket User Decorator** (`src/websocket/decorators/socket-user.decorator.ts`)

Get authenticated user from socket connection:

```typescript
import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Socket } from 'socket.io';

export const SocketUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const client = ctx.switchToWs().getClient<Socket>();
    return client.data.user;
  },
);
```

### 3. **WebSocket Gateway** (`src/websocket/websocket.gateway.ts`)

Main gateway handling Socket.IO events:

```typescript
import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Injectable, UseGuards } from '@nestjs/common';
import { WebSocketAuthGuard } from './guards/websocket-auth.guard';
import { SocketUser } from './decorators/socket-user.decorator';
import { ChatService } from '../chat/chat.service';

@WebSocketGateway({
  namespace: 'chat',
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true,
  },
})
@Injectable()
export class WebSocketGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(
    private authGuard: WebSocketAuthGuard,
    private chatService: ChatService,
  ) {}

  // ============ CONNECTION ============
  async handleConnection(@ConnectedSocket() client: Socket) {
    try {
      const user = await this.authGuard.validateConnection(client);
      client.data.user = user;

      console.log(`✅ User connected: ${user.email} (${client.id})`);

      // Join user's personal room for notifications
      client.join(`user:${user.id}`);

      // Broadcast user is online
      this.server.emit('user:online', {
        userId: user.id,
        timestamp: new Date(),
      });

      // Store in Redis (optional - for presence tracking)
    } catch (error) {
      console.error('❌ Connection failed:', error.message);
      client.disconnect();
    }
  }

  async handleDisconnect(@ConnectedSocket() client: Socket) {
    const user = client.data.user;
    if (user) {
      console.log(`❌ User disconnected: ${user.email} (${client.id})`);

      // Broadcast user is offline
      this.server.emit('user:offline', {
        userId: user.id,
        timestamp: new Date(),
      });
    }
  }

  // ============ CHAT EVENTS ============

  // User joins a chat room
  @SubscribeMessage('chat:join')
  handleChatJoin(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { chatId: string },
  ) {
    const roomName = `chat:${data.chatId}`;
    client.join(roomName);

    console.log(`📍 User ${user.id} joined chat ${data.chatId}`);

    // Notify others in room
    this.server.to(roomName).emit('chat:user-joined', {
      userId: user.id,
      userName: user.name,
      timestamp: new Date(),
    });
  }

  // User leaves a chat room
  @SubscribeMessage('chat:leave')
  handleChatLeave(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { chatId: string },
  ) {
    const roomName = `chat:${data.chatId}`;
    client.leave(roomName);

    console.log(`👋 User ${user.id} left chat ${data.chatId}`);

    this.server.to(roomName).emit('chat:user-left', {
      userId: user.id,
      userName: user.name,
      timestamp: new Date(),
    });
  }

  // Send message
  @SubscribeMessage('message:send')
  async handleMessageSend(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { chatId: string; text: string; mediaUrl?: string },
  ) {
    try {
      // Save message to MongoDB
      const message = await this.chatService.saveMessage({
        senderId: user.id,
        chatId: data.chatId,
        text: data.text,
        mediaUrl: data.mediaUrl,
        timestamp: new Date(),
      });

      // Broadcast to all users in chat
      const roomName = `chat:${data.chatId}`;
      this.server.to(roomName).emit('message:receive', {
        messageId: message._id,
        senderId: user.id,
        senderName: user.name,
        senderAvatar: user.avatar,
        text: data.text,
        mediaUrl: data.mediaUrl,
        timestamp: message.timestamp,
      });

      console.log(`💬 Message sent in chat ${data.chatId}`);
    } catch (error) {
      client.emit('error', { message: error.message });
    }
  }

  // Typing indicator
  @SubscribeMessage('chat:typing')
  handleTyping(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { chatId: string },
  ) {
    const roomName = `chat:${data.chatId}`;

    this.server.to(roomName).emit('chat:typing:update', {
      userId: user.id,
      userName: user.name,
      chatId: data.chatId,
    });
  }

  // Stop typing
  @SubscribeMessage('chat:stop-typing')
  handleStopTyping(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { chatId: string },
  ) {
    const roomName = `chat:${data.chatId}`;

    this.server.to(roomName).emit('chat:stop-typing:update', {
      userId: user.id,
      chatId: data.chatId,
    });
  }

  // Message read receipt
  @SubscribeMessage('message:read')
  async handleMessageRead(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { messageId: string; chatId: string },
  ) {
    try {
      await this.chatService.markMessageAsRead(data.messageId, user.id);

      const roomName = `chat:${data.chatId}`;
      this.server.to(roomName).emit('message:read:update', {
        messageId: data.messageId,
        readBy: user.id,
        readAt: new Date(),
      });
    } catch (error) {
      client.emit('error', { message: error.message });
    }
  }

  // ============ NOTIFICATION EVENTS ============

  // Send notification to specific user
  sendNotification(userId: string, notification: any) {
    this.server.to(`user:${userId}`).emit('notification:new', {
      ...notification,
      timestamp: new Date(),
    });
  }

  // Dismiss notification
  @SubscribeMessage('notification:dismiss')
  handleNotificationDismiss(
    @SocketUser() user: any,
    @MessageBody() data: { notificationId: string },
  ) {
    // Clear from database
    console.log(`🗑️  Notification ${data.notificationId} dismissed`);
  }
}
```

### 4. **WebSocket Module** (`src/websocket/websocket.module.ts`)

```typescript
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { WebSocketGateway } from './websocket.gateway';
import { WebSocketAuthGuard } from './guards/websocket-auth.guard';
import { ChatModule } from '../chat/chat.module';
import { ConfigModule, ConfigService } from '@nestjs/config';

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
  providers: [WebSocketGateway, WebSocketAuthGuard],
  exports: [WebSocketGateway],
})
export class WebSocketModule {}
```

### 5. **Update App Module** (`src/app.module.ts`)

Add WebSocket module:

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { WebSocketModule } from './websocket/websocket.module';  // ADD THIS
import { LoggerServiceImpl } from './common/logger/logger.service';
import { AllExceptionsFilter } from './common/filters/http-exception.filter';
import { APP_FILTER } from '@nestjs/core';
import { appConfig } from './config/app.config';
import { mongooseConfig } from './config/database.config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '.env.local'],
      load: [appConfig],
    }),

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
    WebSocketModule,  // ADD THIS
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
```

### 6. **Message Schema** (`src/chat/schemas/message.schema.ts`)

```typescript
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Message extends Document {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  senderId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Conversation', required: true })
  conversationId: Types.ObjectId;

  @Prop({ required: true })
  text: string;

  @Prop()
  mediaUrl?: string;

  @Prop({ type: [Types.ObjectId], ref: 'User', default: [] })
  readBy: Types.ObjectId[];

  @Prop()
  readAt?: Date;

  @Prop({ default: false })
  isDeleted: boolean;

  @Prop({ default: new Date() })
  createdAt: Date;

  @Prop({ default: new Date() })
  updatedAt: Date;
}

export const MessageSchema = SchemaFactory.createForClass(Message);
```

### 7. **Chat Service** (`src/chat/chat.service.ts`)

```typescript
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Message } from './schemas/message.schema';

@Injectable()
export class ChatService {
  constructor(@InjectModel(Message.name) private messageModel: Model<Message>) {}

  async saveMessage(data: {
    senderId: string;
    chatId: string;
    text: string;
    mediaUrl?: string;
    timestamp: Date;
  }) {
    const message = new this.messageModel({
      senderId: data.senderId,
      conversationId: data.chatId,
      text: data.text,
      mediaUrl: data.mediaUrl,
      createdAt: data.timestamp,
    });

    return await message.save();
  }

  async markMessageAsRead(messageId: string, userId: string) {
    return await this.messageModel.findByIdAndUpdate(
      messageId,
      {
        $addToSet: { readBy: userId },
        readAt: new Date(),
      },
      { new: true },
    );
  }

  async getConversationMessages(conversationId: string, limit = 50) {
    return await this.messageModel
      .find({ conversationId, isDeleted: false })
      .sort({ createdAt: -1 })
      .limit(limit)
      .populate('senderId', 'name email avatar');
  }
}
```

---

## 🚀 Step 4: Environment Configuration

Add to `.env`:

```env
# Socket.IO Configuration
SOCKET_IO_ENABLED=true
SOCKET_IO_PORT=3001
SOCKET_IO_NAMESPACE=/chat
SOCKET_IO_CORS_ORIGIN=http://localhost:3000,http://localhost:8080
SOCKET_IO_RECONNECTION_DELAY=1000
SOCKET_IO_RECONNECTION_DELAY_MAX=5000
SOCKET_IO_RECONNECTION_ATTEMPTS=5
```

---

## 🧪 Step 5: Testing Socket.IO Connection

### Using Thunder Client or Postman WebSocket test:

```javascript
// Connect to Socket.IO
const socket = io('http://localhost:3000/chat', {
  auth: {
    authorization: `Bearer YOUR_JWT_TOKEN`,
  },
});

// Event: Connected
socket.on('connect', () => {
  console.log('✅ Connected to server');

  // Join a chat
  socket.emit('chat:join', { chatId: 'chat-123' });
});

// Event: Receive message
socket.on('message:receive', (data) => {
  console.log('📩 New message:', data);
});

// Event: User typing
socket.on('chat:typing:update', (data) => {
  console.log(`${data.userName} is typing...`);
});

// Event: User online
socket.on('user:online', (data) => {
  console.log(`${data.userId} is online`);
});

// Send message
socket.emit('message:send', {
  chatId: 'chat-123',
  text: 'Hello, this is a test message!',
});

// Typing indicator
socket.emit('chat:typing', { chatId: 'chat-123' });

// Message read
socket.emit('message:read', {
  messageId: 'msg-123',
  chatId: 'chat-123',
});
```

---

## 📊 Socket.IO Events Map

| **Event** | **Sender** | **Receiver** | **Purpose** |
|-----------|-----------|------------|-----------|
| `connect` | Socket.IO | Client | Connection established |
| `disconnect` | Socket.IO | Client | Connection lost |
| `chat:join` | Client | Server | Join chat room |
| `chat:leave` | Client | Server | Leave chat room |
| `chat:user-joined` | Server | Clients in room | Notify user joined |
| `chat:user-left` | Server | Clients in room | Notify user left |
| `message:send` | Client | Server | Send message |
| `message:receive` | Server | Clients in room | Receive message |
| `chat:typing` | Client | Server | User is typing |
| `chat:typing:update` | Server | Clients in room | Display typing indicator |
| `chat:stop-typing` | Client | Server | User stopped typing |
| `chat:stop-typing:update` | Server | Clients in room | Clear typing indicator |
| `message:read` | Client | Server | Mark message as read |
| `message:read:update` | Server | Clients in room | Update read receipt |
| `user:online` | Server | All Clients | User came online |
| `user:offline` | Server | All Clients | User went offline |
| `notification:new` | Server | User's room | Send notification |
| `notification:dismiss` | Client | Server | Clear notification |

---

## 🔒 Security Features

✅ **JWT Authentication** - All connections require valid token  
✅ **User Isolation** - Users only receive notifications for their rooms  
✅ **Room-based Access** - Validate user can join specific chat  
✅ **Message Validation** - Sanitize and validate all incoming data  
✅ **Rate Limiting** - Prevent message spam (coming in Stage 5 Phase 2)  

---

## 🎯 What's Next

- [ ] Create Chat Controller for REST API
- [ ] Create Conversation/Chat model
- [ ] Implement message history pagination
- [ ] Add typing indicator timeout (3s auto-clear)
- [ ] Implement read receipts in UI
- [ ] Test with Flutter Socket.IO client
- [ ] Add message deletion & editing
- [ ] Implement group chat support
- [ ] Add media/file upload support

---

## 📚 Resources

- [Socket.IO Documentation](https://socket.io/docs/)
- [NestJS WebSocket Documentation](https://docs.nestjs.com/websockets/gateways)
- [Socket.IO with Redis Adapter](https://socket.io/docs/v4/redis-adapter/)

---

**SwiftNest Backend** | Stage 5 🚀 | Socket.IO Setup Complete
