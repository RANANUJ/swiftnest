import { Controller, Get, Param, UseGuards, Req, Query } from '@nestjs/common';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private chatService: ChatService) {}

  @Get('conversations')
  async getConversations(@Req() req) {
    return await this.chatService.getUserConversations(req.user.id);
  }

  @Get('conversations/:conversationId')
  async getConversation(@Param('conversationId') conversationId: string) {
    return await this.chatService.getConversationById(conversationId);
  }

  @Get('conversations/:conversationId/messages')
  async getMessages(
    @Param('conversationId') conversationId: string,
    @Query('limit') limit: string = '50',
    @Query('skip') skip: string = '0',
  ) {
    return await this.chatService.getConversationMessages(
      conversationId,
      parseInt(limit),
      parseInt(skip),
    );
  }

  @Get('messages/:messageId')
  async getMessage(@Param('messageId') messageId: string) {
    return await this.chatService.getMessageById(messageId);
  }
}
