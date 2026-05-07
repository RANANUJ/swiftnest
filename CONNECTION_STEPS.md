# 🚀 MONGODB ATLAS + REDIS CONNECTION STEPS

Follow these exact steps to connect your backend to MongoDB Atlas and Redis.

---

## 📝 COPY-PASTE QUICK REFERENCE

### Your Connection Flow:

```
Flutter App
    ↓
Backend (Port 3000)
    ├─ MongoDB Atlas (Cloud) ✅
    └─ Redis (Docker) ✅
```

---

## 🔴 STEP 1: MongoDB Atlas Setup (4 minutes)

### Go here: https://www.mongodb.com/cloud/atlas

1. **Sign Up** (free)
   - Email: your-email@example.com
   - Create account
   - Verify email

2. **Create Cluster**
   - Click "Create" → "Shared (M0, free)" → AWS → Any region → Create
   - ⏳ Wait 1-2 minutes for cluster to be ready

3. **Create Database User** (while waiting)
   - Left sidebar: Security → Database Access
   - Add New Database User
   - Username: `swiftnest_user`
   - Password: Click "Generate Secure Password" → **COPY IT** (save somewhere!)
   - Database: Admin Database
   - Add User

4. **Whitelist Your IP**
   - Security → Network Access
   - Add IP Address → Allow from Anywhere → Confirm

5. **Get Connection String**
   - Deployment → Database (main)
   - Click "Connect" button
   - Choose "Drivers"
   - Select "Node.js"
   - **COPY the connection string** (it starts with `mongodb+srv://`)

---

## 🟢 STEP 2: Update Your .env File (1 minute)

### File Location: `backend\.env`

**FIND THIS:**
```env
MONGODB_URI=mongodb://localhost:27017/swiftnest
```

**REPLACE WITH** (the connection string from Step 1):
```env
MONGODB_URI=mongodb+srv://swiftnest_user:YOUR_PASSWORD_HERE@cluster0.xxxxx.mongodb.net/swiftnest?retryWrites=true&w=majority
```

**EXAMPLE** (with real values):
```env
MONGODB_URI=mongodb+srv://swiftnest_user:MySecurePass123@cluster0.a1b2c3d.mongodb.net/swiftnest?retryWrites=true&w=majority
```

✅ **SAVE THE FILE**

---

## 🔵 STEP 3: Start Redis with Docker (1 minute)

### Open PowerShell in this folder:
```
D:\Flutter\flutter dev\projects\swiftnest\backend
```

### Run this command:
```powershell
docker-compose up -d redis
```

**Expected Output:**
```
✅ redis  Created
✅ redis  Started
```

✅ **Redis is now running on localhost:6379**

---

## 🟡 STEP 4: Run Your Backend (1 minute)

### Still in PowerShell (backend folder):

```powershell
npm run start:dev
```

**You should see:**
```
🚀 SwiftNest server running on port 3000
🗄️  Connecting to MongoDB: mongodb+srv://...
✅ App started!
```

✅ **Backend is running!**

---

## ⚪ STEP 5: Test the Connection (1 minute)

### Open NEW PowerShell window (don't close the backend one)

### Test Signup:
```powershell
$body = @{
    email = "test@example.com"
    password = "password123"
    name = "Test User"
} | ConvertTo-Json

curl -X POST http://localhost:3000/auth/signup `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

**Expected Response** (should have `accessToken`):
```json
{
  "userId": "507f1f77bcf86cd799439011",
  "email": "test@example.com",
  "name": "Test User",
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 1800
}
```

✅ **Connection successful!**

---

## 🔍 VERIFY IN MONGODB ATLAS

1. Go to: https://cloud.mongodb.com
2. Click your cluster
3. Click "Collections"
4. You should see:
   - Database: `swiftnest`
   - Collection: `users`
   - Your test user data!

✅ **Data is saved in MongoDB Atlas!**

---

## 📊 FINAL CHECKLIST

- [ ] MongoDB Atlas account created
- [ ] Cluster created
- [ ] Database user created (swiftnest_user)
- [ ] IP whitelisted
- [ ] Connection string copied
- [ ] `.env` file updated with MongoDB URI
- [ ] Redis started (docker-compose up -d redis)
- [ ] Backend running (npm run start:dev)
- [ ] Test API call successful
- [ ] User data appears in MongoDB Atlas

---

## ✅ YOU'RE CONNECTED!

Now you have:

```
✅ MongoDB Atlas (Cloud Database)
✅ Redis (Local Cache/Sessions)
✅ Backend (Port 3000)
✅ API Endpoints Ready (signup, login, etc.)
```

---

## 🆘 TROUBLESHOOTING

### Problem: "Cannot connect to MongoDB"

**Solution:**
1. Check `.env` file - is MONGODB_URI correct?
2. Go to MongoDB Atlas Network Access - is your IP whitelisted?
3. Check password - does it match what you copied?

**Test connection:**
```powershell
cd backend
npm run start:dev
# Check the logs
```

### Problem: "Docker not running"

**Solution:**
```powershell
# Check if Docker is running
docker ps

# If error, install Docker Desktop or start it
```

### Problem: "Port 3000 already in use"

**Solution:** Edit `backend\.env`
```env
PORT=3001
```

### Problem: "Redis connection failed"

**Solution:**
```powershell
# Make sure Redis container is running
docker ps | findstr redis

# If not, start it
docker-compose up -d redis
```

---

## 🔐 PRODUCTION NOTES

Before deploying to production:

1. **Change MongoDB Password**
   - Keep your current password safe
   - Update in `.env`

2. **Set Strong JWT Secrets**
   ```env
   JWT_SECRET=generate-long-random-string-here
   JWT_REFRESH_SECRET=generate-another-long-random-string
   ```

3. **Restrict Network Access**
   - In MongoDB Atlas → Network Access
   - Remove "Allow from Anywhere"
   - Add your server IP only

4. **Use Redis Cloud** (instead of local Docker)
   - Deploy to production with managed Redis
   - More secure and scalable

---

## 📞 NEXT STEPS

After connections are verified:

1. ✅ **Connections working** (you are here!)
2. 👉 **Test all API endpoints**
3. 👉 **Connect Flutter frontend**
4. 👉 **Add Socket.IO for real-time chat**
5. 👉 **Deploy to production**

---

**Status**: 🟢 Ready to Connect  
**Time**: ~10 minutes  
**Difficulty**: Easy  

**Let's do this!** 🚀
