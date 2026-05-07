import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Message } from './schemas/message.schema';
import { Conversation } from './schemas/conversation.schema';

@Injectable()
export class ChatService {
  constructor(
    @InjectModel(Message.name) private messageModel: Model<Message>,
    @InjectModel(Conversation.name) private conversationModel: Model<Conversation>,
  ) {}

  // ============ CONVERSATION OPERATIONS ============

  async getOrCreateConversation(userId: string, otherUserId: string) {
    const userIds = [new Types.ObjectId(userId), new Types.ObjectId(otherUserId)].sort(
      (a, b) => a.toString().localeCompare(b.toString()),
    );

    let conversation = await this.conversationModel.findOne({
      participants: { $all: userIds },
      type: 'direct',
    });

    if (!conversation) {
      conversation = await this.conversationModel.create({
        participants: userIds,
        type: 'direct',
      });
    }

    return conversation;
  }

  async getConversationById(conversationId: string) {
    return await this.conversationModel
      .findById(conversationId)
      .populate('participants', 'name email avatar');
  }

  async getUserConversations(userId: string, limit = 50) {
    return await this.conversationModel
      .find({
        participants: new Types.ObjectId(userId),
        isArchived: false,
      })
      .populate('participants', 'name email avatar')
      .sort({ lastMessageAt: -1 })
      .limit(limit);
  }

  // ============ MESSAGE OPERATIONS ============

  async saveMessage(data: {
    senderId: string;
    conversationId: string;
    text: string;
    mediaUrl?: string;
  }) {
    const message = await this.messageModel.create({
      senderId: new Types.ObjectId(data.senderId),
      conversationId: new Types.ObjectId(data.conversationId),
      text: data.text,
      mediaUrl: data.mediaUrl,
      createdAt: new Date(),
    });

    // Update conversation's last message
    if (message && message._id) {
      await this.conversationModel.findByIdAndUpdate(data.conversationId, {
        lastMessage: message._id,
        lastMessageAt: new Date(),
      });
    }

    return await message.populate('senderId', 'name email avatar');
  }

  async getConversationMessages(conversationId: string, limit = 50, skip = 0) {
    const messages = await this.messageModel
      .find({
        conversationId: new Types.ObjectId(conversationId),
        isDeleted: false,
      })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('senderId', 'name email avatar');

    return messages || [];
  }

  async markMessageAsRead(messageId: string, userId: string) {
    return await this.messageModel.findByIdAndUpdate(
      messageId,
      {
        $addToSet: { readBy: new Types.ObjectId(userId) },
        readAt: new Date(),
      },
      { new: true },
    );
  }

  async deleteMessage(messageId: string, userId: string) {
    const message = await this.messageModel.findById(messageId);

    if (!message || message.senderId.toString() !== userId) {
      throw new Error('Unauthorized: Only sender can delete message');
    }

    return await this.messageModel.findByIdAndUpdate(
      messageId,
      { isDeleted: true },
      { new: true },
    );
  }

  async getMessageById(messageId: string) {
    return await this.messageModel
      .findById(messageId)
      .populate('senderId', 'name email avatar');
  }
}


