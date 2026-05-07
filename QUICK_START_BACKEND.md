# 🚀 SwiftNest Backend - Quick Start Guide

**Status**: ✅ Stage 3 Complete - Backend Ready  
**Date**: March 23, 2026

---

## ⚡ Quick Start (5 minutes)

### 1. Install & Setup
```bash
cd backend
npm install
cp .env.example .env
```

### 2. Start Docker Services
```bash
# Make sure Docker is installed
docker-compose up -d

# Wait 10 seconds for services to start
# Check: MongoDB at http://localhost:8081, Redis at localhost:6379
```

### 3. Run Backend
```bash
npm run start:dev
```

**Output should show:**
```
🚀 SwiftNest server running on port 3000
```

---

## ✅ Test Authentication

### Signup
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

**Response** (save the tokens):
```json
{
  "userId": "...",
  "accessToken": "eyJhbGci...",
  "refreshToken": "eyJhbGci...",
  "expiresIn": 1800
}
```

### Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Verify Token (Replace with your token)
```bash
curl -X POST http://localhost:3000/auth/verify-token \
  -H "Authorization: Bearer <YOUR_ACCESS_TOKEN>"
```

---

## 📁 Important Files

```
backend/
├── .env                    ← Your config (edit this)
├── docker-compose.yml      ← MongoDB + Redis setup
├── src/
│   ├── main.ts            ← Entry point
│   ├── app.module.ts      ← All modules loaded here
│   └── auth/              ← Authentication endpoints
│       ├── auth.controller.ts
│       ├── auth.service.ts
│       └── schemas/user.schema.ts
└── BACKEND_SETUP.md       ← Full documentation
```

---

## 🔧 Available Commands

```bash
npm run start:dev          # Development (auto-reload)
npm run start:prod         # Production build
npm run build              # Compile TypeScript
npm run test               # Run tests
npm run lint               # Check code style
npm run format             # Format code
```

---

## 🌐 API Endpoints

```
POST   /auth/signup        ← Create account
POST   /auth/login         ← Login with email/password
POST   /auth/verify-token  ← Check token (needs auth)
POST   /auth/refresh       ← Get new access token
POST   /auth/logout        ← Logout (needs auth)
```

---

## 🔑 Environment Variables

Key variables in `.env`:

```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/swiftnest
REDIS_HOST=localhost
JWT_SECRET=your-super-secret-key (change in production!)
```

---

## 🐳 Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f mongodb
docker-compose logs -f redis

# Remove volumes (delete data)
docker-compose down -v
```

---

## 📊 MongoDB GUI

Access at: **http://localhost:8081**

Username: `admin`  
Password: `password`

---

## 🚨 Troubleshooting

### Port 3000 already in use
```bash
# Change in .env:
PORT=3001
```

### MongoDB connection refused
```bash
# Check if MongoDB is running:
docker ps | grep mongodb

# Start if not running:
docker-compose up -d mongodb
```

### Redis connection refused
```bash
# Check if Redis is running:
docker ps | grep redis

# Start if not running:
docker-compose up -d redis
```

---

## 📝 Log Files

```bash
tail -f logs/app.log       # Application logs
tail -f logs/error.log     # Error logs
```

---

## 🎯 What's Ready

✅ Authentication (signup, login, logout)  
✅ JWT tokens with refresh  
✅ MongoDB for user storage  
✅ Redis for caching  
✅ Logging system  
✅ Error handling  

---

## 📚 Full Documentation

Open `BACKEND_SETUP.md` for:
- Complete setup instructions
- All configuration options
- API examples with curl
- Security features
- Database schema
- Next steps

---

## 🔐 Security Notes

⚠️ **Change these in production:**
```
JWT_SECRET              → Generate random 256-bit string
JWT_REFRESH_SECRET      → Generate random 256-bit string
REDIS_PASSWORD          → Set a strong password
MONGODB_URI             → Use MongoDB Atlas or secured instance
```

---

## ✨ You're All Set!

```bash
# One command to start everything:
docker-compose up -d && npm run start:dev
```

The backend is now running and ready for:
- ✅ Flutter frontend integration
- ✅ Real-time Socket.IO in Stage 5
- ✅ Production deployment

---

**Questions?** Check `BACKEND_SETUP.md`  
**Ready for Stage 4?** Start with OTP verification  
**Need help?** Check `/logs/` directory for detailed errors

**SwiftNest Backend** | Stage 3 ✅ | Ready for Development
