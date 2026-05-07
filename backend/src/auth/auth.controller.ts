import { Controller, Post, Body, UseGuards, Req, Inject, Get, Query, Param, Delete } from '@nestjs/common';
import { AuthService } from './auth.service';
import { SignupDto, LoginDto, RefreshTokenDto, AuthResponseDto } from './dto/auth.dto';
import { SendOTPDto, VerifyOTPDto, OTPResponseDto } from './dto/otp.dto';
import { RequestEmailVerificationDto, VerifyEmailTokenDto, EmailVerificationResponseDto } from './dto/email-verification.dto';
import { ForgotPasswordDto, ResetPasswordDto, PasswordResetResponseDto } from './dto/password-reset.dto';
import { RegisterDeviceDto, LogoutDeviceDto, ActiveDevicesResponseDto, LogoutDeviceResponseDto } from './dto/device.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RateLimitGuard, RateLimit } from './guards/rate-limit.guard';
import { OTPService } from './services/otp.service';
import { EmailVerificationService } from './services/email-verification.service';
import { PasswordResetService } from './services/password-reset.service';
import { DeviceService } from './services/device.service';
import { LoggerServiceImpl } from '../common/logger/logger.service';

@Controller('auth')
export class AuthController {
  constructor(
    private authService: AuthService,
    private otpService: OTPService,
    private emailVerificationService: EmailVerificationService,
    private passwordResetService: PasswordResetService,
    private deviceService: DeviceService,
    @Inject(LoggerServiceImpl) private logger: LoggerServiceImpl,
  ) {}

  @Post('signup')
  @UseGuards(RateLimitGuard)
  @RateLimit({ windowMs: 60 * 60 * 1000, maxRequests: 5 }) // 5 signups per hour
  async signup(@Body() signupDto: SignupDto): Promise<AuthResponseDto> {
    this.logger.log(`[API] POST /auth/signup - ${signupDto.email}`, 'AuthController');
    return this.authService.signup(signupDto);
  }

  @Post('login')
  @UseGuards(RateLimitGuard)
  @RateLimit({ windowMs: 15 * 60 * 1000, maxRequests: 10 }) // 10 login attempts per 15 minutes
  async login(@Body() loginDto: LoginDto): Promise<AuthResponseDto> {
    this.logger.log(`[API] POST /auth/login - ${loginDto.email}`, 'AuthController');
    return this.authService.login(loginDto);
  }

  @Post('refresh')
  async refreshToken(@Body() refreshTokenDto: RefreshTokenDto): Promise<AuthResponseDto> {
    this.logger.log(`[API] POST /auth/refresh`, 'AuthController');
    return this.authService.refreshToken(refreshTokenDto.refreshToken);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  async logout(@Req() req: any): Promise<{ message: string }> {
    const userId = req.user.userId;
    this.logger.log(`[API] POST /auth/logout - ${userId}`, 'AuthController');
    await this.authService.logout(userId);
    return { message: 'Logged out successfully' };
  }

  @Post('verify-token')
  @UseGuards(JwtAuthGuard)
  async verifyToken(@Req() req: any): Promise<{ valid: boolean; user: any }> {
    this.logger.log(`[API] POST /auth/verify-token`, 'AuthController');
    return { valid: true, user: req.user };
  }

  // ==================== OTP ENDPOINTS ====================

  @Post('send-otp')
  @UseGuards(RateLimitGuard)
  @RateLimit({ windowMs: 60 * 60 * 1000, maxRequests: 5 }) // 5 OTP requests per hour
  async sendOTP(@Body() sendOTPDto: SendOTPDto): Promise<OTPResponseDto> {
    this.logger.log(
      `[API] POST /auth/send-otp - ${sendOTPDto.email} (${sendOTPDto.type})`,
      'AuthController',
    );
    return this.otpService.generateAndSendOTP(
      sendOTPDto.email,
      sendOTPDto.type,
    );
  }

  @Post('verify-otp')
  @UseGuards(RateLimitGuard)
  @RateLimit({ windowMs: 15 * 60 * 1000, maxRequests: 10 }) // 10 verify attempts per 15 minutes
  async verifyOTP(@Body() verifyOTPDto: VerifyOTPDto): Promise<AuthResponseDto> {
    this.logger.log(
      `[API] POST /auth/verify-otp - ${verifyOTPDto.email} (${verifyOTPDto.type})`,
      'AuthController',
    );
    // Verify OTP and return tokens
    return this.authService.verifyOTPAndGenerateTokens(
      verifyOTPDto.email,
      verifyOTPDto.code,
      verifyOTPDto.type,
    );
  }

  // ==================== EMAIL VERIFICATION ENDPOINTS ====================

  @Post('resend-verification')
  @UseGuards(RateLimitGuard)
  @RateLimit({ windowMs: 60 * 60 * 1000, maxRequests: 5 }) // 5 resend per hour
  async resendVerificationEmail(
    @Body() requestEmailVerificationDto: RequestEmailVerificationDto,
  ): Promise<EmailVerificationResponseDto> {
    this.logger.log(
      `[API] POST /auth/resend-verification - ${requestEmailVerificationDto.email}`,
      'AuthController',
    );
    return this.emailVerificationService.resendVerificationEmail(
      requestEmailVerificationDto.email,
    );
  }

  @Get('verify-email')
  async verifyEmail(@Query('token') token: string): Promise<EmailVerificationResponseDto> {
    this.logger.log(`[API] GET /auth/verify-email`, 'AuthController');
    const result = await this.emailVerificationService.verifyEmailToken(token);
    return {
      success: result.success,
      message: 'Email verified successfully! You can now use all features.',
      email: result.email,
    };
  }

  @Get('verification-status')
  @UseGuards(JwtAuthGuard)
  async getVerificationStatus(@Req() req: any): Promise<{ email: string; verified: boolean; verifiedAt?: Date }> {
    this.logger.log(
      `[API] GET /auth/verification-status - ${req.user.email}`,
      'AuthController',
    );
    return this.emailVerificationService.getVerificationStatus(req.user.email);
  }

  // ==================== PASSWORD RESET ENDPOINTS ====================

  @Post('forgot-password')
  @UseGuards(RateLimitGuard)
  @RateLimit({ windowMs: 60 * 60 * 1000, maxRequests: 3 }) // 3 password reset requests per hour
  async forgotPassword(
    @Body() forgotPasswordDto: ForgotPasswordDto,
  ): Promise<PasswordResetResponseDto> {
    this.logger.log(
      `[API] POST /auth/forgot-password - ${forgotPasswordDto.email}`,
      'AuthController',
    );
    return this.passwordResetService.generateAndSendResetEmail(forgotPasswordDto.email);
  }

  @Post('reset-password')
  @UseGuards(RateLimitGuard)
  @RateLimit({ windowMs: 15 * 60 * 1000, maxRequests: 5 }) // 5 reset attempts per 15 minutes
  async resetPassword(
    @Body() resetPasswordDto: ResetPasswordDto,
  ): Promise<PasswordResetResponseDto> {
    this.logger.log(`[API] POST /auth/reset-password`, 'AuthController');
    return this.passwordResetService.resetPassword(
      resetPasswordDto.token,
      resetPasswordDto.newPassword,
    );
  }

  @Get('validate-reset-token')
  async validateResetToken(@Query('token') token: string): Promise<{ valid: boolean; email?: string }> {
    this.logger.log(`[API] GET /auth/validate-reset-token`, 'AuthController');
    return this.passwordResetService.isResetTokenValid(token);
  }

  // ==================== DEVICE MANAGEMENT ENDPOINTS ====================

  @Get('devices')
  @UseGuards(JwtAuthGuard)
  async getActiveDevices(@Req() req: any): Promise<ActiveDevicesResponseDto> {
    this.logger.log(
      `[API] GET /auth/devices - ${req.user.userId}`,
      'AuthController',
    );
    const devices = await this.deviceService.getActiveDevices(req.user.userId);
    return {
      success: true,
      devices,
      totalDevices: devices.length,
    };
  }

  @Post('logout-device/:deviceId')
  @UseGuards(JwtAuthGuard)
  async logoutFromDevice(
    @Param('deviceId') deviceId: string,
    @Req() req: any,
  ): Promise<LogoutDeviceResponseDto> {
    this.logger.log(
      `[API] POST /auth/logout-device/${deviceId} - ${req.user.userId}`,
      'AuthController',
    );
    const result = await this.deviceService.logoutFromDevice(req.user.userId, deviceId);
    return {
      success: true,
      message: result.message,
    };
  }

  @Post('logout-all-devices')
  @UseGuards(JwtAuthGuard)
  async logoutFromAllDevices(@Req() req: any): Promise<LogoutDeviceResponseDto> {
    this.logger.log(
      `[API] POST /auth/logout-all-devices - ${req.user.userId}`,
      'AuthController',
    );
    const result = await this.deviceService.logoutFromAllDevices(req.user.userId);
    return {
      success: true,
      message: result.message,
      devicesLoggedOut: result.devicesLoggedOut,
    };
  }
}

