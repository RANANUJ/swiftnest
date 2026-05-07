# MongoDB Atlas + Redis Connection Guide

**Date**: March 23, 2026  
**Project**: SwiftNest Backend

---

## 📦 Step 1: Set Up MongoDB Atlas (Cloud)

MongoDB Atlas is a cloud service - no installation needed!

### 1.1 Create MongoDB Atlas Account

1. Go to: https://www.mongodb.com/cloud/atlas
2. Click **"Sign Up Free"**
3. Register with your email
4. Verify your email
5. Accept terms and create account

### 1.2 Create Your First Cluster

1. After login, click **"Create"** button
2. Choose **"Shared"** (free tier - 512 MB storage)
3. Select a cloud provider: **AWS/GCP/Azure** (any is fine)
4. Choose region closest to you
5. Click **"Create Cluster"** (takes 1-2 minutes)

### 1.3 Create Database User

1. In left sidebar, click **"Security"** → **"Database Access"**
2. Click **"Add New Database User"**
3. Enter:
   - **Username**: `swiftnest_user`
   - **Password**: Generate secure password (save it!)
   - **Database**: "Admin Database"
4. Click **"Add User"**

**Important**: Save the username and password!

### 1.4 Whitelist Your IP

1. Go to **"Security"** → **"Network Access"**
2. Click **"Add IP Address"**
3. For development, click **"Allow Access from Anywhere"** (temporarily)
4. In production, use your server IP only
5. Click **"Confirm"**

### 1.5 Get Connection String

1. Go to **"Deployments"** → **"Database"**
2. Click **"Connect"** button on your cluster
3. Choose **"Drivers"**
4. Select **"Node.js"** and version **5.x or later**
5. Copy the connection string (looks like this):

```
mongodb+srv://<USERNAME>:<PASSWORD>@cluster0.xxxxx.mongodb.net/<DBNAME>?retryWrites=true&w=majority
```

**Replace**:
- `<USERNAME>` → `swiftnest_user`
- `<PASSWORD>` → Your password
- `<DBNAME>` → `swiftnest`

**Result**:
```
mongodb+srv://swiftnest_user:YourPassword123@cluster0.abc123.mongodb.net/swiftnest?retryWrites=true&w=majority
```

---

## 🔧 Step 2: Update Backend Configuration

### 2.1 Edit Your `.env` File

Open: `backend/.env`

**Find this line**:
```
MONGODB_URI=mongodb://localhost:27017/swiftnest
```

**Replace with** (your MongoDB Atlas connection string):
```
MONGODB_URI=mongodb+srv://swiftnest_user:YourPassword123@cluster0.abc123.mongodb.net/swiftnest?retryWrites=true&w=majority
```

**Complete `.env` file should look like**:
```env
# Application
NODE_ENV=development
PORT=3000
APP_NAME=SwiftNest
APP_URL=http://localhost:3000

# MongoDB Atlas - UPDATED
MONGODB_URI=mongodb+srv://swiftnest_user:YourPassword123@cluster0.abc123.mongodb.net/swiftnest?retryWrites=true&w=majority

# Redis - Keep for now
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION=1800
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-this
JWT_REFRESH_EXPIRATION=2592000

# Security
BCRYPT_ROUNDS=12
OTP_EXPIRATION=300
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=debug
LOG_FILE=logs/app.log
LOG_MAX_SIZE=10m
LOG_MAX_FILES=14

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8081

# AWS/S3 (Optional)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=swiftnest-media

# Email (Optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=noreply@swiftnest.com
```

---

## 💾 Step 3: Set Up Redis

### Option A: Using Docker (Recommended for development)

Keep your existing docker-compose setup:

```bash
docker-compose up -d redis
```

This will start Redis on `localhost:6379`

**Your `.env` stays as**:
```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0
```

### Option B: Using Redis Cloud (Recommended for production)

1. Go to: https://redis.com/try-free/
2. Click **"Try Free"**
3. Create account (or login with GitHub)
4. Click **"Create Subscription"**
5. Choose:
   - **Provider**: AWS/GCP/Azure
   - **Region**: Closest to you
   - **Type**: Fixed (free tier - 30 MB)
6. Click **"Let's start free"**
7. In your database, click **"Connect"**
8. Copy the connection string (Redis URL)

**Update your `.env`**:
```env
# Instead of localhost, use Redis Cloud URL
REDIS_HOST=redis-xxxxx.cloud.redislabs.com
REDIS_PORT=12345
REDIS_PASSWORD=YourRedisPassword
REDIS_DB=0
```

Or store the full URL:
```env
# Or use connection string format
REDIS_URL=redis://:password@host:port/db
```

**For Docker setup**, `redis.config.ts` needs small update if using Redis Cloud:

```typescript
// src/config/redis.config.ts
export const redisConfig = (): any => {
  return {
    host: process.env.REDIS_CLOUD === 'true' 
      ? process.env.REDIS_HOST 
      : 'localhost',
    port: parseInt(process.env.REDIS_PORT) || 6379,
    password: process.env.REDIS_PASSWORD || undefined,
    tls: process.env.REDIS_CLOUD === 'true' ? {} : undefined,
  };
};
```

---

## ✅ Step 4: Test Connections

### 4.1 Test MongoDB Atlas Connection

```bash
cd backend

# Install Mongoose CLI tool
npm install -g mongoose-cli

# Or test via your app
npm run start:dev
```

**Check logs for**:
```
✅ Database connected!
🗄️  Connecting to MongoDB: mongodb+srv://swiftnest_user:...
```

### 4.2 Test the API

```bash
# Create a user (tests MongoDB)
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'

# Check MongoDB Atlas
# Go to: https://cloud.mongodb.com → Collections
# You should see the new user!
```

### 4.3 Monitor MongoDB Atlas

1. Go to **https://cloud.mongodb.com**
2. Click your cluster
3. Click **"Collections"**
4. You should see:
   - Database: `swiftnest`
   - Collection: `users`
   - Your test user!

---

## 🔐 Security Notes

### Production Checklist

Before deploying to production:

```env
# 1. Change MongoDB Atlas password
MONGODB_URI=mongodb+srv://swiftnest_user:NEW_STRONG_PASSWORD@...

# 2. Set strong JWT secrets
JWT_SECRET=Generate_256_bit_random_string_here
JWT_REFRESH_SECRET=Generate_another_256_bit_random_string

# 3. Restrict IP whitelist
# In MongoDB Atlas → Network Access
# Remove "Allow from anywhere"
# Add your server's IP only

# 4. Use Redis Cloud with TLS
REDIS_CLOUD=true
REDIS_PASSWORD=strong_password_here

# 5. Change environment
NODE_ENV=production

# 6. Restrict CORS
CORS_ORIGIN=https://yourdomain.com
```

---

## 🚀 Step 5: Complete Setup (All Together)

### For Development (with Docker Redis):

```bash
cd backend

# 1. Update .env with MongoDB Atlas URI
# (Edit backend/.env)

# 2. Start Redis using Docker
docker-compose up -d redis

# 3. Run backend
npm run start:dev

# Output should show:
# 🚀 SwiftNest server running on port 3000
```

### For Production (with Redis Cloud):

```bash
cd backend

# 1. Update .env:
# MONGODB_URI=mongodb+srv://...
# REDIS_CLOUD=true
# REDIS_HOST=redis-xxxxx.cloud.redislabs.com
# JWT_SECRET=real_secret_key
# NODE_ENV=production

# 2. Build
npm run build

# 3. Deploy to server
npm run start:prod
```

---

## 📊 Connection String Examples

### MongoDB Atlas (Your Setup)
```
mongodb+srv://swiftnest_user:Password123@cluster0.abc123.mongodb.net/swiftnest?retryWrites=true&w=majority
```

### Redis Local (Docker)
```
redis://localhost:6379
```

### Redis Cloud
```
redis://:password@redis-xxxxx.cloud.redislabs.com:12345
```

---

## 🐛 Troubleshooting

### "Cannot connect to MongoDB"

**Check**:
1. ✅ Connection string in `.env` is correct
2. ✅ Password has no special characters (or is URL-encoded)
3. ✅ Your IP is whitelisted in MongoDB Atlas
4. ✅ Database name is correct

**Test connection**:
```bash
# In MongoDB Atlas
# Click "Connect" → "MongoDB Shell"
# Copy and run the command

# Or test in Node.js:
node -e "
require('mongoose').connect('mongodb+srv://...', {}).then(() => {
  console.log('✅ Connected!');
  process.exit();
}).catch(err => {
  console.error('❌ Failed:', err);
  process.exit(1);
});
"
```

### "Cannot connect to Redis"

**If using Docker**:
```bash
# Check if Redis is running
docker ps | grep redis

# Start if not running
docker-compose up -d redis

# Check logs
docker-compose logs redis
```

**If using Redis Cloud**:
```bash
# Test connection
redis-cli -h redis-xxxxx.cloud.redislabs.com -p 12345 -a PASSWORD ping

# Should print: PONG
```

### "Connection timeout"

**MongoDB Atlas**:
- Go to **Security** → **Network Access**
- Make sure your IP is added
- Or temporarily use "Allow from Anywhere" for testing

**Redis Cloud**:
- Ensure TLS is enabled if using Redis Cloud

---

## 📈 Monitoring

### MongoDB Atlas Dashboard
- URL: https://cloud.mongodb.com
- Check:
  - ✅ Active connections
  - ✅ Data size
  - ✅ Operations per second
  - ✅ Logs

### Redis Monitoring (if using Redis Cloud)
- URL: https://app.redislabs.com
- Check:
  - ✅ Memory usage
  - ✅ Commands/sec
  - ✅ Connected clients

---

## ✨ You're All Set!

```bash
# One command to start:
npm run start:dev

# You should see:
# 🚀 SwiftNest server running on port 3000
# Connected to MongoDB Atlas ✅
# Connected to Redis ✅
```

---

## 📝 Next Steps

1. ✅ MongoDB Atlas configured
2. ✅ Redis configured
3. ✅ Backend connected to both
4. 👉 Test API endpoints
5. 👉 Connect Flutter frontend

**Ready to test?**

```bash
# Signup test
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe"
  }'
```

---

**Questions?** Check your `.env` file and MongoDB Atlas dashboard  
**Need help?** Check the logs: `tail -f logs/app.log`
