export const appConfig = () => ({
  app: {
    name: process.env.APP_NAME || 'SwiftNest',
    env: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '3000'),
    url: process.env.APP_URL || 'http://localhost:3000',
  },
  database: {
    mongoUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/swiftnest',
    mongoHost: process.env.MONGODB_HOST || 'localhost',
    mongoPort: parseInt(process.env.MONGODB_PORT || '27017'),
    mongoName: process.env.MONGODB_NAME || 'swiftnest',
  },
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    password: process.env.REDIS_PASSWORD,
    db: parseInt(process.env.REDIS_DB || '0'),
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',
    expiresIn: parseInt(process.env.JWT_EXPIRATION || '1800'),
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'your-refresh-secret',
    refreshExpiresIn: parseInt(process.env.JWT_REFRESH_EXPIRATION || '2592000'),
  },
  security: {
    bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS || '12'),
    otpExpiration: parseInt(process.env.OTP_EXPIRATION || '300'),
    rateLimitWindow: parseInt(process.env.RATE_LIMIT_WINDOW || '60000'),
    rateLimitMaxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  },
  logging: {
    level: process.env.LOG_LEVEL || 'debug',
    file: process.env.LOG_FILE || 'logs/app.log',
    maxSize: process.env.LOG_MAX_SIZE || '10m',
    maxFiles: parseInt(process.env.LOG_MAX_FILES || '14'),
  },
  cors: {
    origin: (process.env.CORS_ORIGIN || 'http://localhost:8081').split(','),
    credentials: true,
  },
});
