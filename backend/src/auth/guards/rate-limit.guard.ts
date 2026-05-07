import { Injectable, CanActivate, ExecutionContext, HttpException, HttpStatus } from '@nestjs/common';
import { RateLimitService } from '../services/rate-limit.service';
import { LoggerServiceImpl } from '../../common/logger/logger.service';

export interface RateLimitOptions {
  windowMs?: number; // Time window in milliseconds
  maxRequests?: number; // Max requests per window
  keyGenerator?: (context: ExecutionContext) => string;
}

@Injectable()
export class RateLimitGuard implements CanActivate {
  private readonly defaultOptions: RateLimitOptions = {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 100,
  };

  constructor(
    private rateLimitService: RateLimitService,
    private logger: LoggerServiceImpl,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const response = context.switchToHttp().getResponse();
    const options = this.getRouteOptions(context);

    // Generate rate limit key
    const key = options.keyGenerator
      ? options.keyGenerator(context)
      : this.getDefaultKey(request);

    // Check rate limit
    const result = await this.rateLimitService.isLimited(key, {
      windowMs: options.windowMs,
      maxRequests: options.maxRequests,
    });

    // Set rate limit headers
    response.set('X-RateLimit-Limit', String(options.maxRequests));
    response.set('X-RateLimit-Remaining', String(result.remaining));
    response.set('X-RateLimit-Reset', String(Math.floor(result.resetTime.getTime() / 1000)));

    if (!result.allowed) {
      this.logger.warn(
        `[RateLimitGuard] Rate limit exceeded for key ${key}. Reset at ${result.resetTime}`,
        'canActivate',
      );
      throw new HttpException(
        `Too many requests. Try again after ${Math.ceil((result.resetTime.getTime() - Date.now()) / 1000)} seconds.`,
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    return true;
  }

  private getDefaultKey(request: any): string {
    // Use user ID if authenticated, otherwise use IP address
    if (request.user?.userId) {
      return `user-${request.user.userId}`;
    }
    return `ip-${this.getClientIp(request)}`;
  }

  private getClientIp(request: any): string {
    return (
      request.headers['x-forwarded-for']?.split(',')[0] ||
      request.headers['x-real-ip'] ||
      request.connection.remoteAddress ||
      'unknown'
    );
  }

  private getRouteOptions(context: ExecutionContext): RateLimitOptions {
    const handler = context.getHandler();
    const options = Reflect.getMetadata('rate-limit', handler);
    return { ...this.defaultOptions, ...options };
  }
}

/**
 * Decorator to set rate limit options on a route
 */
export function RateLimit(options: RateLimitOptions = {}) {
  return Reflect.metadata('rate-limit', options);
}
