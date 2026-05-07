import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import * as bcrypt from 'bcrypt';

@Schema({ timestamps: true })
export class User extends Document {
  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  password: string;

  @Prop({ required: true })
  name: string;

  @Prop({ default: null })
  phone?: string;

  @Prop({ default: null })
  avatar?: string;

  @Prop({ default: false })
  isEmailVerified: boolean;

  @Prop({ default: null })
  emailVerifiedAt?: Date;

  @Prop({ default: false })
  isPhoneVerified: boolean;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ type: [String], default: [] })
  blockedUsers: string[];

  @Prop({ type: [String], default: [] })
  blockedBy: string[];

  @Prop({ default: 0 })
  tokenVersion: number;

  @Prop({ default: null })
  lastLogin?: Date;

  @Prop({ type: [String], default: [] })
  deviceIds: string[];
}

export const UserSchema = SchemaFactory.createForClass(User);

// Pre-save hook to hash password
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    return;
  }

  const salt = await bcrypt.genSalt(parseInt(process.env.BCRYPT_ROUNDS || '12'));
  const hashedPassword = await bcrypt.hash(this.password, salt);
  this.password = hashedPassword;
});

// Method to compare password
UserSchema.methods.matchPassword = async function (password: string) {
  return await bcrypt.compare(password, this.password);
};

// Method to increment token version (invalidates all old tokens)
UserSchema.methods.incrementTokenVersion = function () {
  this.tokenVersion += 1;
  return this.save();
};
