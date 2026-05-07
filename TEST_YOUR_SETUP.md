# ✅ TEST YOUR MONGODB + REDIS SETUP

After following `CONNECTION_STEPS.md`, use this guide to verify everything works!

---

## 🎯 QUICK TEST (5 minutes)

### Test 1: Is Backend Running?

**Command:**
```bash
curl http://localhost:3000/health
```

**Expected Response:**
```json
{"status":"ok","timestamp":"2024-01-20T10:30:45.123Z"}
```

**Troubleshooting:**
- ❌ "Connection refused" → Backend isn't running. Run: `cd backend && npm run start:dev`
- ❌ Timeout → Check if port 3000 is in use: `netstat -ano | findstr :3000`

---

### Test 2: Is MongoDB Connected?

**Command:**
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "TestPassword123!",
    "name": "Test User"
  }'
```

**Expected Response:**
```json
{
  "userId": "507f1f77bcf86cd799439011",
  "email": "testuser@example.com",
  "name": "Test User",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 1800
}
```

**Troubleshooting:**
- ❌ "MONGODB_URI not found" → Check your backend/.env file has MONGODB_URI
- ❌ "Invalid connection string" → Verify the connection string format:
  ```
  mongodb+srv://swiftnest_user:PASSWORD@cluster0.xxxxx.mongodb.net/swiftnest?retryWrites=true&w=majority
  ```
- ❌ "Cannot reach server" → Check your MongoDB Atlas network access whitelist (allow 0.0.0.0/0 for dev)

---

### Test 3: Verify Data in MongoDB Atlas

1. **Open your MongoDB Atlas Dashboard:**
   - Go to: https://cloud.mongodb.com/
   - Login with your account
   - Select your project
   - Select "swiftnest-cluster"

2. **Navigate to Collections:**
   - Click "Browse Collections"
   - Select "swiftnest" database
   - Look for "users" collection

3. **Verify the Test User:**
   ```
   Collection: users
   Document:
   {
     "_id": ObjectId("..."),
     "email": "testuser@example.com",
     "password": "$2b$12$...(hashed password, not plain text)",
     "name": "Test User",
     "createdAt": ISODate("2024-01-20T10:30:45.123Z"),
     "updatedAt": ISODate("2024-01-20T10:30:45.123Z")
   }
   ```

**If you see this → ✅ MongoDB is working!**

---

### Test 4: Is Redis Connected?

**Command (Check if Redis is running):**
```bash
docker ps | findstr redis
```

**Expected Output:**
```
a1b2c3d4e5f6   redis:7   "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes   0.0.0.0:6379->6379/tcp   swiftnest-redis
```

**If Redis is running → ✅ Redis is working!**

---

## 🔐 TEST LOGIN (Authentication)

### Test 5: Login with Your Test User

**Command:**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "TestPassword123!"
  }'
```

**Expected Response:**
```json
{
  "userId": "507f1f77bcf86cd799439011",
  "email": "testuser@example.com",
  "name": "Test User",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 1800
}
```

**Troubleshooting:**
- ❌ "Invalid email or password" → User doesn't exist. Try the email you used in Test 2
- ❌ "User not found" → The user wasn't saved to MongoDB. Check Test 2 results

**If you get a token → ✅ Authentication is working!**

---

### Test 6: Use Authentication Token

**Get your accessToken from Test 5 response, then:**

```bash
curl -X GET http://localhost:3000/auth/verify \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "userId": "507f1f77bcf86cd799439011",
  "email": "testuser@example.com",
  "name": "Test User"
}
```

**Troubleshooting:**
- ❌ "Invalid token" → The token is expired or malformed
- ❌ "No token" → You forgot to include the Authorization header
- ❌ "Unauthorized" → Check the token starts with "eyJ"

**If you get user data → ✅ JWT authentication is working!**

---

## 🚀 ADVANCED TESTS (Optional)

### Test 7: Refresh Token

**Command:**
```bash
curl -X POST http://localhost:3000/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "YOUR_REFRESH_TOKEN_HERE"
  }'
```

**Expected Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...(new token)",
  "expiresIn": 1800
}
```

---

### Test 8: Logout

**Command:**
```bash
curl -X POST http://localhost:3000/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "message": "Successfully logged out"
}
```

---

## 🐛 COMPLETE TROUBLESHOOTING GUIDE

### Issue: Backend Won't Start

**Symptoms:** `npm run start:dev` fails immediately

**Check List:**
1. Do you have Node.js installed?
   ```bash
   node --version
   ```
   Should show v16+

2. Is the .env file created?
   ```bash
   cd backend
   ls .env
   ```
   File should exist

3. Are all npm packages installed?
   ```bash
   npm install
   ```

4. Check the error message:
   ```bash
   npm run start:dev 2>&1 | head -50
   ```

---

### Issue: MongoDB Connection Failed

**Symptoms:** Backend starts but database operations fail

**Error Message: "Cannot connect to MongoDB"**

**Fix Checklist:**
1. ✅ Is MONGODB_URI in your .env?
   ```bash
   grep MONGODB_URI backend/.env
   ```

2. ✅ Is the connection string correct?
   - Should start with: `mongodb+srv://`
   - Should contain: `@cluster0.xxxxx.mongodb.net/`
   - Should end with: `?retryWrites=true&w=majority`

3. ✅ Is your IP address whitelisted in MongoDB Atlas?
   - Go to: https://cloud.mongodb.com/ → Security → Network Access
   - Add your IP: 0.0.0.0/0 (development) or your actual IP (production)

4. ✅ Is your database user correct?
   - Username: `swiftnest_user`
   - Password: The one you created in MongoDB Atlas

5. ✅ Does the database name match?
   - Should be: `/swiftnest?` (after the hostname)

**Test Connection:**
```bash
# Add this to backend/.env temporarily
DEBUG=mongoose:*

npm run start:dev
```

Look for: "connected to MongoDB Atlas successfully"

---

### Issue: Redis Connection Failed

**Symptoms:** Backend connects but Redis operations fail

**Error Message: "Cannot connect to Redis"**

**Fix Checklist:**
1. ✅ Is Redis running?
   ```bash
   docker ps | findstr redis
   ```
   Should show a running container

2. ✅ Start Redis if not running:
   ```bash
   docker-compose -f docker-compose.yml up -d redis
   ```

3. ✅ Is Redis accessible on port 6379?
   ```bash
   telnet localhost 6379
   ```
   If it connects (blank screen), then Redis is running

4. ✅ Check your REDIS_HOST and REDIS_PORT in .env:
   ```bash
   grep REDIS backend/.env
   ```
   Should be:
   ```
   REDIS_HOST=localhost
   REDIS_PORT=6379
   ```

5. ✅ Restart Docker if needed:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

---

### Issue: Tests Fail at "Invalid Token"

**Symptoms:** Test 6 returns "Invalid token"

**Possible Causes:**
1. Token is incomplete or malformed
   - Copy the full token from Test 5 response
   - Make sure it starts with `eyJ`

2. Token is expired
   - Tokens expire after 30 minutes
   - Get a new token by running Test 5 again

3. Bearer format is wrong
   - Correct: `Authorization: Bearer eyJ...`
   - Incorrect: `Authorization: eyJ...` (missing "Bearer")

---

## 📊 VERIFICATION CHECKLIST

Mark these as you verify:

```
CONNECTIVITY TESTS:
☐ Test 1: Backend responds to /health
☐ Test 2: Can create user in MongoDB
☐ Test 3: User data visible in MongoDB Atlas
☐ Test 4: Redis is running (docker ps shows it)

AUTHENTICATION TESTS:
☐ Test 5: Login returns valid token
☐ Test 6: Token can verify user
☐ Test 7: Refresh token works
☐ Test 8: Logout succeeds

ADVANCED TESTS:
☐ Can signup with different email
☐ Cannot login with wrong password
☐ Expired token is rejected
```

**All checked? → ✅ System is Ready!**

---

## 🎓 WHAT TO DO NEXT

### After Verification ✅

1. **Update Flutter App** to use real backend:
   ```dart
   // In lib/config/app_config.dart
   const apiBaseUrl = 'http://localhost:3000';  // Or your server IP
   ```

2. **Run Flutter App** and test login flow:
   ```bash
   flutter run
   ```

3. **Start Building Stage 4:**
   - OTP verification
   - Email verification
   - Password reset
   - Device session management

---

## 🚨 EMERGENCY RESET

If everything breaks, reset from scratch:

```bash
# Kill backend
Ctrl+C

# Reset database
# Go to MongoDB Atlas → Database → Delete swiftnest database
# (Or keep it and just clear collections)

# Reset Redis
docker-compose down
docker-compose up -d redis

# Restart backend
cd backend
npm run start:dev
```

---

**Questions?** Check:
- CONNECTION_STEPS.md (how to connect)
- MONGODB_ATLAS_REDIS_SETUP.md (full reference)
- QUICK_CONNECT_MONGODB_REDIS.md (detailed walkthrough)

**Ready to proceed?** → Run Test 1 now! 🚀
