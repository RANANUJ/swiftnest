# SwiftNest - System Architecture Flows

## 1. App Startup Flow (Local-First)

```
┌─────────────────────────────────────────────────────────────────┐
│ USER OPENS APP                                                  │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ LOAD CHAT LIST FROM SQLite/Drift (INSTANTLY)                    │
│ - Recent chats                                                  │
│ - Last messages                                                 │
│ - Unread counts                                                 │
│ - Cached avatars                                                │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ RENDER CHAT LIST TO USER                                        │
│ ⏱ Timeline: < 500ms (faster than Telegram!)                     │
│ ✅ App feels responsive immediately                             │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼ (Background/Async)
┌─────────────────────────────────────────────────────────────────┐
│ CONNECT TO SOCKET.IO SERVER                                     │
│ - Establish WebSocket connection                                │
│ - Authenticate with JWT token                                   │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ FETCH ONLY MISSING UPDATES FROM MONGODB                         │
│ - Query: messages after lastSyncTime                            │
│ - Only new messages, not full history                           │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ PATCH CHANGED ROWS IN LOCAL DATABASE                            │
│ - Update only affected chats                                    │
│ - Don't redraw entire list                                      │
│ - Use efficient row-level updates                               │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ REBUILD ONLY CHANGED LIST ITEMS                                 │
│ ✅ User sees fresh data, no loading spinner                     │
└─────────────────────────────────────────────────────────────────┘

KEY: Never make user wait for network before showing local data
```

---

## 2. Open Conversation Flow

```
┌──────────────────────────────────────────────────────────────────┐
│ USER TAPS ON CHAT                                                │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ LOAD LAST 50 MESSAGES FROM SQLite (INSTANTLY)                    │
│ - Recent message history                                         │
│ - Already available locally                                      │
│ - Cached media URLs                                              │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ DISPLAY CONVERSATION                                             │
│ ⏱ Timeline: < 300ms (feels instant!)                             │
│ ✅ User can read old messages while new sync happens            │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼ (Background)
┌──────────────────────────────────────────────────────────────────┐
│ FETCH NEW MESSAGES FROM SERVER (Socket.IO)                       │
│ - Messages after last loaded timestamp                           │
│ - Silently append to bottom                                      │
│ - Update status indicators                                       │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ PAGINATION: USER SCROLLS UP FOR OLDER MESSAGES                   │
│ - Cursor pagination: load next 50 messages before this batch     │
│ - Only load on demand (don't load all 10,000 at once)            │
│ - Prevents memory bloat                                          │
└──────────────────────────────────────────────────────────────────┘

KEY: Never load full message history; use cursor pagination
```

---

## 3. Send Message Flow (Optimistic UI)

```
┌──────────────────────────────────────────────────────────────────┐
│ USER TYPES MESSAGE AND TAPS SEND                                 │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ SAVE MESSAGE LOCALLY WITH TEMP ID (UUID)                         │
│ - Status: PENDING                                                │
│ - Store in SQLite + pending queue                                │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ DISPLAY IN UI IMMEDIATELY                                        │
│ ⏱ Timeline: < 100ms (user sees "sent" instantly!)                │
│ ✅ Message appears in chat while network request is in-flight    │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼ (Background)
┌──────────────────────────────────────────────────────────────────┐
│ SEND TO SERVER VIA SOCKET.IO                                     │
│ - Include temp ID for tracking                                   │
│ - Fast network handoff                                           │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ RECEIVE AND STORE SERVER MESSAGE ID                              │
│ - Replace temp ID with real MongoDB ID                           │
│ - Update local database                                          │
│ - Set status: SENT                                               │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ ON DELIVERY                                                      │
│ - Update status: DELIVERED                                       │
│ - Refresh UI (just status icon)                                  │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ ON READ BY RECIPIENT                                             │
│ - Update status: SEEN                                            │
│ - Show "read at" timestamp                                       │
└──────────────────────────────────────────────────────────────────┘

KEY: Don't wait for server; show message instantly to keep UX snappy
```

---

## 4. Media Loading Flow (Thumbnail-First)

```
┌──────────────────────────────────────────────────────────────────┐
│ USER OPENS CHAT WITH IMAGE/VIDEO MESSAGE                         │
└────────────────┬─────────────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ CHECK LOCAL FILE CACHE                                           │
│ - Is this media already downloaded?                              │
└────────────┬──────────────────────────────────────────────────────┘
             │
        YES  │  NO
             │   │
        ┌────▼┐┌─▼──────────────────────────────────────────────────┐
        │     ││ DISPLAY CACHED THUMBNAIL (50KB)                     │
        │     │└────────────┬───────────────────────────────────────┘
        │     │             │
        │     │             ▼
        │     │ ┌──────────────────────────────────────────────────┐
        │     │ │ ⏱ Timeline: < 200ms (from cache)                 │
        │     │ │ ✅ User sees preview immediately                 │
        │     │ └────────────┬─────────────────────────────────────┘
        │     │              │
        │     │              ▼ (Background)
        │     │ ┌──────────────────────────────────────────────────┐
        │     │ │ FETCH FULL RESOLUTION FROM S3                    │
        │     │ │ - Resumable download (HTTP range requests)        │
        │     │ │ - Save to local cache                             │
        │     │ │ - Stream if user doesn't want to download         │
        │     │ └────────────┬─────────────────────────────────────┘
        │     │              │
        │     │              ▼
        │     │ ┌──────────────────────────────────────────────────┐
        │     │ │ REPLACE THUMBNAIL WITH FULL IMAGE                │
        │     │ │ ✅ Smooth fade transition                         │
        │     │ └──────────────────────────────────────────────────┘
        │     │
        │     └─────────────────┬──────────────────────────────────┐
        │                       │                                  │
        └──────────────────────►▼────────────────────────────────┐
                     ┌─────────────────────────────────────┐     │
                     │ OPEN LOCAL FILE IMMEDIATELY         │     │
                     │ No network call needed              │     │
                     │ ⏱ < 100ms (extremely fast)          │     │
                     │ ✅ Works offline!                    │     │
                     └─────────────────────────────────────┘◄────┘

KEY BENEFITS:
- Quick preview (thumbnail from cache)
- Full resolution in background
- Offline access to downloaded media
- Smooth transitions
```

---

## 5. Offline & Reconnect Flow

```
┌───────────────────────────────────────────────────────────────────┐
│ NETWORK DISCONNECTS                                               │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌───────────────────────────────────────────────────────────────────┐
│ APP CONTINUES NORMALLY                                            │
│ - Read old messages from SQLite                                   │
│ - Open downloaded media from local storage                        │
│ - Typing still works (shown as 🕐 pending)                        │
│ - No spinner, no "no connection" message (unless essential)       │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌───────────────────────────────────────────────────────────────────┐
│ USER TAPS SEND (While Offline)                                    │
│ - Save message to PENDING QUEUE with temp ID                      │
│ - Mark as "sending..." in UI                                      │
│ - Keep in queue even after app restart                            │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌───────────────────────────────────────────────────────────────────┐
│ NETWORK RECONNECTS                                                │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌───────────────────────────────────────────────────────────────────┐
│ AUTO-SYNC PENDING MESSAGES                                        │
│ - Send all queued messages to server                              │
│ - Retry failed messages (with exponential backoff)                │
│ - Delete from queue after server confirms                         │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌───────────────────────────────────────────────────────────────────┐
│ FETCH MISSED MESSAGES FROM SERVER                                 │
│ - Query: messages after lastSyncTime                              │
│ - Insert into local database                                      │
│ - Refresh UI                                                      │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 ▼
┌───────────────────────────────────────────────────────────────────┐
│ SYNC COMPLETE                                                     │
│ ⏱ Timeline: < 2 seconds (only missed messages)                    │
│ ✅ User sees all new messages and their messages confirmed        │
└───────────────────────────────────────────────────────────────────┘

KEY: App graceful degrades offline and recovers quickly online
```

---

## 6. Database Schema (SQLite/Drift Local)

```
┌─────────────────────────────────────────────────────────┐
│ LOCAL DATABASE SCHEMA (SQLite/Drift)                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ✅ Table: chats                                         │
│    - id (PK)                                            │
│    - type (ONE_TO_ONE, GROUP)                           │
│    - members (JSON array)                               │
│    - lastMessage (TEXT)                                 │
│    - unreadCount (INT) [Index]                          │
│    - updatedAt (DateTime) [Index]                       │
│ ✅ Table: messages                                      │
│    - id (PK, server-provided)                           │
│    - tempId (STRING, for offline)                       │
│    - chatId (FK) [Index]                                │
│    - senderId (FK)                                      │
│    - type (TEXT, VIDEO, IMAGE, VOICE, FILE)            │
│    - text (STRING, optional)                            │
│    - mediaUrl (STRING, optional)                        │
│    - thumbUrl (STRING, optional)                        │
│    - status (PENDING, SENDING, SENT, DELIVERED, SEEN)   │
│    - createdAt (DateTime) [Index]                       │
│    - deletedAt (DateTime, soft delete)                  │
│ ✅ Table: pending_messages                              │
│    - id (PK, local UUID)                                │
│    - chatId (FK)                                        │
│    - localPath (STRING)                                 │
│    - payload (JSON)                                     │
│    - retryCount (INT)                                   │
│    - createdAt (DateTime)                               │
│ ✅ Table: downloaded_media                              │
│    - id (PK)                                            │
│    - messageId (FK, unique)                             │
│    - localPath (STRING)                                 │
│    - mimeType (STRING)                                  │
│    - size (INT)                                         │
│    - downloadedAt (DateTime)                            │
│ ✅ Table: users (cached)                                │
│    - id (PK)                                            │
│    - name (STRING)                                      │
│    - avatar (STRING)                                    │
│    - bio (STRING)                                       │
│    - updatedAt (DateTime)                               │
│ ✅ Table: sync_metadata                                 │
│    - key (STRING, PK) = "last_sync_time"                │
│    - value (STRING) = ISO datetime                      │
│                                                         │
└─────────────────────────────────────────────────────────┘

Optimized Indexes:
- chats(updatedAt DESC, unreadCount)
- messages(chatId, createdAt DESC)
- pending_messages(chatId, retryCount)
- downloaded_media(messageId)
```

---

## 7. Backend API Responsibilities

```
┌─────────────────────────────────────────────────────────────────┐
│ BACKEND (NestJS + MongoDB + Redis)                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 🔐 Authentication                                               │
│    POST /auth/signup       → Create user + issue tokens         │
│    POST /auth/login        → Verify credentials + tokens        │
│    POST /auth/refresh      → Rotate refresh token               │
│    POST /auth/verify-otp   → OTP verification                   │
│    POST /auth/logout       → Invalidate session                 │
│                                                                 │
│ 👤 User Profile                                                 │
│    GET  /users/:id         → Fetch user profile                 │
│    PUT  /users/:id         → Update profile                     │
│    POST /users/:id/avatar  → Upload avatar (signed URL)         │
│    GET  /users/status      → Get online/offline status (Redis)  │
│                                                                 │
│ 💬 Messages                                                     │
│    GET  /chats/:id/messages?after=timestamp&limit=50            │
│           → Fetch only NEW messages (cursor pagination)         │
│    POST /chats/:id/message                                      │
│           → Store message in MongoDB                            │
│    PUT  /messages/:id      → Edit message                       │
│    DELETE /messages/:id    → Soft delete message                │
│    DELETE /messages/:id?hard=true  → Hard delete from all       │
│                                                                 │
│ 📁 Media                                                        │
│    POST /media/upload-signature                                 │
│           → Return S3 pre-signed URL + upload ID                │
│    POST /media/:id/confirm                                      │
│           → Mark upload complete, generate thumbnail            │
│    GET  /media/:id/url?download=false                           │
│           → Return temporary signed download URL (expires 1h)   │
│                                                                 │
│ 🔔 Real-Time (Socket.IO)                                       │
│    socket.on('message')       → Receive + broadcast             │
│    socket.on('typing')        → Broadcast typing status         │
│    socket.on('read')          → Mark message as read            │
│    socket.on('connect')       → Update presence in Redis        │
│    socket.on('disconnect')    → Remove from Redis presence      │
│                                                                 │
│ 📊 Sync & History                                               │
│    GET  /sync?after=timestamp                                   │
│           → Return only messages/updates after given time       │
│           → Used for reconnect sync (not full history)          │
│                                                                 │
│ 🛡️ Security                                                     │
│    Rate limit: 5 login/min, 3 OTP/hour, 100 msg/min             │
│    Validate file type, size, user permission                    │
│    Check if sender has access to chat before storing message    │
│    Generate audit logs for sensitive actions                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Security Layers

```
┌────────────────────────────────────────────────────────┐
│ AUTHENTICATION LAYER                                   │
├────────────────────────────────────────────────────────┤
│                                                        │
│ Signup/Login                                           │
│ ├─ Verify email/phone via OTP                          │
│ ├─ Hash password with bcrypt (salt rounds: 12)         │
│ └─ Generate JWT + refresh token                        │
│                                                        │
│ JWT Tokens                                             │
│ ├─ Access Token (15-30 min)                            │
│ │  ├─ Issued on: signup, login, refresh                │
│ │  └─ Stored in: secure_storage                        │
│ ├─ Refresh Token (30 days)                             │
│ │  ├─ Device-bound (includes device ID)                │
│ │  ├─ Hash stored in Redis cache                       │
│ │  └─ Rotated on use (new refresh on refresh)          │
│ └─ Session invalidation on logout/password change      │
│                                                        │
│ Device Sessions                                        │
│ ├─ Track device ID, IP, last seen                      │
│ ├─ Allow user to revoke old sessions                   │
│ └─ Prevent concurrent logins on same device            │
│                                                        │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ TRANSPORT SECURITY LAYER                               │
├────────────────────────────────────────────────────────┤
│                                                        │
│ APIs: HTTPS/TLS (encrypt in transit)                   │
│ Socket.IO: WSS (WebSocket Secure)                      │
│ All tokens sent in Authorization header, not cookies   │
│ CSRF protection on form submissions                    │
│                                                        │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ MEDIA & FILE SECURITY LAYER                            │
├────────────────────────────────────────────────────────┤
│                                                        │
│ Upload                                                 │
│ ├─ Get signed URL from backend (JWT verified)          │
│ ├─ Server generates pre-signed S3 URL                  │
│ ├─ Validate file type (image, video, audio, doc)       │
│ ├─ Validate file size (image: <5MB, video: <50MB)      │
│ ├─ Check sender permission (owns chat)                 │
│ └─ Mark upload complete to generate thumbnail          │
│                                                        │
│ Download                                               │
│ ├─ Never expose permanent public URLs                  │
│ ├─ Generate signed/temporary URLs (expires 1 hour)     │
│ ├─ Verify user is chat member before serving           │
│ └─ Log access for audit trail                          │
│                                                        │
│ Storage                                                │
│ ├─ Store in S3 with encryption at rest                 │
│ ├─ Use bucket policies to prevent public exposure      │
│ └─ Archive old media after 90 days                     │
│                                                        │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ APPLICATION LOGIC SECURITY LAYER                       │
├────────────────────────────────────────────────────────┤
│                                                        │
│ Rate Limiting (DDoS prevention)                        │
│ ├─ Login: 5 attempts/min per IP                        │
│ ├─ OTP: 3 requests/hour per user                       │
│ ├─ Messages: 100 messages/min per user                 │
│ ├─ Uploads: 10 uploads/min per user                    │
│ └─ API: 1000 requests/min per user                     │
│                                                        │
│ Input Validation                                       │
│ ├─ Sanitize text messages (XSS prevention)             │
│ ├─ Validate file MIME types                            │
│ ├─ Check message length < 5000 chars                   │
│ └─ Validate user IDs and chat permissions              │
│                                                        │
│ Database Security                                      │
│ ├─ Use parameterized queries (prevent SQL injection)   │
│ ├─ Index sensitive fields for fast lookups             │
│ ├─ Encrypt PII fields (optional: user avatars)         │
│ └─ Regular backups + audit logs                        │
│                                                        │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│ MODERATION & PRIVACY LAYER                             │
├────────────────────────────────────────────────────────┤
│                                                        │
│ Content Moderation                                     │
│ ├─ Report message/user endpoint                        │
│ ├─ Admin review reported content                       │
│ ├─ Soft delete if violates policy                      │
│ └─ Notify user if action taken                         │
│                                                        │
│ User Privacy                                           │
│ ├─ Block users: hidden from searches, can't message    │
│ ├─ Mute chats: don't send notifications                │
│ ├─ Privacy settings: who can message, group adds       │
│ ├─ Data export: user can download all messages/media   │
│ └─ Account deletion: hard delete all user data         │
│                                                        │
│ Audit Logs                                             │
│ ├─ Log all admin actions (delete, ban, etc)            │
│ ├─ Log all security events (failed login, token revoke) │
│ ├─ Log sensitive data access                           │
│ └─ Store for 90 days for compliance                    │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## 9. Performance Optimization Checklist

```
┌──────────────────────────────────────────────────────────┐
│ PERFORMANCE TARGETS                                      │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ ✅ Startup (App Open to Chat List)        Target: < 500ms│
│    - Load SQLite cache               ⏱ 50ms             │
│    - Render UI                       ⏱ 100ms            │
│    - Network sync (background)       ⏱ async            │
│                                                          │
│ ✅ Conversation Open                      Target: < 300ms│
│    - Load 50 recent messages         ⏱ 100ms            │
│    - Render UI                       ⏱ 100ms            │
│    - Fetch newer messages (bg)       ⏱ async            │
│                                                          │
│ ✅ Message Send                           Target: < 100ms│
│    - Save locally                    ⏱ 20ms             │
│    - Show in UI (optimistic)         ⏱ 30ms             │
│    - Send to server (async)          ⏱ background       │
│                                                          │
│ ✅ Media Thumbnail Load                   Target: < 200ms│
│    - Load from memory cache          ⏱ < 10ms           │
│    - Load from file cache            ⏱ 50-100ms         │
│                                                          │
│ ✅ Offline Sync on Reconnect              Target: < 2s   │
│    - Auto-sync pending messages      ⏱ 500ms            │
│    - Fetch missed messages           ⏱ 1000ms           │
│    - Update UI                       ⏱ 500ms            │
│                                                          │
│ ✅ App Size                               Target: < 80MB │
│    - APK/IPA uncompressed size       ⏱ measure          │
│    - Avoid large assets in bundle    ⏱ use lazy loading │
│                                                          │
└──────────────────────────────────────────────────────────┘

OPTIMIZATION TECHNIQUES:
- Use ListView.builder (not ListView) - only render visible items
- Implement IndexedStack for screen transitions (no rebuild)
- Use const constructors everywhere possible
- Offload heavy work to Isolates (background threads)
- Compress images before upload (50KB thumbnail, 2-5MB full)
- Use Hive or shared_preferences for small local data
- Profile with DevTools Profiler regularly
- Monitor frame rate with DevTools (aim for 60fps)
```

---

## Summary: Why This Architecture Is Fast

| Principle | Result |
|-----------|--------|
| **Local-First** | Chat list appears instantly, never wait for network |
| **Sync-Smart** | Only fetch new messages, not full history on reconnect |
| **Optimistic UI** | Messages appear instantly, confirmed asynchronously |
| **Thumbnail-First** | Quick preview while full resolution loads |
| **Cursor Pagination** | Load 50, expand on demand (not all 10K) |
| **Background Tasks** | Heavy work doesn't block UI responsiveness |
| **Efficient Caching** | Multiple cache layers (memory, SQLite, file) |
| **Resumable Transfers** | Large uploads/downloads don't restart on interruption |

**Result: Feels as fast as Telegram** ⚡
