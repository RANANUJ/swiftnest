import { IsEmail, IsString, Length, IsEnum } from 'class-validator';

// Send OTP Request
export class SendOTPDto {
  @IsEmail()
  email: string;

  @IsEnum(['signup', 'login', 'password-reset'])
  type: 'signup' | 'login' | 'password-reset';
}

// Verify OTP Request
export class VerifyOTPDto {
  @IsEmail()
  email: string;

  @IsString()
  @Length(6, 6)
  code: string;

  @IsEnum(['signup', 'login', 'password-reset'])
  type: 'signup' | 'login' | 'password-reset';
}

// OTP Response
export class OTPResponseDto {
  success: boolean;
  message: string;
  expiresIn: number;
}

// Verify OTP Response
export class VerifyOTPResponseDto {
  verified: boolean;
  userId?: string;
  message: string;
}
