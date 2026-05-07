import { Injectable, BadRequestException, HttpException, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { OTP } from '../schemas/otp.schema';
import { EmailService } from './email.service';

@Injectable()
export class OTPService {
  private readonly logger = new Logger(OTPService.name);

  constructor(
    @InjectModel(OTP.name) private otpModel: Model<OTP>,
    private emailService: EmailService,
    private configService: ConfigService,
  ) {}

  /**
   * Generate and send OTP to email
   */
  async generateAndSendOTP(
    email: string,
    type: 'signup' | 'login' | 'password-reset',
    userId?: string,
  ): Promise<{ success: boolean; message: string; expiresIn: number }> {
    this.logger.log(`Generating OTP for ${email} (${type})`);

    // Check rate limiting - max 3 OTP requests per hour
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    const recentOTPs = await this.otpModel.countDocuments({
      email,
      type,
      createdAt: { $gte: oneHourAgo },
    });

    if (recentOTPs >= 3) {
      this.logger.warn(`Rate limit exceeded for ${email} (${type})`);
      throw new HttpException(
        'Too many OTP requests. Please try again in 1 hour.',
        429,
      );
    }

    // Delete any existing unverified OTPs for this email/type
    await this.otpModel.deleteMany({
      email,
      type,
      verified: false,
    });

    // Generate 6-digit OTP code
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedCode = await bcrypt.hash(otpCode, 10);

    // OTP expires in 10 minutes
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    // Save OTP to database
    const otp = new this.otpModel({
      email,
      code: hashedCode,
      type,
      userId: userId || undefined,
      expiresAt,
    });

    await otp.save();
    this.logger.log(`OTP saved for ${email}`);

    // Send OTP via email
    try {
      await this.emailService.sendOTPEmail(email, otpCode, 10);
      this.logger.log(`OTP email sent to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send OTP email to ${email}:`, error);
      // Don't throw - OTP is still valid, but email failed
      // In production, you might want to retry or alert admins
    }

    return {
      success: true,
      message: 'OTP sent to your email. Check your inbox.',
      expiresIn: 10 * 60, // 10 minutes in seconds
    };
  }

  /**
   * Verify OTP code
   */
  async verifyOTP(
    email: string,
    code: string,
    type: 'signup' | 'login' | 'password-reset',
  ): Promise<{ verified: boolean; userId?: string }> {
    this.logger.log(`Verifying OTP for ${email} (${type})`);

    // Find the most recent OTP for this email/type
    const otp = await this.otpModel.findOne({
      email,
      type,
      verified: false,
    }).sort({ createdAt: -1 });

    if (!otp) {
      this.logger.warn(`No OTP found for ${email} (${type})`);
      throw new BadRequestException('Invalid or expired OTP. Please request a new one.');
    }

    // Check if OTP is expired
    if (new Date() > otp.expiresAt) {
      this.logger.warn(`OTP expired for ${email}`);
      await this.otpModel.deleteOne({ _id: otp._id });
      throw new BadRequestException('OTP has expired. Please request a new one.');
    }

    // Check attempts
    if (otp.attempts >= otp.maxAttempts) {
      this.logger.warn(`Max attempts exceeded for ${email}`);
      await this.otpModel.deleteOne({ _id: otp._id });
      throw new BadRequestException(
        'Too many attempts. Please request a new OTP.',
      );
    }

    // Compare OTP code
    const isValid = await bcrypt.compare(code, otp.code);

    if (!isValid) {
      otp.attempts += 1;
      await otp.save();
      this.logger.warn(`Invalid OTP attempt ${otp.attempts} for ${email}`);

      const remainingAttempts = otp.maxAttempts - otp.attempts;
      throw new BadRequestException(
        `Invalid OTP. ${remainingAttempts} attempts remaining.`,
      );
    }

    // Mark as verified
    otp.verified = true;
    otp.verifiedAt = new Date();
    await otp.save();

    this.logger.log(`OTP verified for ${email}`);

    return {
      verified: true,
      userId: otp.userId?.toString(),
    };
  }

  /**
   * Check if OTP is valid for the given email/type
   * (without consuming it)
   */
  async isOTPVerified(
    email: string,
    type: 'signup' | 'login' | 'password-reset',
  ): Promise<boolean> {
    const otp = await this.otpModel.findOne({
      email,
      type,
      verified: true,
    }).sort({ verifiedAt: -1 });

    if (!otp) return false;

    // Check if verified within last 5 minutes (gives time for user to complete action)
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
    return otp.verifiedAt! > fiveMinutesAgo;
  }

  /**
   * Mark OTP as used (consume it)
   */
  async consumeOTP(
    email: string,
    type: 'signup' | 'login' | 'password-reset',
  ): Promise<void> {
    // Find the most recent verified OTP
    const otp = await this.otpModel.findOne({
      email,
      type,
      verified: true,
    }).sort({ verifiedAt: -1 });

    if (otp) {
      otp.verified = false;
      await otp.save();
    }
  }

  /**
   * Clean up expired OTPs manually
   * (also done automatically by MongoDB TTL index)
   */
  async cleanupExpiredOTPs(): Promise<void> {
    const result = await this.otpModel.deleteMany({
      expiresAt: { $lt: new Date() },
    });

    this.logger.log(`Deleted ${result.deletedCount} expired OTPs`);
  }
}
