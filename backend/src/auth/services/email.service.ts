import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class EmailService {
  private transporter: nodemailer.Transporter;
  private readonly logger = new Logger(EmailService.name);

  constructor(private configService: ConfigService) {
    this.initializeTransporter();
  }

  private initializeTransporter() {
    const smtpHost = this.configService.get<string>('SMTP_HOST') || 'smtp.gmail.com';
    const smtpPort = this.configService.get<number>('SMTP_PORT') || 587;
    const smtpUser = this.configService.get<string>('SMTP_USER');
    const smtpPass = this.configService.get<string>('SMTP_PASS');

    // Check if email is configured
    if (!smtpUser || !smtpPass) {
      this.logger.warn('Email service not configured. Using mock transporter.');
      // For development without email config
      return;
    }

    this.transporter = nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpPort === 465,
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
    });

    this.logger.log(`Email service initialized: ${smtpHost}:${smtpPort}`);
  }

  async sendOTPEmail(email: string, otp: string, expiresInMinutes: number = 10): Promise<void> {
    const subject = '🔐 Your SwiftNest OTP Code';
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 8px 8px 0 0; color: white;">
          <h1 style="margin: 0; font-size: 24px;">SwiftNest Verification</h1>
        </div>
        <div style="padding: 30px; background: #f9f9f9; border-radius: 0 0 8px 8px;">
          <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
            Hi there! Your OTP code is:
          </p>
          <div style="background: white; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0; border: 2px solid #667eea;">
            <h2 style="margin: 0; color: #667eea; letter-spacing: 4px; font-size: 32px;">
              ${otp}
            </h2>
          </div>
          <p style="font-size: 14px; color: #666; margin: 20px 0;">
            This code will expire in <strong>${expiresInMinutes} minutes</strong>.
          </p>
          <p style="font-size: 14px; color: #666; margin: 20px 0;">
            <strong>⚠️ Important:</strong> Never share this code with anyone. We will never ask for it.
          </p>
          <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
          <p style="font-size: 12px; color: #999;">
            If you didn't request this code, you can safely ignore this email.
          </p>
        </div>
      </div>
    `;

    const textContent = `
      Your SwiftNest OTP Code:
      ${otp}

      This code will expire in ${expiresInMinutes} minutes.

      Important: Never share this code with anyone. We will never ask for it.

      If you didn't request this code, you can safely ignore this email.
    `;

    await this.sendEmail(email, subject, htmlContent, textContent);
  }

  async sendVerificationEmail(email: string, verificationLink: string): Promise<void> {
    const subject = '📧 Verify Your SwiftNest Email';
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 8px 8px 0 0; color: white;">
          <h1 style="margin: 0; font-size: 24px;">Verify Your Email</h1>
        </div>
        <div style="padding: 30px; background: #f9f9f9; border-radius: 0 0 8px 8px;">
          <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
            Welcome to SwiftNest! Click the button below to verify your email:
          </p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${verificationLink}" style="background: #667eea; color: white; padding: 12px 30px; border-radius: 6px; text-decoration: none; font-size: 16px; font-weight: bold;">
              Verify Email
            </a>
          </div>
          <p style="font-size: 14px; color: #666;">
            Or copy and paste this link in your browser:
          </p>
          <p style="font-size: 12px; color: #667eea; word-break: break-all;">
            ${verificationLink}
          </p>
          <p style="font-size: 12px; color: #666; margin-top: 20px;">
            This link will expire in 24 hours.
          </p>
        </div>
      </div>
    `;

    const textContent = `
      Verify Your Email

      Click the link below to verify your email:
      ${verificationLink}

      This link will expire in 24 hours.

      If you didn't create this account, you can safely ignore this email.
    `;

    await this.sendEmail(email, subject, htmlContent, textContent);
  }

  async sendPasswordResetEmail(email: string, resetLink: string): Promise<void> {
    const subject = '🔑 Reset Your SwiftNest Password';
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 8px 8px 0 0; color: white;">
          <h1 style="margin: 0; font-size: 24px;">Reset Your Password</h1>
        </div>
        <div style="padding: 30px; background: #f9f9f9; border-radius: 0 0 8px 8px;">
          <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
            We received a request to reset your password. Click the button below to proceed:
          </p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${resetLink}" style="background: #667eea; color: white; padding: 12px 30px; border-radius: 6px; text-decoration: none; font-size: 16px; font-weight: bold;">
              Reset Password
            </a>
          </div>
          <p style="font-size: 14px; color: #666;">
            Or copy and paste this link in your browser:
          </p>
          <p style="font-size: 12px; color: #667eea; word-break: break-all;">
            ${resetLink}
          </p>
          <p style="font-size: 12px; color: #666; margin-top: 20px;">
            This link will expire in 1 hour.
          </p>
          <p style="font-size: 12px; color: #999;">
            If you didn't request this reset, you can safely ignore this email.
          </p>
        </div>
      </div>
    `;

    const textContent = `
      Reset Your Password

      Click the link below to reset your password:
      ${resetLink}

      This link will expire in 1 hour.

      If you didn't request this reset, you can safely ignore this email.
    `;

    await this.sendEmail(email, subject, htmlContent, textContent);
  }

  private async sendEmail(
    to: string,
    subject: string,
    htmlContent: string,
    textContent: string,
  ): Promise<void> {
    try {
      if (!this.transporter) {
        this.logger.debug(`[Mock Email] To: ${to}, Subject: ${subject}`);
        return;
      }

      const result = await this.transporter.sendMail({
        from: this.configService.get<string>('SMTP_USER'),
        to,
        subject,
        html: htmlContent,
        text: textContent,
      });

      this.logger.log(`Email sent successfully: ${result.messageId}`);
    } catch (error) {
      this.logger.error(`Failed to send email to ${to}:`, error);
      throw error;
    }
  }
}
