import { RedisClientOptions } from 'redis';

export const redisConfig = (): RedisClientOptions => {
  const host = process.env.REDIS_HOST || 'localhost';
  const port = parseInt(process.env.REDIS_PORT || '6379');
  const password = process.env.REDIS_PASSWORD;

  return {
    socket: {
      host,
      port,
    },
    password: password || undefined,
    db: parseInt(process.env.REDIS_DB || '0'),
  } as RedisClientOptions;
};
