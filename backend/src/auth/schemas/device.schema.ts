import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Device extends Document {
  @Prop({ required: true, type: Types.ObjectId, ref: 'User', index: true })
  userId: Types.ObjectId;

  @Prop({ required: true })
  name: string; // e.g., "Chrome on Windows", "Safari on iPhone"

  @Prop({ default: null })
  ipAddress?: string;

  @Prop({ default: null })
  userAgent?: string;

  @Prop({ default: null })
  deviceId?: string; // Unique device identifier from client

  @Prop({ default: 'unknown' })
  osType: string; // 'Android', 'iOS', 'Windows', 'Mac', 'Linux'

  @Prop({ default: 'unknown' })
  osVersion?: string;

  @Prop({ default: false })
  isCurrent: boolean; // Whether this is the current active device

  @Prop({ default: new Date() })
  lastSeenAt: Date;

  @Prop({ default: null })
  lastActivityAt?: Date;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: null })
  revokedAt?: Date;

  // Timestamps
  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const DeviceSchema = SchemaFactory.createForClass(Device);

// Indexes for efficient queries
DeviceSchema.index({ userId: 1, isActive: 1 });
DeviceSchema.index({ userId: 1, isCurrent: 1 });
DeviceSchema.index({ userId: 1, createdAt: -1 });
