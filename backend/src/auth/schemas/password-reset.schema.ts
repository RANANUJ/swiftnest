import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ timestamps: true })
export class PasswordReset extends Document {
  @Prop({ required: true, index: true })
  email: string;

  @Prop({ required: true })
  token: string; // Hashed reset token

  @Prop({ required: true })
  expiresAt: Date;

  @Prop({ default: false })
  used: boolean;

  @Prop({ default: null })
  usedAt?: Date;

  @Prop({ default: 0 })
  attempts: number;

  @Prop({ default: 5 })
  maxAttempts: number;
}

export const PasswordResetSchema = SchemaFactory.createForClass(PasswordReset);

// TTL index - Auto delete documents 1 hour after creation
PasswordResetSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// Compound index for efficient queries
PasswordResetSchema.index({ email: 1, used: 1 });
