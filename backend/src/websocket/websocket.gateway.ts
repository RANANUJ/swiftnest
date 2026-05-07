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
import { Injectable } from '@nestjs/common';
import { WebSocketAuthGuard } from './guards/websocket-auth.guard';
import { SocketUser } from './decorators/socket-user.decorator';
import { ChatService } from '../chat/chat.service';
import { Logger } from '@nestjs/common';

@Injectable()
@WebSocketGateway({
  namespace: 'chat',
  cors: {
    origin: process.env.SOCKET_IO_CORS_ORIGIN || '*',
    credentials: true,
  },
  transports: ['websocket', 'polling'],
})
export class ChatWebSocketGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private logger = new Logger('WebSocketGateway');

  constructor(
    private authGuard: WebSocketAuthGuard,
    private chatService: ChatService,
  ) {}

  // ============ CONNECTION & DISCONNECTION ============

  async handleConnection(@ConnectedSocket() client: Socket) {
    try {
      const user = await this.authGuard.validateConnection(client);
      client.data.user = user;

      this.logger.log(`✅ User connected: ${user.email} (${client.id})`);

      // Join user's personal room for notifications
      client.join(`user:${user.id}`);

      // Broadcast user is online
      this.server.emit('user:online', {
        userId: user.id,
        userName: user.name,
        timestamp: new Date(),
      });
    } catch (error) {
      this.logger.error(`❌ Connection failed: ${error.message}`);
      client.disconnect();
    }
  }

  async handleDisconnect(@ConnectedSocket() client: Socket) {
    const user = client.data.user;
    if (user) {
      this.logger.log(`❌ User disconnected: ${user.email} (${client.id})`);

      // Broadcast user is offline
      this.server.emit('user:offline', {
        userId: user.id,
        userName: user.name,
        timestamp: new Date(),
      });
    }
  }

  // ============ CHAT ROOM EVENTS ============

  // User joins a chat room
  @SubscribeMessage('chat:join')
  handleChatJoin(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { conversationId: string },
  ) {
    const roomName = `conversation:${data.conversationId}`;
    client.join(roomName);

    this.logger.log(`📍 User ${user.id} joined conversation ${data.conversationId}`);

    // Notify others in room
    this.server.to(roomName).emit('chat:user-joined', {
      userId: user.id,
      userName: user.name,
      userAvatar: user.avatar,
      timestamp: new Date(),
    });
  }

  // User leaves a chat room
  @SubscribeMessage('chat:leave')
  handleChatLeave(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { conversationId: string },
  ) {
    const roomName = `conversation:${data.conversationId}`;
    client.leave(roomName);

    this.logger.log(`👋 User ${user.id} left conversation ${data.conversationId}`);

    this.server.to(roomName).emit('chat:user-left', {
      userId: user.id,
      userName: user.name,
      timestamp: new Date(),
    });
  }

  // ============ MESSAGE EVENTS ============

  // Send message
  @SubscribeMessage('message:send')
  async handleMessageSend(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody()
    data: {
      conversationId: string;
      text: string;
      mediaUrl?: string;
    },
  ) {
    try {
      // Save message to MongoDB
      const message = await this.chatService.saveMessage({
        senderId: user.id,
        conversationId: data.conversationId,
        text: data.text,
        mediaUrl: data.mediaUrl,
      });

      if (!message) {
        throw new Error('Failed to save message');
      }

      // Broadcast to all users in conversation
      const roomName = `conversation:${data.conversationId}`;
      this.server.to(roomName).emit('message:receive', {
        messageId: message._id,
        senderId: user.id,
        senderName: user.name,
        senderAvatar: user.avatar,
        text: message.text,
        mediaUrl: message.mediaUrl,
        createdAt: message.createdAt,
        readBy: message.readBy || [],
      });

      this.logger.log(`💬 Message sent in conversation ${data.conversationId}`);
    } catch (error) {
      this.logger.error(`Error sending message: ${error.message}`);
      client.emit('error', { message: error.message });
    }
  }

  // Typing indicator
  @SubscribeMessage('chat:typing')
  handleTyping(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { conversationId: string },
  ) {
    const roomName = `conversation:${data.conversationId}`;

    this.server.to(roomName).emit('chat:typing:update', {
      userId: user.id,
      userName: user.name,
      conversationId: data.conversationId,
      timestamp: new Date(),
    });

    this.logger.debug(`⌨️  ${user.name} is typing in ${data.conversationId}`);
  }

  // Stop typing
  @SubscribeMessage('chat:stop-typing')
  handleStopTyping(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { conversationId: string },
  ) {
    const roomName = `conversation:${data.conversationId}`;

    this.server.to(roomName).emit('chat:stop-typing:update', {
      userId: user.id,
      conversationId: data.conversationId,
      timestamp: new Date(),
    });
  }

  // ============ MESSAGE READ RECEIPTS ============

  // Mark message as read
  @SubscribeMessage('message:read')
  async handleMessageRead(
    @ConnectedSocket() client: Socket,
    @SocketUser() user: any,
    @MessageBody() data: { messageId: string; conversationId: string },
  ) {
    try {
      const message = await this.chatService.markMessageAsRead(data.messageId, user.id);

      if (!message) {
        throw new Error('Message not found');
      }

      const roomName = `conversation:${data.conversationId}`;
      this.server.to(roomName).emit('message:read:update', {
        messageId: data.messageId,
        readBy: message.readBy || [],
        readAt: message.readAt,
      });

      this.logger.log(`✓ Message ${data.messageId} marked as read by ${user.id}`);
    } catch (error) {
      this.logger.error(`Error marking message as read: ${error.message}`);
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

    this.logger.log(`🔔 Notification sent to user ${userId}`);
  }

  // Send notification to multiple users
  sendNotificationToUsers(userIds: string[], notification: any) {
    userIds.forEach((userId) => {
      this.sendNotification(userId, notification);
    });
  }

  // Dismiss notification
  @SubscribeMessage('notification:dismiss')
  handleNotificationDismiss(
    @SocketUser() user: any,
    @MessageBody() data: { notificationId: string },
  ) {
    this.logger.log(`🗑️  Notification ${data.notificationId} dismissed by ${user.id}`);
    // Additional logic to clear from database can be added here
  }

  // ============ HELPER METHODS ============

  // Get connected user count
  getConnectedUserCount(): number {
    return this.server.engine.clientsCount;
  }

  // Get users in a conversation room
  getUsersInConversation(conversationId: string): string[] {
    const roomName = `conversation:${conversationId}`;
    const socketsInRoom = this.server.sockets.adapter.rooms.get(roomName);
    return socketsInRoom ? Array.from(socketsInRoom) : [];
  }

  // Check if user is online
  isUserOnline(userId: string): boolean {
    const sockets = Array.from(this.server.sockets.sockets.values());
    return sockets.some((socket) => socket.data.user?.id === userId);
  }
}
