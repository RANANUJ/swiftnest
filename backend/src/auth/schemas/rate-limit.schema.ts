import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class RateLimit extends Document {
  @Prop({ required: true, unique: true, index: true })
  key: string; // IP address or user ID

  @Prop({ default: 1 })
  requests: number;

  @Prop({ default: new Date() })
  windowStart: Date;

  @Prop({ required: true, index: true })
  resetAt: Date; // TTL field

  @Prop({ default: new Date() })
  createdAt: Date;

  @Prop({ default: new Date() })
  updatedAt: Date;
}

export const RateLimitSchema = SchemaFactory.createForClass(RateLimit);

// TTL index - Auto delete documents when resetAt is reached
RateLimitSchema.index({ resetAt: 1 }, { expireAfterSeconds: 0 });
