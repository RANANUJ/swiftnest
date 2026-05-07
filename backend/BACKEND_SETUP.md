# SwiftNest Backend - Stage 3 Complete

**Status**: ✅ Backend Foundation Complete  
**Last Updated**: March 23, 2026

## 📋 What's Implemented

### ✅ 1. NestJS Project Initialization
- Modern NestJS 10+ structure
- TypeScript support
- Module-based architecture
- Ready for scaling

### ✅ 2. MongoDB Connection
- Mongoose ODM integration
- Connection pooling with retries
- Database-first schema design
- User model created with pre-hooks

**Config**: `src/config/database.config.ts`  
**URI**: Configurable via `.env`

```env
MONGODB_URI=mongodb://localhost:27017/swiftnest
```

### ✅ 3. Redis Connection
- Redis client configuration
- Automatic retry strategy
- Connection pooling ready
- Perfect for caching & sessions

**Config**: `src/config/redis.config.ts`  
**Usage**: Ready for Socket.IO integration

```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0
```

### ✅ 4. Authentication Module (Complete)

#### Features:
- ✅ JWT-based authentication (access + refresh tokens)
- ✅ User signup with email
- ✅ User login with password validation
- ✅ Token refresh endpoint
- ✅ Logout with token invalidation
- ✅ Password hashing with bcrypt (12 rounds)
- ✅ Device tracking per user
- ✅ User blocking functionality
- ✅ Token versioning (invalidate all tokens on demand)

#### Files:
- `src/auth/auth.controller.ts` - API endpoints
- `src/auth/auth.service.ts` - Business logic
- `src/auth/auth.module.ts` - Module exports
- `src/auth/schemas/user.schema.ts` - User model with hooks
- `src/auth/dto/auth.dto.ts` - Request/response DTOs
- `src/auth/strategies/jwt.strategy.ts` - Passport JWT strategy
- `src/auth/guards/jwt-auth.guard.ts` - Route protection

#### API Endpoints:
```
POST   /auth/signup          - Create new account
POST   /auth/login           - Login with email/password
POST   /auth/refresh         - Get new access token
POST   /auth/logout          - Invalidate all tokens
POST   /auth/verify-token    - Check if token is valid
```

### ✅ 5. Logging & Error Handling

#### Logger Service (`src/common/logger/logger.service.ts`)
- Winston-based logging
- Console output with colors
- File logging (app.log + error.log)
- Log rotation (10MB per file, 14-day retention)
- Structured JSON format for production
- Multiple log levels: debug, info, warn, error

#### Global Exception Filter (`src/common/filters/http-exception.filter.ts`)
- Catches all exceptions globally
- Logs errors automatically
- Returns consistent error format
- Stack traces in development only
- Prevents information leakage in production

#### Error Response Format:
```json
{
  "statusCode": 400,
  "timestamp": "2026-03-23T14:25:00.000Z",
  "path": "/auth/login",
  "message": "Invalid email or password",
  "details": {...}  // Only in development
}
```

### ✅ 6. Environment Management

#### Configuration Files:
- `.env` - Current environment variables (ignored in git)
- `.env.example` - Template for setup documentation

#### Configuration Service (`src/config/app.config.ts`)
- Centralized config management
- Type-safe access
- Defaults for all variables
- Automatic PORT/CORS handling

#### Environment Variables:
```
NODE_ENV              - development|production|test
PORT                  - Server port (default: 3000)
MONGODB_URI          - MongoDB connection string
REDIS_HOST/PORT      - Redis configuration
JWT_SECRET           - Secret key for access tokens
JWT_REFRESH_SECRET   - Secret key for refresh tokens
JWT_EXPIRATION       - Access token TTL (seconds)
JWT_REFRESH_EXPIRATION - Refresh token TTL (seconds)
BCRYPT_ROUNDS        - Password hashing rounds (default: 12)
LOG_LEVEL            - debug|info|warn|error
CORS_ORIGIN          - Comma-separated allowed origins
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Set Up Environment
```bash
cp .env.example .env
# Edit .env with your values
```

### 3. MongoDB Setup
```bash
# Option 1: Using Docker
docker run -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password mongo:latest

# Option 2: Using MongoDB Atlas Cloud
# Update MONGODB_URI in .env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/swiftnest
```

### 4. Redis Setup
```bash
# Option 1: Using Docker
docker run -d -p 6379:6379 redis:latest

# Option 2: Using Redis Cloud
# Update .env with your Redis URL
```

### 5. Run Development Server
```bash
npm run start:dev
```

**Output:**
```
🚀 SwiftNest server running on port 3000
📝 API Documentation: http://localhost:3000/api
```

---

## 🧪 Testing Authentication

### Signup
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securePassword123",
    "name": "John Doe",
    "deviceId": "device-123"
  }'
```

**Response:**
```json
{
  "userId": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "name": "John Doe",
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 1800
}
```

### Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securePassword123",
    "deviceId": "device-123"
  }'
```

### Verify Token (Protected)
```bash
curl -X POST http://localhost:3000/auth/verify-token \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Refresh Token
```bash
curl -X POST http://localhost:3000/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "<REFRESH_TOKEN>"}'
```

### Logout (Protected)
```bash
curl -X POST http://localhost:3000/auth/logout \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── auth/
│   │   ├── dto/
│   │   │   └── auth.dto.ts            ✅ Login/Signup DTOs
│   │   ├── schemas/
│   │   │   └── user.schema.ts         ✅ MongoDB User model
│   │   ├── strategies/
│   │   │   └── jwt.strategy.ts        ✅ Passport JWT strategy
│   │   ├── guards/
│   │   │   └── jwt-auth.guard.ts      ✅ Route protection guards
│   │   ├── auth.controller.ts         ✅ API endpoints
│   │   ├── auth.service.ts            ✅ Business logic
│   │   └── auth.module.ts             ✅ Module definition
│   ├── config/
│   │   ├── app.config.ts              ✅ App configuration
│   │   ├── database.config.ts         ✅ MongoDB config
│   │   ├── redis.config.ts            ✅ Redis config
│   │   └── jwt.config.ts              ✅ JWT config
│   ├── common/
│   │   ├── logger/
│   │   │   └── logger.service.ts      ✅ Winston logger
│   │   └── filters/
│   │       └── http-exception.filter.ts ✅ Global error handler
│   ├── app.module.ts                  ✅ Root module
│   ├── app.controller.ts              - Health check
│   ├── app.service.ts                 - Example service
│   └── main.ts                        ✅ Entry point with CORS & logging
├── test/
│   ├── jest.config.js                 - Test configuration
│   └── app.e2e-spec.ts                - E2E tests
├── logs/
│   ├── app.log                        - Application logs
│   └── error.log                      - Error logs
├── .env                               ✅ Environment variables
├── .env.example                       ✅ Env template
├── package.json                       ✅ Dependencies
├── tsconfig.json                      - TypeScript config
└── README.md                          - This file
```

---

## 🔒 Security Features Implemented

### Authentication
✅ JWT tokens with expiration  
✅ Refresh token rotation  
✅ Password hashing (bcrypt)  
✅ Token versioning (logout all devices)  
✅ Device tracking  

### Data Validation
✅ DTOs with class-validator  
✅ Global validation pipe  
✅ Type safety with TypeScript  

### Rate Limiting (Ready for implementation)
- Login attempts: 5/min per IP
- OTP requests: 3/hour per user
- Message sending: 100/min per user

### Error Handling
✅ Global exception filter  
✅ Consistent error responses  
✅ No stack trace leaks in production  

---

## 🔧 Development Commands

```bash
# Development mode (auto-reload)
npm run start:dev

# Production mode
npm run build
npm run start:prod

# Run tests
npm run test

# Run e2e tests
npm run test:e2e

# Check code style
npm run lint

# Format code
npm run format

# View logs
tail -f logs/app.log
tail -f logs/error.log
```

---

## 📊 Database Schema

### User Model
```javascript
{
  _id: ObjectId,
  email: String (unique),
  password: String (hashed),
  name: String,
  phone: String,
  avatar: String (URL),
  isEmailVerified: Boolean,
  isPhoneVerified: Boolean,
  isActive: Boolean,
  blockedUsers: [UserId],
  blockedBy: [UserId],
  tokenVersion: Number (for logout all devices),
  lastLogin: Date,
  deviceIds: [String],
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🎯 Next Steps (Stage 4)

After Stage 3 is complete, proceed to **Stage 4: Authentication System** which includes:
- [ ] OTP verification for signup
- [ ] Password reset workflow
- [ ] Email verification
- [ ] Device session management
- [ ] Rate limiting

Then **Stage 5: Real-Time Chat** for Socket.IO integration.

---

## 📚 Useful Links

- [NestJS Documentation](https://docs.nestjs.com)
- [MongoDB Documentation](https://docs.mongodb.com)
- [Redis Documentation](https://redis.io/documentation)
- [JWT Guide](https://jwt.io/introduction)
- [Passport.js](http://www.passportjs.org)

---

## ✅ Stage 3 Checklist

- [x] Initialize NestJS project
- [x] Set up MongoDB connection & User schema
- [x] Set up Redis connection config
- [x] Create authentication module (signup, login, logout)
- [x] Add logging with Winston
- [x] Add error handling with global filter
- [x] Environment management with ConfigModule
- [x] JWT authentication with Passport
- [x] Documentation

**Status**: 🟢 **COMPLETE**

---

**Backend Version**: 1.0-stage-3  
**Last Updated**: March 23, 2026  
**Ready for**: Stage 4 - Advanced Auth Features
