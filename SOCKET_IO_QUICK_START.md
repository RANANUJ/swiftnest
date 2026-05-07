# 🚀 Socket.IO Quick Start - Sequential Setup

**This guide helps you set up Socket.IO step-by-step in your SwiftNest backend.**

---

## ⚡ 5-Minute Overview

```
Your Flutter App (Client)
    ↓ (WebSocket Connection)
NestJS + Socket.IO (Server)
    ↓
┌─────────────────────────────────────┐
│  Real-Time Features Enabled         │
├─────────────────────────────────────┤
│ ✅ Live Messages                    │
│ ✅ Typing Indicators                │
│ ✅ Read Receipts                    │
│ ✅ User Online/Offline Status       │
│ ✅ Instant Notifications            │
└─────────────────────────────────────┘
```

---

## 📍 Where Socket.IO Is Used in SwiftNest

### 1. **Real-Time Messaging** ⭐ MAIN USE CASE
User sends message → Instantly appears in recipient's chat

### 2. **Typing Indicators**
User A types → User B sees "User A is typing..."

### 3. **Read Receipts**
User B reads message → User A sees "Read at 2:30 PM"

### 4. **Online Status**
User comes online → Friends see "Online" badge

### 5. **Push Notifications**
Event happens → User gets notification via Socket.IO

---

## 🔧 Sequential Setup Steps

### **STEP 1: Install Dependencies** (2 min)
```bash
cd backend
npm install socket.io @nestjs/websockets @nestjs/platform-socket.io socket.io-redis socket.io-redis-adapter
```

**Verify installation:**
```bash
npm list socket.io
npm list @nestjs/websockets
```

---

### **STEP 2: Create Folder Structure** (2 min)

In `backend/src/`, create these folders:

```
websocket/
├── websocket.gateway.ts          ← Main file (handles all events)
├── websocket.module.ts           ← Register module
├── guards/
│   └── websocket-auth.guard.ts   ← JWT verification
├── decorators/
│   └── socket-user.decorator.ts  ← Get user from socket
└── events/
    ├── chat.events.ts
    ├── presence.events.ts
    └── notification.events.ts

chat/
├── chat.service.ts               ← Message logic
├── chat.module.ts
└── schemas/
    └── message.schema.ts         ← Message model
```

**Command to create folders:**
```bash
# Windows PowerShell
mkdir backend/src/websocket/guards
mkdir backend/src/websocket/decorators
mkdir backend/src/websocket/events
mkdir backend/src/chat/schemas
```

---

### **STEP 3: Copy Code Files** (10 min)

See full implementation in [SOCKET_IO_SETUP.md](SOCKET_IO_SETUP.md)

**Key files to create (in order):**

1. ✅ `src/websocket/guards/websocket-auth.guard.ts` - JWT verification
2. ✅ `src/websocket/decorators/socket-user.decorator.ts` - User extraction
3. ✅ `src/websocket/websocket.gateway.ts` - Main gateway (all events)
4. ✅ `src/websocket/websocket.module.ts` - Module definition
5. ✅ `src/chat/schemas/message.schema.ts` - Message model
6. ✅ `src/chat/chat.service.ts` - Message operations
7. ✅ `src/app.module.ts` - Import WebSocketModule

---

### **STEP 4: Update Configuration** (1 min)

Add to `.env`:

```env
SOCKET_IO_ENABLED=true
SOCKET_IO_PORT=3001
SOCKET_IO_NAMESPACE=/chat
SOCKET_IO_CORS_ORIGIN=http://localhost:3000
```

---

### **STEP 5: Start Backend** (1 min)

```bash
npm run start:dev
```

**Expected output:**
```
🚀 SwiftNest server running on port 3000
🔌 WebSocket server running on port 3001/chat
```

---

## 🧪 Test Socket.IO

### Using JavaScript (in browser console or Node):

```javascript
// 1. Install socket.io-client first
// In Flutter, install: socket_io_client package

// 2. Connect
const io = require('socket.io-client');
const socket = io('http://localhost:3000/chat', {
  auth: { authorization: 'Bearer YOUR_JWT_TOKEN' },
});

// 3. Listen for connection
socket.on('connect', () => {
  console.log('✅ Connected!');

  // 4. Join chat room
  socket.emit('chat:join', { chatId: 'chat-123' });

  // 5. Send message
  socket.emit('message:send', {
    chatId: 'chat-123',
    text: 'Hello World!',
  });
});

// 6. Receive messages
socket.on('message:receive', (data) => {
  console.log('📩 Message:', data);
});

// 7. Listen for typing
socket.on('chat:typing:update', (data) => {
  console.log(`${data.userName} is typing...`);
});

// 8. Online status
socket.on('user:online', (data) => {
  console.log(`${data.userId} is online`);
});
```

---

## 📊 Event Flow Diagram

```
Flutter Client                Backend (NestJS)           Database
    │                              │                        │
    ├─── socket.connect ────────→  │                        │
    │                        (verify JWT)                    │
    │                              │                        │
    ├─ chat:join ─────────────────→ │                        │
    │                         (join room)                    │
    │                              │                        │
    ├─ message:send ──────────────→ │                        │
    │                              ├─── save message ──────→ │
    │                              │                        │
    │  ← message:receive ─────────  ├─ broadcast to room     │
    │   (to all users in room)      │                        │
    │                              │                        │
    ├─ chat:typing ───────────────→ │                        │
    │                              ├─ chat:typing:update    │
    │  ← chat:typing:update ──────  │  (to room)             │
    │                              │                        │
    ├─ message:read ──────────────→ │                        │
    │                              ├─ update readBy ──────→  │
    │  ← message:read:update ────── │  (broadcast to room)   │
    │                              │                        │
    ├─── socket.disconnect ──────→ │                        │
    │                         (broadcast offline)           │
    │                              │                        │
```

---

## 🎯 Event Reference

| Event | Direction | Purpose | Data |
|-------|-----------|---------|------|
| `chat:join` | C → S | Join chat | `{ chatId }` |
| `message:send` | C → S | Send message | `{ chatId, text, mediaUrl? }` |
| `message:receive` | S → C | Receive message | `{ messageId, senderId, text, timestamp }` |
| `chat:typing` | C → S | User typing | `{ chatId }` |
| `chat:typing:update` | S → C | Show typing indicator | `{ userId, userName, chatId }` |
| `message:read` | C → S | Mark as read | `{ messageId, chatId }` |
| `message:read:update` | S → C | Update read status | `{ messageId, readBy, readAt }` |
| `user:online` | S → C | User online | `{ userId, timestamp }` |
| `user:offline` | S → C | User offline | `{ userId, timestamp }` |
| `notification:new` | S → C | New notification | `{ title, message, type }` |

---

## 🚀 What Happens After Setup

### Connection Flow:
1. **Flutter opens app** → Connects to Socket.IO with JWT token
2. **Server verifies token** → Joins user's personal notification room
3. **User opens chat** → `chat:join` event → Joins specific chat room
4. **User sends message** → `message:send` event → Saved to MongoDB → Broadcasted to room
5. **Other users receive** → `message:receive` event → UI updates instantly
6. **User closes app** → `disconnect` event → `user:offline` broadcasted

---

## ✅ Checklist

After following this guide:

- [ ] Installed Socket.IO packages
- [ ] Created websocket folder structure
- [ ] Created websocket.gateway.ts
- [ ] Created websocket.module.ts
- [ ] Created chat service & message schema
- [ ] Updated app.module.ts to import WebSocketModule
- [ ] Added Socket.IO config to .env
- [ ] Backend starts without errors
- [ ] Can connect from test client
- [ ] Messages appear in real-time

---

## 🔧 Troubleshooting

**Issue**: "Cannot find module 'socket.io'"
```bash
npm install socket.io @nestjs/websockets @nestjs/platform-socket.io
```

**Issue**: "CORS error on Socket.IO"
```env
SOCKET_IO_CORS_ORIGIN=http://localhost:3000,http://localhost:8080
```

**Issue**: "WebSocket handshake failed"
→ Check JWT token is valid  
→ Check CORS_ORIGIN matches your client  
→ Check port 3001 is not blocked

---

## 📚 See Also

- Full implementation: [SOCKET_IO_SETUP.md](SOCKET_IO_SETUP.md)
- Testing guide: [END_TO_END_TESTING_GUIDE.md](END_TO_END_TESTING_GUIDE.md)
- Backend setup: [BACKEND_SETUP.md](backend/BACKEND_SETUP.md)

---

**Next Step**: Start implementing the files from Step 3  
**Questions?** Check SOCKET_IO_SETUP.md for full code samples  
**Ready to code?** Open SOCKET_IO_SETUP.md and follow Step 3

**SwiftNest** | Stage 5 🚀 | Socket.IO Ready
