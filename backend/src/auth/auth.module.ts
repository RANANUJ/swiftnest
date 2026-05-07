import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { OTPService } from './services/otp.service';
import { EmailService } from './services/email.service';
import { EmailVerificationService } from './services/email-verification.service';
import { PasswordResetService } from './services/password-reset.service';
import { DeviceService } from './services/device.service';
import { RateLimitService } from './services/rate-limit.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { User, UserSchema } from './schemas/user.schema';
import { OTP, OTPSchema } from './schemas/otp.schema';
import { EmailVerification, EmailVerificationSchema } from './schemas/email-verification.schema';
import { PasswordReset, PasswordResetSchema } from './schemas/password-reset.schema';
import { Device, DeviceSchema } from './schemas/device.schema';
import { RateLimit, RateLimitSchema } from './schemas/rate-limit.schema';
import { LoggerServiceImpl } from '../common/logger/logger.service';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<number>('JWT_EXPIRATION') || 1800,
        },
      }),
    }),
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: OTP.name, schema: OTPSchema },
      { name: EmailVerification.name, schema: EmailVerificationSchema },
      { name: PasswordReset.name, schema: PasswordResetSchema },
      { name: Device.name, schema: DeviceSchema },
      { name: RateLimit.name, schema: RateLimitSchema },
    ]),
  ],
  controllers: [AuthController],
  providers: [AuthService, OTPService, EmailService, EmailVerificationService, PasswordResetService, DeviceService, RateLimitService, JwtStrategy, LoggerServiceImpl],
  exports: [AuthService, OTPService, EmailService, EmailVerificationService, PasswordResetService, DeviceService, RateLimitService, JwtModule, PassportModule],
})
export class AuthModule {}
