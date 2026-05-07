import { IsString, IsOptional } from 'class-validator';

export class RegisterDeviceDto {
  @IsString()
  name: string; // e.g., "Chrome on Windows"

  @IsOptional()
  @IsString()
  ipAddress?: string;

  @IsOptional()
  @IsString()
  userAgent?: string;

  @IsOptional()
  @IsString()
  deviceId?: string; // Unique device identifier from client

  @IsString()
  osType: string; // 'Android', 'iOS', 'Windows', 'Mac', 'Linux'

  @IsOptional()
  @IsString()
  osVersion?: string;
}

export class LogoutDeviceDto {
  @IsString()
  deviceId: string;
}

export class DeviceResponseDto {
  id: string;
  name: string;
  osType: string;
  osVersion?: string;
  ipAddress?: string;
  isCurrent: boolean;
  lastSeenAt: Date;
  createdAt: Date;
}

export class ActiveDevicesResponseDto {
  success: boolean;
  devices: DeviceResponseDto[];
  totalDevices: number;
}

export class LogoutDeviceResponseDto {
  success: boolean;
  message: string;
  devicesLoggedOut?: number;
}
