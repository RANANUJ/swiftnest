@echo off
REM MongoDB Atlas + Redis Quick Setup Script
REM This script helps you configure MongoDB Atlas and Redis

setlocal enabledelayedexpansion

echo.
echo ===============================================
echo SwiftNest MongoDB Atlas + Redis Setup
echo ===============================================
echo.

echo Step 1: MongoDB Atlas Setup
echo.
echo 1. Go to: https://www.mongodb.com/cloud/atlas
echo 2. Sign up (free)
echo 3. Create a Shared Cluster
echo 4. Create Database User:
echo    - Username: swiftnest_user
echo    - Password: (generate and save it!)
echo 5. Whitelist your IP (Allow from Anywhere for now)
echo 6. Get Connection String from "Connect" button
echo.
pause

echo Step 2: Update .env file
echo.
echo Open: backend\.env
echo.
echo Find this line:
echo   MONGODB_URI=mongodb://localhost:27017/swiftnest
echo.
echo Replace with your MongoDB Atlas connection string:
echo   MONGODB_URI=mongodb+srv://swiftnest_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/swiftnest?retryWrites=true^&w=majority
echo.
pause

echo Step 3: Start Redis (Docker)
echo.
echo Running: docker-compose up -d redis
echo.

cd backend

REM Check if docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker not installed!
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Start Redis
docker-compose up -d redis

if %errorlevel% neq 0 (
    echo ERROR: Failed to start Redis
    pause
    exit /b 1
)

echo.
echo ✅ Redis started!
echo.

echo Step 4: Install dependencies
echo.
echo Running: npm install
npm install

if %errorlevel% neq 0 (
    echo ERROR: npm install failed
    pause
    exit /b 1
)

echo.
echo ✅ Dependencies installed!
echo.

echo Step 5: Test connection
echo.
echo Running: npm run start:dev
echo.
echo Wait for this message:
echo   🚀 SwiftNest server running on port 3000
echo.
pause

npm run start:dev

echo.
echo ===============================================
echo Setup Complete!
echo ===============================================
echo.
echo ✅ MongoDB Atlas connected
echo ✅ Redis running on localhost:6379
echo ✅ Backend running on http://localhost:3000
echo.
echo Next: Test the API with:
echo   curl -X POST http://localhost:3000/auth/signup \
echo     -H "Content-Type: application/json" \
echo     -d "{"email":"test@example.com","password":"password123","name":"Test"}"
echo.

pause
