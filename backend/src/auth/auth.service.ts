import { Injectable, BadRequestException, UnauthorizedException, ConflictException, Inject } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ConfigService } from '@nestjs/config';
import { User } from './schemas';
import { SignupDto, LoginDto, AuthResponseDto } from './dto';
import { OTPService } from './services/otp.service';
import { LoggerServiceImpl } from '../common/logger/logger.service';

@Injectable()
export class AuthService {
  constructor(
    @InjectModel(User.name) private userModel: Model<User>,
    private jwtService: JwtService,
    private configService: ConfigService,
    private otpService: OTPService,
    @Inject(LoggerServiceImpl) private logger: LoggerServiceImpl,
  ) {}

  async signup(signupDto: SignupDto): Promise<AuthResponseDto> {
    this.logger.log(`[Auth] Signup attempt for ${signupDto.email}`, 'AuthService');

    // Check if user already exists
    const existingUser = await this.userModel.findOne({ email: signupDto.email });
    if (existingUser) {
      this.logger.warn(`[Auth] User already exists: ${signupDto.email}`, 'AuthService');
      throw new ConflictException('User with this email already exists');
    }

    // Create new user
    const user = new this.userModel({
      email: signupDto.email,
      password: signupDto.password,
      name: signupDto.name,
      phone: signupDto.phone,
      deviceIds: signupDto.deviceId ? [signupDto.deviceId] : [],
      isEmailVerified: false,
    });

    await user.save();
    this.logger.log(`[Auth] User created: ${user._id}`, 'AuthService');

    // ⚠️ DO NOT GENERATE TOKENS HERE!
    // User must verify OTP first before receiving tokens
    // Tokens will be returned only after OTP verification in verifyOTP()
    
    this.logger.log(`[Auth] Signup complete. User must verify OTP before tokens are issued.`, 'AuthService');

    // Return user info WITHOUT tokens
    return {
      userId: user._id.toString(),
      email: user.email,
      name: user.name,
      avatar: user.avatar,
      accessToken: '', // Empty - tokens only after OTP verification
      refreshToken: '', // Empty - tokens only after OTP verification
      expiresIn: 0,
    };
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    this.logger.log(`[Auth] Login attempt for ${loginDto.email}`, 'AuthService');

    // Find user by email
    const user = await this.userModel.findOne({ email: loginDto.email });
    if (!user) {
      this.logger.warn(`[Auth] User not found: ${loginDto.email}`, 'AuthService');
      throw new UnauthorizedException('Invalid email or password');
    }

    // Check password
    const isPasswordValid = await (user as any).matchPassword(loginDto.password);
    if (!isPasswordValid) {
      this.logger.warn(`[Auth] Invalid password for user: ${loginDto.email}`, 'AuthService');
      throw new UnauthorizedException('Invalid email or password');
    }

    // Check if user is active
    if (!user.isActive) {
      this.logger.warn(`[Auth] Inactive user trying to login: ${loginDto.email}`, 'AuthService');
      throw new UnauthorizedException('User account is inactive');
    }

    // Add device ID if provided
    if (loginDto.deviceId && !user.deviceIds.includes(loginDto.deviceId)) {
      user.deviceIds.push(loginDto.deviceId);
    }

    user.lastLogin = new Date();
    await user.save();

    this.logger.log(`[Auth] User logged in: ${user._id}`, 'AuthService');

    // Generate tokens
    const tokens = this.generateTokens(user);

    return {
      userId: user._id.toString(),
      email: user.email,
      name: user.name,
      avatar: user.avatar,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: parseInt(this.configService.get<string>('JWT_EXPIRATION') || '1800'),
    };
  }

  async refreshToken(refreshToken: string) {
    this.logger.log(`[Auth] Refresh token attempt`, 'AuthService');

    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
      });

      const user = await this.userModel.findById(payload.userId);
      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      if (!user.isActive) {
        throw new UnauthorizedException('User is inactive');
      }

      const tokens = this.generateTokens(user);

      return {
        userId: user._id.toString(),
        email: user.email,
        name: user.name,
        avatar: user.avatar,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: this.configService.get('JWT_EXPIRATION'),
      };
    } catch (error) {
      this.logger.error(`[Auth] Refresh token failed: ${error.message}`, 'AuthService');
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async logout(userId: string) {
    this.logger.log(`[Auth] Logout for user: ${userId}`, 'AuthService');

    const user = await this.userModel.findById(userId);
    if (user) {
      // Increment token version to invalidate all tokens
      await (user as any).incrementTokenVersion();
      this.logger.log(`[Auth] User logged out: ${userId}`, 'AuthService');
    }
  }

  /**
   * Verify OTP and generate tokens for authenticated user
   * Called after user completes signup and verifies their email/phone via OTP
   */
  async verifyOTPAndGenerateTokens(
    email: string,
    code: string,
    type: 'signup' | 'login' | 'password-reset',
  ): Promise<AuthResponseDto> {
    this.logger.log(`[Auth] Verifying OTP and generating tokens for ${email}`, 'AuthService');

    // Verify OTP code first
    const otpResult = await this.otpService.verifyOTP(email, code, type);
    
    if (!otpResult.verified) {
      throw new BadRequestException('OTP verification failed');
    }

    // Find user by email
    const user = await this.userModel.findOne({ email });
    if (!user) {
      this.logger.warn(`[Auth] User not found after OTP verification: ${email}`, 'AuthService');
      throw new UnauthorizedException('User not found');
    }

    // Mark email as verified
    user.isEmailVerified = true;
    user.emailVerifiedAt = new Date();
    
    // For signup flow, mark as active
    if (type === 'signup') {
      user.isActive = true;
    }

    await user.save();
    this.logger.log(`[Auth] User email verified and activated: ${user._id}`, 'AuthService');

    // Generate tokens for authenticated user
    const tokens = this.generateTokens(user);

    return {
      userId: user._id.toString(),
      email: user.email,
      name: user.name,
      avatar: user.avatar,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: parseInt(this.configService.get<string>('JWT_EXPIRATION') || '1800'),
    };
  }

  private generateTokens(user: User) {
    const payload = {
      userId: user._id,
      email: user.email,
      tokenVersion: user.tokenVersion,
    };

    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_SECRET'),
      expiresIn: this.configService.get('JWT_EXPIRATION'),
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_REFRESH_SECRET'),
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRATION'),
    });

    return { accessToken, refreshToken };
  }

  async validateUser(email: string): Promise<User | null> {
    return await this.userModel.findOne({ email });
  }
}
