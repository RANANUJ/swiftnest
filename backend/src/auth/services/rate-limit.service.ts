import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { RateLimit } from '../schemas/rate-limit.schema';
import { LoggerServiceImpl } from '../../common/logger/logger.service';

export interface RateLimitConfig {
  windowMs: number; // Time window in milliseconds
  maxRequests: number; // Max requests per window
  keyPrefix?: string;
}

@Injectable()
export class RateLimitService {
  private readonly defaultConfig: RateLimitConfig = {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 100,
    keyPrefix: 'rl',
  };

  constructor(
    @InjectModel(RateLimit.name) private rateLimitModel: Model<RateLimit>,
    private logger: LoggerServiceImpl,
  ) {}

  /**
   * Check if request should be rate limited
   */
  async isLimited(
    key: string,
    config: Partial<RateLimitConfig> = {},
  ): Promise<{ allowed: boolean; remaining: number; resetTime: Date }> {
    const finalConfig = { ...this.defaultConfig, ...config };
    const now = new Date();
    const windowStart = new Date(now.getTime() - finalConfig.windowMs);

    try {
      // Try to find existing record
      let record = await this.rateLimitModel.findOne({
        key,
      });

      if (!record) {
        // Create new record
        record = await this.rateLimitModel.create({
          key,
          requests: 1,
          windowStart: now,
          resetAt: new Date(now.getTime() + finalConfig.windowMs),
        });

        return {
          allowed: true,
          remaining: finalConfig.maxRequests - 1,
          resetTime: record.resetAt,
        };
      }

      // Check if window has expired
      if (record.windowStart < windowStart) {
        // Reset window
        record.requests = 1;
        record.windowStart = now;
        record.resetAt = new Date(now.getTime() + finalConfig.windowMs);
        await record.save();

        return {
          allowed: true,
          remaining: finalConfig.maxRequests - 1,
          resetTime: record.resetAt,
        };
      }

      // Increment request count
      record.requests += 1;

      if (record.requests > finalConfig.maxRequests) {
        await record.save();
        return {
          allowed: false,
          remaining: 0,
          resetTime: record.resetAt,
        };
      }

      await record.save();
      return {
        allowed: true,
        remaining: finalConfig.maxRequests - record.requests,
        resetTime: record.resetAt,
      };
    } catch (error) {
      this.logger.error(
        `[RateLimitService] Error checking rate limit for key ${key}: ${error.message}`,
        'isLimited',
      );
      // In case of error, allow request (fail open)
      return {
        allowed: true,
        remaining: this.defaultConfig.maxRequests,
        resetTime: new Date(Date.now() + this.defaultConfig.windowMs),
      };
    }
  }

  /**
   * Get rate limit status for a key
   */
  async getStatus(key: string): Promise<{ requests: number; windowStart: Date; resetAt: Date } | null> {
    try {
      const record = await this.rateLimitModel.findOne({ key });
      if (!record) return null;

      return {
        requests: record.requests,
        windowStart: record.windowStart,
        resetAt: record.resetAt,
      };
    } catch (error) {
      this.logger.debug(`[RateLimitService] Error getting status for key ${key}: ${error.message}`, 'getStatus');
      return null;
    }
  }

  /**
   * Reset limit for a key
   */
  async reset(key: string): Promise<void> {
    try {
      await this.rateLimitModel.deleteOne({ key });
    } catch (error) {
      this.logger.debug(`[RateLimitService] Error resetting key ${key}: ${error.message}`, 'reset');
    }
  }

  /**
   * Cleanup expired rate limit records
   */
  async cleanup(): Promise<{ deleted: number }> {
    try {
      const result = await this.rateLimitModel.deleteMany({
        resetAt: { $lt: new Date() },
      });

      return { deleted: result.deletedCount };
    } catch (error) {
      this.logger.error(
        `[RateLimitService] Error cleaning up rate limits: ${error.message}`,
        'cleanup',
      );
      return { deleted: 0 };
    }
  }
}
