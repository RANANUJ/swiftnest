export const jwtConfig = () => ({
  secret: process.env.JWT_SECRET || 'your-secret-key',
  expiresIn: parseInt(process.env.JWT_EXPIRATION || '1800'), // 30 minutes
  refreshSecret: process.env.JWT_REFRESH_SECRET || 'your-refresh-secret',
  refreshExpiresIn: parseInt(process.env.JWT_REFRESH_EXPIRATION || '2592000'), // 30 days
});

export interface JwtPayload {
  userId: string;
  email: string;
  deviceId?: string;
  iat?: number;
  exp?: number;
}

export interface RefreshTokenPayload extends JwtPayload {
  tokenVersion: number;
}
