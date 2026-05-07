import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class OTP extends Document {
  @Prop({ required: true, index: true })
  email: string;

  @Prop({ required: true })
  code: string; // Hashed OTP code

  @Prop({ required: true, enum: ['signup', 'login', 'password-reset'] })
  type: 'signup' | 'login' | 'password-reset';

  @Prop({ type: Types.ObjectId, ref: 'User', nullable: true })
  userId?: Types.ObjectId;

  @Prop({ default: 0 })
  attempts: number;

  @Prop({ default: 5 })
  maxAttempts: number;

  @Prop({ required: true })
  expiresAt: Date;

  @Prop({ default: false })
  verified: boolean;

  @Prop({ nullable: true })
  verifiedAt?: Date;
}

export const OTPSchema = SchemaFactory.createForClass(OTP);

// Index for automatic deletion of expired OTPs
OTPSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
OTPSchema.index({ email: 1, type: 1 });
