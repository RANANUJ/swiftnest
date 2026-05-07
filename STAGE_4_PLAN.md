# 🔐 Stage 4: Enhanced Authentication System

**Status**: Starting  
**Estimated Time**: 3-4 days  
**Deliverables**: Complete auth flow with OTP, email verification, password reset, device sessions, and rate limiting

---

## 📋 Stage 4 Tasks

### Phase 1: OTP System (1 day)
- [ ] OTP Service (generate, send via email, verify)
- [ ] OTP Model in MongoDB
- [ ] OTP validation endpoints
- [ ] Email service integration (Nodemailer)
- [ ] OTP logging and tracking

### Phase 2: Email Verification (1 day)
- [ ] Email verification flow
- [ ] Verification email templates
- [ ] Resend verification email endpoint
- [ ] Mark email as verified on signup
- [ ] Dashboard view for verification status

### Phase 3: Password Reset (1 day)
- [ ] Forgot password endpoint
- [ ] Reset token generation (time-limited)
- [ ] Reset password endpoint
- [ ] Email with reset link
- [ ] Token expiration handling

### Phase 4: Device Session Management (1 day)
- [ ] Device model in MongoDB
- [ ] Device registration on login
- [ ] Active sessions endpoint
- [ ] Logout from specific device
- [ ] Logout from all devices
- [ ] Device tracking (IP, User-Agent)

### Phase 5: Rate Limiting & Security (1 day)
- [ ] Rate limiting for login attempts (5/min)
- [ ] Rate limiting for OTP requests (3/hour)
- [ ] Rate limiting for password reset (3/day)
- [ ] Brute force protection
- [ ] Account lockout after failed attempts
- [ ] IP-based blocking

---

## 🏗️ Backend Architecture

### New Files to Create

```
src/
├── auth/
│   ├── controllers/
│   │   ├── auth.controller.ts (existing - will expand)
│   │   └── otp.controller.ts (NEW)
│   ├── services/
│   │   ├── auth.service.ts (existing - will expand)
│   │   ├── otp.service.ts (NEW)
│   │   ├── email.service.ts (NEW)
│   │   └── device.service.ts (NEW)
│   ├── schemas/
│   │   ├── user.schema.ts (existing - will update)
│   │   ├── otp.schema.ts (NEW)
│   │   ├── device.schema.ts (NEW)
│   │   └── password-reset.schema.ts (NEW)
│   └── dto/
│       ├── auth.dto.ts (existing - will expand)
│       ├── otp.dto.ts (NEW)
│       ├── password-reset.dto.ts (NEW)
│       └── device.dto.ts (NEW)
├── email/
│   ├── email.service.ts (NEW)
│   ├── templates/
│   │   ├── otp.template.ts (NEW)
│   │   ├── verification.template.ts (NEW)
│   │   └── password-reset.template.ts (NEW)
│   └── email.module.ts (NEW)
├── common/
│   ├── guards/
│   │   ├── jwt-auth.guard.ts (existing)
│   │   └── rate-limit.guard.ts (NEW)
│   ├── decorators/
│   │   ├── rate-limit.decorator.ts (NEW)
│   │   └── device-id.decorator.ts (NEW)
│   └── interceptors/
│       └── rate-limit.interceptor.ts (NEW)
└── config/
    └── rate-limit.config.ts (NEW)
```

---

## 📡 New API Endpoints

### OTP Endpoints
```
POST /auth/send-otp
  Body: { email, type: 'signup|login|password-reset' }
  Response: { message, expiresIn }

POST /auth/verify-otp
  Body: { email, otp, type }
  Response: { verified: true, userId? }
```

### Email Verification
```
POST /auth/resend-verification
  Body: { email }
  Response: { message, expiresIn }

GET /auth/verify-email?token=xxx
  Response: { success: true, email }
```

### Password Reset
```
POST /auth/forgot-password
  Body: { email }
  Response: { message, resetTokenSent }

POST /auth/reset-password
  Body: { token, newPassword }
  Response: { success: true, message }
```

### Device Sessions
```
GET /auth/devices
  Headers: Authorization
  Response: [{ deviceId, name, lastSeen, ip, userAgent }]

POST /auth/logout-device
  Body: { deviceId }
  Response: { success: true }

POST /auth/logout-all-devices
  Response: { success: true, message }

POST /auth/rename-device
  Body: { deviceId, name }
  Response: { device: { id, name } }
```

---

## 💾 MongoDB Schema Updates

### OTP Schema
```typescript
{
  email: string (indexed)
  code: string (hashed)
  type: 'signup' | 'login' | 'password-reset'
  userId?: ObjectId (optional, for existing users)
  attempts: number
  maxAttempts: 5
  expiresAt: Date
  createdAt: Date
}
```

### Device Schema
```typescript
{
  userId: ObjectId
  name: string (auto or user-set)
  deviceToken: string (for push notifications)
  ip: string
  userAgent: string
  lastSeen: Date
  isActive: boolean
  createdAt: Date
}
```

### User Schema Updates
```typescript
{
  // Existing fields...
  isEmailVerified: boolean (default: false)
  emailVerifiedAt?: Date
  passwordResetToken?: string
  passwordResetTokenExpires?: Date
  failedLoginAttempts: number (default: 0)
  lockUntil?: Date (account lockout time)
  loginHistory: [{timestamp, ip, success}]
  lastPasswordChange?: Date
}
```

### Password Reset Schema
```typescript
{
  email: string (indexed)
  resetToken: string (hashed)
  expiresAt: Date
  used: boolean
  usedAt?: Date
  createdAt: Date
}
```

---

## 🔐 Security Considerations

1. **OTP**: 6-digit codes, 10-minute expiry, 5 attempts max
2. **Password Reset**: Token with 1-hour expiry, single-use
3. **Device Tracking**: Store IP, User-Agent, timestamp
4. **Rate Limiting**: Redis for tracking request counts
5. **Account Lockout**: After 5 failed logins, lock for 15 minutes
6. **Email Verification**: Required before full account access
7. **Password Hashing**: Bcrypt 12 rounds (existing)

---

## 📊 Implementation Order

1. **Start with OTP Service** - Foundation for other features
2. **Add Email Service** - Required for OTP, verification, password reset
3. **Implement Device Management** - Track active sessions
4. **Add Rate Limiting** - Protect endpoints
5. **Password Reset Flow** - Final authentication feature
6. **Frontend Integration** - Update Flutter UI

---

## ✅ Acceptance Criteria

- [ ] Can signup with OTP verification
- [ ] Can login with OTP verification
- [ ] Can reset password via email link
- [ ] Can view all active devices
- [ ] Can logout from specific device
- [ ] Can logout from all devices
- [ ] Rate limiting prevents brute force
- [ ] Account locks after 5 failed attempts
- [ ] Email verification blocks full access

---

## 🚀 Next Step

Start with **Phase 1: OTP System** implementation.

Ready to begin? Type: `start otp implementation`
