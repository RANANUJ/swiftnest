# 🏗️ SWIFTNEST ARCHITECTURE - MONGODB + REDIS

```
┌──────────────────────────────────────────────────────────────────────┐
│                    SWIFTNEST CHAT APPLICATION                        │
└──────────────────────────────────────────────────────────────────────┘

┌─────────────────────────┐
│  FLUTTER MOBILE APP     │  <- iOS / Android
│   (Your Clients)        │
└────────────┬────────────┘
             │ HTTP / WebSocket
             │ Port 3000
             ↓
┌─────────────────────────────────────────────────────────────────┐
│              NESTJS BACKEND (NestJS Server)                     │
│              http://localhost:3000                              │
│                                                                 │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐      │
│  │   Auth API  │  │  Chat API    │  │  Media API       │      │
│  │             │  │              │  │                  │      │
│  │ POST /signup│  │ POST /send   │  │ POST /upload     │      │
│  │ POST /login │  │ GET /messages│  │ GET /download    │      │
│  │ POST /logout│  │ GET /chats   │  │                  │      │
│  └─────────────┘  └──────────────┘  └──────────────────┘      │
└────────┬──────────────────────────────┬────────────────────────┘
         │                              │
    ┌────┴────┐                    ┌────┴────┐
    │ TLS/SSL │                    │Websocket│
    │ HTTPS   │                    │ (Soon)  │
    ↓         ↓                    ↓
┌────────────────────┐        ┌──────────────┐
│  MONGODB ATLAS     │        │   REDIS      │
│  (Cloud)           │        │  (Docker)    │
│                    │        │              │
│ Store:             │        │ Store:       │
│ - Users            │        │ - Presence   │
│ - Chats            │        │ - Sessions   │
│ - Messages         │        │ - OTP Codes  │
│ - Groups           │        │ - Cache      │
│ - Media Meta       │        │              │
│                    │        │              │
│ URL:               │        │ Port: 6379   │
│ mongodb+srv://...  │        │              │
│                    │        │              │
│ Database: swiftne  │        │ Docker       │
│ User: swiftnest_u  │        │ running      │
└────────────────────┘        └──────────────┘

    Cloud (MongoDB)          Local (Docker)
   mongodb.com              localhost
```

---

## 🔄 DATA FLOW EXAMPLE: User Signup

```
1. USER SIGNS UP (Mobile)
   ┌────────────────────┐
   │ Flutter App        │
   │ Email: test@ex.com │
   │ Password: pwd123   │
   └─────────┬──────────┘
             │ HTTP POST
             │ POST /auth/signup
             ↓
   ┌─────────────────────────────────────┐
   │ NestJS Backend (Port 3000)          │
   │                                     │
   │ 1. Validate email & password        │
   │ 2. Hash password (bcrypt)           │
   │ 3. Create user object               │
   │ 4. Save to MongoDB Atlas            │
   └──────┬──────────────────────────────┘
          │ HTTPS Connection
          │ mongodb+srv://...
          ↓
   ┌─────────────────────────────────────┐
   │ MongoDB Atlas (Cloud)               │
   │                                     │
   │ Database: swiftnest                 │
   │ Collection: users                   │
   │                                     │
   │ New document:                       │
   │ {                                   │
   │   _id: ObjectId(...),               │
   │   email: "test@ex.com",             │
   │   password: "$2b$12$...(hashed)",   │
   │   name: "User",                     │
   │   createdAt: Date                   │
   │ }                                   │
   └─────────────────────────────────────┘
             │
             ↓ Return
   ┌─────────────────────────────────────┐
   │ NestJS Backend                      │
   │                                     │
   │ 5. Generate JWT token               │
   │ 6. Store token in Redis (optional)  │
   │ 7. Return response                  │
   └─────────┬──────────────────────────┘
             │ HTTP Response
             │ JSON with accessToken
             ↓
   ┌────────────────────┐
   │ Flutter App        │
   │                    │
   │ ✅ token received  │
   │ ✅ User logged in  │
   └────────────────────┘

2. REDIS STORES SESSION (Optional)
   ┌──────────────────────────────────────┐
   │ NestJS Backend                       │
   │                                      │
   │ redis.set(                           │
   │   userId,                            │
   │   sessionData,                       │
   │   {EX: 24*60*60}                    │ <- 24 hours
   │ )                                    │
   └───────────┬────────────────────────┘
               │ Socket Connection
               ↓
   ┌──────────────────────────────────────┐
   │ Redis (Docker)                       │
   │ localhost:6379                       │
   │                                      │
   │ KEY: "session:userId123"             │
   │ VALUE: {user, token, permissions}   │
   │ TTL: 24 hours                        │
   └──────────────────────────────────────┘
```

---

## ✅ SETUP CHECKLIST WITH ARCHITECTURE

```
SETUP PHASE:
☐ Step 1: Create MongoDB Atlas account
  └─ Result: mongodb+srv://swiftnest_user:...@cluster0.xxxxx.mongodb.net

☐ Step 2: Create Database User
  └─ Result: Username: swiftnest_user, Password: saved

☐ Step 3: Create .env file entry
  └─ Result: MONGODB_URI=mongodb+srv://...

☐ Step 4: Start Redis with Docker
  └─ Result: Redis running on localhost:6379

☐ Step 5: Run Backend
  └─ Result: NestJS listening on port 3000

TESTING PHASE:
☐ Test API: POST /auth/signup
  └─ Result: User created in MongoDB Atlas

☐ Verify: Check MongoDB Collections
  └─ Result: User data visible in cloud

☐ Test API: POST /auth/login
  └─ Result: Access token returned
```

---

## 🌍 LIVE EXAMPLE

### Your Setup Will Look Like This:

**1. MongoDB Atlas Dashboard (Cloud)**
```
Username: your-email@gmail.com
Cluster: swiftnest-cluster (M0 Shared, 512 MB)
Database: swiftnest
Collections:
  - users (your test user will be here)
  - chats (future)
  - messages (future)
```

**2. Redis Running Locally**
```
Port: 6379
Status: Running in Docker container
Data: Cached sessions, OTP codes
```

**3. Your Backend**
```
Port: 3000
Status: Connected to:
  - MongoDB Atlas ✅
  - Redis ✅
  - Ready for requests ✅
```

**4. Your .env File**
```
MONGODB_URI=mongodb+srv://swiftnest_user:password@cluster0.abc123.mongodb.net/swiftnest?retryWrites=true&w=majority
REDIS_HOST=localhost
REDIS_PORT=6379
PORT=3000
```

---

## 📊 CONNECTION DIAGRAM

```
When you call: POST /auth/signup

STEP 1: Request Arrives
┌─────────────────────────────────────┐
│ Frontend (Flutter) sends:           │
│ POST http://localhost:3000/signup   │
│ {                                   │
│   email: "user@example.com",        │
│   password: "secret123",            │
│   name: "John"                      │
│ }                                   │
└────────────┬────────────────────────┘
             │
STEP 2: Backend Processes
┌────────────┴─────────────────────────────────────────┐
│ NestJS AuthService.signup():                         │
│                                                      │
│ 1. Validate input (email format, password length)    │
│ 2. Check if user already exists (Query MongoDB)      │
│ 3. Hash password with bcrypt                         │
│ 4. Create user document                             │
│ 5. Save to MongoDB Atlas                            │
│                                                      │
│    → mongodb+srv://...                              │
│       INSERT INTO users VALUES(...)                 │
│                                                      │
│ 6. Generate JWT token                               │
│ 7. Store in Redis (optional, for fast lookup)       │
│                                                      │
│    → redis://localhost:6379                         │
│       SET session:userId {...}                      │
│                                                      │
│ 8. Return response with token                       │
└────────────┬─────────────────────────────────────────┘
             │
STEP 3: Response Sent
┌────────────┴────────────────────┐
│ Frontend receives:              │
│ {                               │
│   userId: "507f1f77...",        │
│   email: "user@example.com",    │
│   accessToken: "eyJhbGc...",    │
│   refreshToken: "eyJhbGc...",   │
│   expiresIn: 1800               │
│ }                               │
│                                 │
│ ✅ User created!                │
│ ✅ Data in MongoDB!             │
│ ✅ Session in Redis!            │
└─────────────────────────────────┘
```

---

## 🔐 SECURITY FLOW

```
Password Security:
┌─────────────────┐
│ User Password   │ (plain text from form)
│ "password123"   │
└────────┬────────┘
         │ bcrypt.hash()
         ↓
┌─────────────────────────────────┐
│ Hashed Password                 │
│ "$2b$12$..." (not reversible)   │
└────────┬────────────────────────┘
         │ Save to MongoDB
         ↓
┌─────────────────────────────────┐
│ MongoDB Atlas (Encrypted)       │
│                                 │
│ users collection:               │
│ {                               │
│   email: "user@example.com",    │
│   password: "$2b$12$..."  ← Hash│
│ }                               │
└─────────────────────────────────┘

Next login:
┌─────────────────┐
│ User Password   │ (plain text again)
│ "password123"   │
└────────┬────────┘
         │ bcrypt.compare() vs stored hash
         ↓
┌──────────────────┐
│ ✅ Match! ✅     │ → Generate new token
│                  │
│ ❌ No match ❌   │ → Return 401 error
└──────────────────┘
```

---

## 🎯 FINAL ARCHITECTURE

```
┌──────────────────────────────────────────────────────────────┐
│                  SWIFTNEST SYSTEM ARCHITECTURE              │
└──────────────────────────────────────────────────────────────┘

TIER 1: CLIENT
  ✓ Flutter App (Android/iOS)
  └─ Makes HTTP/WebSocket calls

TIER 2: APPLICATION
  ✓ NestJS Backend (Node.js Server)
  ├─ Authentication (JWT tokens)
  ├─ Business Logic
  ├─ Rate Limiting
  └─ WebSocket Handler (future)

TIER 3: DATA
  ├─ MongoDB Atlas (Persistence)
  │  ├─ Users Collection
  │  ├─ Chats Collection
  │  ├─ Messages Collection
  │  └─ Groups Collection
  │
  └─ Redis (Cache/Sessions)
     ├─ User Sessions
     ├─ Presence Status
     ├─ OTP Codes
     └─ Real-time Data

TIER 4: INFRASTRUCTURE
  ├─ Cloud: MongoDB Atlas (mongodb.com)
  └─ Local: Docker Redis (localhost:6379)

COMMUNICATION:
  Client ←→ Backend (HTTP/WebSocket, Port 3000)
  Backend ←→ MongoDB (TLS Connection String)
  Backend ←→ Redis (Local Socket, Port 6379)

RESULT: ✅ Complete Backend-to-Database Pipeline
```

---

**Now Ready!** → Follow `CONNECTION_STEPS.md`

🚀 **10 minutes to full integration!**
