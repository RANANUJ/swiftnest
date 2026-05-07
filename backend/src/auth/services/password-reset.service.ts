import { Injectable, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { PasswordReset } from '../schemas/password-reset.schema';
import { User } from '../schemas/user.schema';
import { EmailService } from './email.service';
import { LoggerServiceImpl } from '../../common/logger/logger.service';

@Injectable()
export class PasswordResetService {
  private readonly RESET_TOKEN_EXPIRATION = 3600; // 1 hour in seconds
  private readonly MAX_RESET_ATTEMPTS = 5;
  private readonly RESET_RATE_LIMIT = 3; // Max 3 reset requests per hour
  private readonly BCRYPT_ROUNDS = 10;

  constructor(
    @InjectModel(PasswordReset.name) private passwordResetModel: Model<PasswordReset>,
    @InjectModel(User.name) private userModel: Model<User>,
    private emailService: EmailService,
    private configService: ConfigService,
    private logger: LoggerServiceImpl,
  ) {}

  /**
   * Generate reset token and send password reset email
   */
  async generateAndSendResetEmail(email: string): Promise<{ success: boolean; message: string; expiresIn: number }> {
    // Check if user exists
    const user = await this.userModel.findOne({ email });
    if (!user) {
      // Don't reveal if user exists for security
      return {
        success: true,
        message: 'If email exists, password reset link sent to your inbox.',
        expiresIn: this.RESET_TOKEN_EXPIRATION,
      };
    }

    // Rate limiting: Check for too many reset requests in last hour
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    const recentRequests = await this.passwordResetModel.countDocuments({
      email,
      createdAt: { $gte: oneHourAgo },
      used: false,
    });

    if (recentRequests >= this.RESET_RATE_LIMIT) {
      throw new BadRequestException(
        `Too many reset requests. Please try again later.`,
      );
    }

    // Generate random token
    const tokenBuffer = crypto.randomBytes(32);
    const token = tokenBuffer.toString('hex');

    // Hash token for storage
    const hashedToken = await bcrypt.hash(token, this.BCRYPT_ROUNDS);

    // Calculate expiration time
    const expiresAt = new Date(Date.now() + this.RESET_TOKEN_EXPIRATION * 1000);

    // Save to database
    try {
      await this.passwordResetModel.create({
        email,
        token: hashedToken,
        expiresAt,
        used: false,
        attempts: 0,
        maxAttempts: this.MAX_RESET_ATTEMPTS,
      });
    } catch (error) {
      this.logger.error(
        `[PasswordResetService] Error saving reset token: ${error.message}`,
        'generateAndSendResetEmail',
      );
      throw new InternalServerErrorException('Failed to initiate password reset');
    }

    // Generate reset link
    const baseUrl = this.configService.get<string>('FRONTEND_URL') || 'http://localhost:3000';
    const resetLink = `${baseUrl}/reset-password?token=${token}`;

    // Send email
    try {
      await this.emailService.sendPasswordResetEmail(email, resetLink);
      this.logger.log(
        `[PasswordResetService] Password reset email sent to ${email}`,
        'generateAndSendResetEmail',
      );
    } catch (error) {
      this.logger.error(
        `[PasswordResetService] Error sending reset email: ${error.message}`,
        'generateAndSendResetEmail',
      );
      // Don't fail - email service might be in mock mode
    }

    return {
      success: true,
      message: 'If email exists, password reset link sent to your inbox.',
      expiresIn: this.RESET_TOKEN_EXPIRATION,
    };
  }

  /**
   * Verify reset token and reset password
   */
  async resetPassword(
    token: string,
    newPassword: string,
  ): Promise<{ success: boolean; message: string; email: string }> {
    // Validate token format
    if (!token || token.length < 32) {
      throw new BadRequestException('Invalid reset link.');
    }

    // Find reset record with matching token (not yet used)
    const resetRecords = await this.passwordResetModel.find({
      used: false,
      attempts: { $lt: this.MAX_RESET_ATTEMPTS },
    });

    let resetRecord: any = null;
    for (const record of resetRecords) {
      try {
        const isValidToken = await bcrypt.compare(token, record.token);
        if (isValidToken) {
          resetRecord = record;
          break;
        }
      } catch (error) {
        // Continue to next record
        continue;
      }
    }

    if (!resetRecord) {
      // Token not found or already used - track attempt
      throw new BadRequestException('Invalid or expired reset link.');
    }

    // Check if token has expired
    if (new Date() > resetRecord.expiresAt) {
      throw new BadRequestException('Reset link has expired. Please request a new one.');
    }

    // Update attempt counter
    resetRecord.attempts += 1;
    await resetRecord.save();

    // Find user and update password
    const user = await this.userModel.findOne({ email: resetRecord.email });
    if (!user) {
      throw new BadRequestException('User not found.');
    }

    // Update password (will be hashed by pre-save hook)
    user.password = newPassword;
    user.tokenVersion += 1; // Invalidate all existing tokens
    await user.save();

    // Mark reset token as used
    resetRecord.used = true;
    resetRecord.usedAt = new Date();
    await resetRecord.save();

    this.logger.log(
      `[PasswordResetService] Password reset successful for ${user.email}`,
      'resetPassword',
    );

    return {
      success: true,
      message: 'Password reset successfully. Please login with your new password.',
      email: user.email,
    };
  }

  /**
   * Check if reset token is valid (but don't reset password)
   */
  async isResetTokenValid(token: string): Promise<{ valid: boolean; email?: string }> {
    if (!token) return { valid: false };

    const resetRecords = await this.passwordResetModel.find({
      used: false,
      attempts: { $lt: this.MAX_RESET_ATTEMPTS },
    });

    for (const record of resetRecords) {
      try {
        const isValidToken = await bcrypt.compare(token, record.token);
        if (isValidToken && new Date() <= record.expiresAt) {
          return { valid: true, email: record.email };
        }
      } catch (error) {
        continue;
      }
    }

    return { valid: false };
  }

  /**
   * Cleanup expired tokens (manual - also handled by TTL index)
   */
  async cleanupExpiredTokens(): Promise<{ deleted: number }> {
    const result = await this.passwordResetModel.deleteMany({
      expiresAt: { $lt: new Date() },
    });

    return { deleted: result.deletedCount };
  }
}
