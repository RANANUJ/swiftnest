import { IsEmail, IsString } from 'class-validator';

// Request Email Verification
export class RequestEmailVerificationDto {
  @IsEmail()
  email: string;
}

// Verify Email Token Request
export class VerifyEmailTokenDto {
  @IsString()
  token: string;
}

// Email Verification Response
export class EmailVerificationResponseDto {
  success: boolean;
  message: string;
  email?: string;
}
