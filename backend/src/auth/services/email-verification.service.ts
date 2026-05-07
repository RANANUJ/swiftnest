import { Injectable, BadRequestException, Logger, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import * as bcrypt from 'bcrypt';
import { EmailVerification } from '../schemas/email-verification.schema';
import { User } from '../schemas/user.schema';
import { EmailService } from './email.service';

@Injectable()
export class EmailVerificationService {
  private readonly logger = new Logger(EmailVerificationService.name);

  constructor(
    @InjectModel(EmailVerification.name) private emailVerificationModel: Model<EmailVerification>,
    @InjectModel(User.name) private userModel: Model<User>,
    private emailService: EmailService,
    private configService: ConfigService,
  ) {}

  /**
   * Generate verification token for new user
   * Called during signup
   */
  async generateAndSendVerificationEmail(
    email: string,
    userId: string,
  ): Promise<{ success: boolean; message: string; expiresIn: number }> {
    this.logger.log(`Generating verification email for ${email}`);

    // Delete any existing unverified tokens for this email
    await this.emailVerificationModel.deleteMany({
      email,
      verified: false,
    });

    // Generate random token
    const token = crypto.randomBytes(32).toString('hex');
    const hashedToken = await bcrypt.hash(token, 10);

    // Token expires in 24 hours
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

    // Save verification record
    const verification = new this.emailVerificationModel({
      email,
      token: hashedToken,
      userId,
      expiresAt,
    });

    await verification.save();
    this.logger.log(`Verification token saved for ${email}`);

    // Generate verification link to send to user
    const verificationLink = `${this.configService.get<string>('APP_URL')}/auth/verify-email?token=${token}`;

    // Send verification email
    try {
      await this.emailService.sendVerificationEmail(email, verificationLink);
      this.logger.log(`Verification email sent to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send verification email to ${email}:`, error);
      // Don't throw - token is still valid
    }

    return {
      success: true,
      message: 'Verification email sent. Check your inbox.',
      expiresIn: 24 * 60 * 60, // 24 hours in seconds
    };
  }

  /**
   * Verify email token and mark user's email as verified
   */
  async verifyEmailToken(token: string): Promise<{ success: boolean; email: string }> {
    this.logger.log(`Verifying email token`);

    // Find the verification record
    const verification = await this.emailVerificationModel.findOne({
      verified: false,
    }).sort({ createdAt: -1 });

    if (!verification) {
      this.logger.warn(`No verification found for token`);
      throw new BadRequestException('Invalid or expired verification link.');
    }

    // Check if token is expired
    if (new Date() > verification.expiresAt) {
      this.logger.warn(`Verification token expired for ${verification.email}`);
      await this.emailVerificationModel.deleteOne({ _id: verification._id });
      throw new BadRequestException('Verification link has expired. Please request a new one.');
    }

    // Compare token
    const isValid = await bcrypt.compare(token, verification.token);

    if (!isValid) {
      verification.attempts += 1;
      await verification.save();
      this.logger.warn(`Invalid token attempt ${verification.attempts} for ${verification.email}`);

      if (verification.attempts >= verification.maxAttempts) {
        await this.emailVerificationModel.deleteOne({ _id: verification._id });
        throw new BadRequestException('Too many invalid attempts. Please request a new verification email.');
      }

      throw new BadRequestException(`Invalid verification link. ${verification.maxAttempts - verification.attempts} attempts remaining.`);
    }

    // Mark verification as complete
    verification.verified = true;
    verification.verifiedAt = new Date();
    await verification.save();

    // Update user's email verification status
    const user = await this.userModel.findById(verification.userId);
    if (user) {
      user.isEmailVerified = true;
      user.emailVerifiedAt = new Date();
      await user.save();
      this.logger.log(`Email verified for user ${verification.email}`);
    }

    return {
      success: true,
      email: verification.email,
    };
  }

  /**
   * Resend verification email
   */
  async resendVerificationEmail(email: string): Promise<{ success: boolean; message: string; expiresIn: number }> {
    this.logger.log(`Resending verification email for ${email}`);

    // Find user
    const user = await this.userModel.findOne({ email });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check if already verified
    if (user.isEmailVerified) {
      throw new BadRequestException('Email is already verified');
    }

    // Check rate limiting - max 3 resend requests per hour
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    const recentVerifications = await this.emailVerificationModel.countDocuments({
      email,
      createdAt: { $gte: oneHourAgo },
    });

    if (recentVerifications >= 3) {
      this.logger.warn(`Rate limit exceeded for ${email}`);
      throw new BadRequestException('Too many verification requests. Please try again in 1 hour.');
    }

    // Generate new verification email
    return this.generateAndSendVerificationEmail(email, user._id.toString());
  }

  /**
   * Check if user's email is verified
   */
  async isEmailVerified(userId: string): Promise<boolean> {
    const user = await this.userModel.findById(userId);
    return user?.isEmailVerified || false;
  }

  /**
   * Get verification status
   */
  async getVerificationStatus(email: string): Promise<{ email: string; verified: boolean; verifiedAt?: Date }> {
    const user = await this.userModel.findOne({ email });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      email: user.email,
      verified: user.isEmailVerified,
      verifiedAt: user.emailVerifiedAt,
    };
  }

  /**
   * Clean up expired tokens
   */
  async cleanupExpiredTokens(): Promise<void> {
    const result = await this.emailVerificationModel.deleteMany({
      expiresAt: { $lt: new Date() },
    });

    this.logger.log(`Deleted ${result.deletedCount} expired verification tokens`);
  }
}
