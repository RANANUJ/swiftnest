# ⚡ QUICK SETUP - MongoDB Atlas + Redis (5 mins)

## 🎯 Follow These Steps EXACTLY

---

### **STEP 1: Create MongoDB Atlas Account (2 mins)**

1. Go to: **https://www.mongodb.com/cloud/atlas**
2. Click **"Sign Up Free"**
3. Fill in email, password, name
4. Check email verify link
5. Login

---

### **STEP 2: Create Your Cluster (1 min)**

1. After login, click **"+ Create"** button
2. Select **"M0 Shared"** (Free tier)
3. Choose any cloud provider (AWS recommended)
4. Choose region closest to you
5. Click **"Create Deployment"**
⏳ Wait 1-2 minutes...

---

### **STEP 3: Create Database User (1 min)**

While cluster is being created:

1. Left sidebar → **"Security"** → **"Database Access"**
2. Click **"+ Add New Database User"**
3. Enter:
   - **Username**: `swiftnest_user`
   - **Password**: Click "Generate Secure Password" (copy it!)
   - Leave database: "Admin Database"
4. Click **"Add User"**

**⚠️ SAVE YOUR PASSWORD! You'll need it in 1 minute**

---

### **STEP 4: Whitelist Your IP (30 seconds)**

1. Left sidebar → **"Security"** → **"Network Access"**
2. Click **"+ Add IP Address"**
3. Click **"Allow Access from Anywhere"** (green button, for development only)
4. Click **"Confirm"**

---

### **STEP 5: Get Connection String (30 seconds)**

1. Left sidebar → **"Deployment"** → **"Database"**
2. Click **"Connect"** button
3. Choose **"Drivers"**
4. Select **"Node.js"**
5. **COPY** the connection string shown

It looks like:
```
mongodb+srv://<USERNAME>:<PASSWORD>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

---

### **STEP 6: Update Your .env File (1 min)**

1. Open file: `backend\.env`

2. Find this line:
```
MONGODB_URI=mongodb://localhost:27017/swiftnest
```

3. **Replace it with** your connection string from Step 5:
```
MONGODB_URI=mongodb+srv://swiftnest_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/swiftnest?retryWrites=true&w=majority
```

**Replace the password with your actual password from Step 3**

Example:
```
MONGODB_URI=mongodb+srv://swiftnest_user:myPassword123@cluster0.a1b2c3d.mongodb.net/swiftnest?retryWrites=true&w=majority
```

**⚠️ Keep everything else in .env the same!**

---

### **STEP 7: Start Redis (1 min)**

Open PowerShell in `backend` folder:

```powershell
docker-compose up -d redis
```

Output should show:
```
✅ redis  Created
✅ redis  Started
```

---

### **STEP 8: Start Your Backend (1 min)**

Still in PowerShell:

```powershell
npm run start:dev
```

**You should see**:
```
🚀 SwiftNest server running on port 3000
```

✅ **YOU'RE DONE!**

---

## ✅ Test It Works

Open new PowerShell window:

```powershell
curl -X POST http://localhost:3000/auth/signup `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"test@example.com","password":"password123","name":"Test User"}'
```

You should get back a response with `accessToken` ✅

---

## 🔍 Verify Data in MongoDB Atlas

1. Go to: https://cloud.mongodb.com
2. Click your cluster
3. Click **"Collections"**
4. You should see:
   - Database: `swiftnest` ✅
   - Collection: `users` ✅
   - Your test user inside! ✅

---

## 🆘 Common Issues

### **"Cannot connect to MongoDB"**
- ❌ Connection string is wrong
  - ✅ Copy it again from MongoDB Atlas "Connect" button
- ❌ Password has special characters not URL-encoded
  - ✅ Use password from "Generate Secure Password" button (it's already safe)
- ❌ IP not whitelisted
  - ✅ Go to Network Access, add "Allow from Anywhere"

### **"Cannot find module"**
```powershell
cd backend
npm install
```

### **Port 3000 already in use**
Edit `backend/.env`:
```
PORT=3001
```

---

## 📐 Your Final .env Should Look Like

```env
NODE_ENV=development
PORT=3000
APP_NAME=SwiftNest
APP_URL=http://localhost:3000

MONGODB_URI=mongodb+srv://swiftnest_user:PASSWORD@cluster0.xxxxx.mongodb.net/swiftnest?retryWrites=true&w=majority
MONGODB_HOST=localhost
MONGODB_PORT=27017
MONGODB_NAME=swiftnest

REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION=1800
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-this
JWT_REFRESH_EXPIRATION=2592000

BCRYPT_ROUNDS=12
OTP_EXPIRATION=300
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX_REQUESTS=100

LOG_LEVEL=debug
LOG_FILE=logs/app.log
LOG_MAX_SIZE=10m
LOG_MAX_FILES=14

CORS_ORIGIN=http://localhost:8081,http://localhost:3000

AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=swiftnest-media

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=noreply@swiftnest.com
```

---

## 🎉 You're Ready!

```
✅ MongoDB Atlas connected
✅ Redis running locally
✅ Backend on http://localhost:3000
✅ Ready to test API
✅ Ready for Flutter frontend
```

---

**Time: 5 minutes**  
**Difficulty: Easy**  
**Status: ✅ Complete**

Need more details? See: `MONGODB_ATLAS_REDIS_SETUP.md`
