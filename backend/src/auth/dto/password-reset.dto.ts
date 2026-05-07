import { IsEmail, IsString, MinLength, Matches } from 'class-validator';

export class ForgotPasswordDto {
  @IsEmail()
  email: string;
}

export class ResetPasswordDto {
  @IsString()
  token: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  @Matches(/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])/, {
    message: 'Password must contain uppercase, lowercase, number, and special character',
  })
  newPassword: string;
}

export class PasswordResetResponseDto {
  success: boolean;
  message: string;
  email?: string;
}

export class ValidateResetTokenDto {
  @IsString()
  token: string;
}
