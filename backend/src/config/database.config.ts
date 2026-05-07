import { MongooseModuleOptions } from '@nestjs/mongoose';

export const mongooseConfig = (): MongooseModuleOptions => {
  const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/swiftnest';

  return {
    uri: mongoUri,
    retryAttempts: 5,
    retryDelay: 3000,
  };
};
