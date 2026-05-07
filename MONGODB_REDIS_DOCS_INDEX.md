# 📚 MongoDB & Redis Connection - Documentation Index

**Date**: March 23, 2026  
**Status**: 🟢 Ready to Set Up

---

## 📖 Read These Files (in order)

### 1. **START HERE**: `CONNECTION_STEPS.md` ⭐
   - 🎯 5-step quick guide
   - Copy-paste commands
   - Test commands included
   - **Time: 10 minutes**

### 2. **DETAILED GUIDE**: `QUICK_CONNECT_MONGODB_REDIS.md` 📋
   - Step-by-step MongoDB Atlas setup
   - Screenshots/descriptions
   - .env file examples
   - **Time: 5 minutes**

### 3. **COMPLETE REFERENCE**: `MONGODB_ATLAS_REDIS_SETUP.md` 📚
   - Full technical documentation
   - Option A (Docker) vs Option B (Cloud Redis)
   - Monitoring dashboards
   - Production checklist
   - **Time: Reference guide**

---

## 🎯 The 5-Minute Quick Setup

```
Step 1: Create MongoDB Atlas account (2 min)
    ↓
Step 2: Create cluster + database user (1 min)
    ↓
Step 3: Get connection string (1 min)
    ↓
Step 4: Update .env file (1 min)
    ↓
Step 5: Test it works (1 min)
```

---

## 📝 What You'll Get

After following the setup:

```
✅ MongoDB Atlas Account (Free, Cloud-based)
✅ Cluster Created (M0 Shared, 512 MB)
✅ Database User (swiftnest_user)
✅ Connection String (mongodb+srv://...)
✅ Backend Connected to MongoDB
✅ Redis Running Locally
✅ Full Backend-to-Database Pipeline
```

---

## ⚙️ Your Current Architecture

### After Setup:

```
┌─────────────────────────────────────┐
│      Flutter App (Mobile)           │
└────────────────┬────────────────────┘
                 │ HTTP/WebSocket
                 ↓
┌─────────────────────────────────────┐
│   NestJS Backend (Port 3000)        │
│                                     │
│  ├── /auth/signup                  │
│  ├── /auth/login                   │
│  ├── /auth/logout                  │
│  └── ... (more routes)             │
└────┬──────────────────────┬─────────┘
     │                      │
     │                      │
   TLS/SSL              Socket.IO
     │                      │
     ↓                      ↓
┌──────────────────┐  ┌──────────────────┐
│ MongoDB Atlas    │  │ Redis (Docker)   │
│ (Cloud Database) │  │ (Local Cache)    │
│                  │  │                  │
│ Store:           │  │ Store:           │
│ - Users          │  │ - Sessions       │
│ - Messages       │  │ - Cache          │
│ - Groups         │  │ - Presence       │
│ - Media Meta     │  │ - OTP codes      │
└──────────────────┘  └──────────────────┘

Cloud (MongoDB.com)  Local Machine (Docker)
```

---

## 🚀 Quick Commands Reference

### Create MongoDB Atlas Account
```
https://www.mongodb.com/cloud/atlas
```

### Update .env (after getting connection string)
```
MONGODB_URI=mongodb+srv://swiftnest_user:PASSWORD@cluster0.xxxxx.mongodb.net/swiftnest?retryWrites=true&w=majority
```

### Start Redis
```powershell
cd backend
docker-compose up -d redis
```

### Start Backend
```powershell
npm run start:dev
```

### Test API
```powershell
curl -X POST http://localhost:3000/auth/signup `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"test@example.com","password":"pwd123","name":"User"}'
```

### Check MongoDB
```
https://cloud.mongodb.com → Collections → See your data!
```

---

## 📋 MongoDB Atlas Setup Checklist

- [ ] Create account at mongodb.com/cloud/atlas
- [ ] Create free cluster (M0 Shared)
- [ ] Create database user: swiftnest_user
- [ ] Whitelist your IP
- [ ] Get connection string
- [ ] Update backend/.env
- [ ] Test connection

**Estimated time: 5 minutes**

---

## 🔧 Redis Setup Checklist

- [ ] Docker installed
- [ ] Run: `docker-compose up -d redis`
- [ ] Verify: `docker ps | grep redis`
- [ ] Redis running on localhost:6379

**Estimated time: 1 minute**

---

## ✅ Verification Checklist

After setup:

- [ ] Backend starts without errors
- [ ] Can call API: /auth/signup
- [ ] User created successfully
- [ ] Data appears in MongoDB Atlas Collections
- [ ] No connection errors in logs

---

## 📊 Performance Expectations

After setup:

| Metric | Expected |
|--------|----------|
| Signup Time | < 500ms |
| Login Time | < 300ms |
| MongoDB Query | < 50ms |
| Data in Atlas | Instant |
| Redis Response | < 10ms |

---

## 🎓 Learning Outcome

You'll understand:

- ✅ Cloud databases (MongoDB Atlas)
- ✅ Connection strings & security
- ✅ IP whitelisting
- ✅ Environment configuration
- ✅ Backend-to-database integration
- ✅ API testing with curl
- ✅ Docker containers (Redis)

---

## 🆘 Getting Help

### Error: "Cannot connect to MongoDB"
→ See `CONNECTION_STEPS.md` → Step 2 troubleshooting

### Error: "Redis connection failed"
→ See `MONGODB_ATLAS_REDIS_SETUP.md` → Troubleshooting section

### Questions about setup?
→ Read `MONGODB_ATLAS_REDIS_SETUP.md` (detailed guide)

---

## 🚀 You're Almost There!

```
Before Setup:  ❌ No database connection
After Setup:   ✅ Full MongoDB + Redis integration
```

**Next**: Follow `CONNECTION_STEPS.md` (5 minutes!)

---

## 📞 Quick Links

- MongoDB Atlas: https://cloud.mongodb.com
- Redis Cloud (if using cloud): https://redis.com/try-free
- Docker Desktop: https://www.docker.com/products/docker-desktop
- Your Cluster Collections: https://cloud.mongodb.com (after login)

---

## 🎯 Success Criteria

After setup, you can:

✅ Create user (API returns access token)  
✅ See user in MongoDB Atlas  
✅ Login with same email  
✅ Get new token from refresh endpoint  
✅ Access protected routes with token  

---

**Status**: 🟢 Ready to Begin  
**Difficulty**: Easy (5 minutes)  
**Next**: Open `CONNECTION_STEPS.md` and follow!

🚀 **Let's connect MongoDB and Redis!**
