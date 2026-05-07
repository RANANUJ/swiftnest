import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class EmailVerification extends Document {
  @Prop({ required: true, index: true })
  email: string;

  @Prop({ required: true })
  token: string; // Hashed verification token

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ required: true })
  expiresAt: Date;

  @Prop({ default: false })
  verified: boolean;

  @Prop({ nullable: true })
  verifiedAt?: Date;

  @Prop({ default: 0 })
  attempts: number;

  @Prop({ default: 5 })
  maxAttempts: number;
}

export const EmailVerificationSchema = SchemaFactory.createForClass(EmailVerification);

// Index for automatic deletion of expired tokens
EmailVerificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
EmailVerificationSchema.index({ email: 1, userId: 1 });
