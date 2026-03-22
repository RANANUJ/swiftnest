# SwiftNest - Architecture & Development Blueprint

## Executive Summary
**Current State:** Hello World Flutter app (Day 0)  
**Target:** Telegram-like high-performance chat app with offline-first architecture  
**Timeline:** 13 development stages  
**Core Principle:** Local-first, sync-smart, never block UI on network

---

## 1. PRODUCT VISION & CORE EXPERIENCE GOALS

### Must-Have User Experiences
| Goal | Expected Behavior |
|------|-------------------|
| **Startup Speed** | Chat list appears instantly from SQLite cache, before API responds |
| **Conversation Speed** | Old messages load instantly from local DB; new sync happens silently |
| **Media Speed** | Thumbnails display first; full resolution loads in background |
| **Offline Support** | Read old chats and view downloaded media without internet |
| **Smoothness** | Fluid scrolling, transitions, typing indicators, no jank |
| **Security** | JWT + refresh tokens, HTTPS, signed media URLs, rate limiting |

---

## 2. RECOMMENDED TECHNOLOGY STACK

### Frontend (Flutter)
```
├── UI Framework: Flutter 3.8+
├── State Management: Riverpod (recommended) or Bloc
├── Local Database: Drift (Dart SQLite wrapper) for reliability
├── Networking: Dio (HTTP client) for resumable upload/download
├── Real-time: Socket.IO client for instant messages
├── Media: Flutter native plugins for image/video handling
├── Notifications: Firebase Cloud Messaging (FCM)
├── Security: flutter_secure_storage for tokens
└── UI Components: Provider, GetX (optional for routing)
```

### Backend (Node.js + NestJS)
```
├── Framework: NestJS (TypeScript, modular, production-ready)
├── Database: MongoDB (flexible, scalable)
├── Cache/Presence: Redis (fast, pub/sub for real-time)
├── Real-time Transport: Socket.IO
├── File Storage: S3/R2/MinIO (scalable media storage)
├── Authentication: JWT + Refresh token rotation
└── Monitoring: Logging, error tracking, performance metrics
```

### Infrastructure
```
├── Database: MongoDB Atlas or self-hosted
├── Cache: Redis Cloud or self-hosted
├── Media Storage: AWS S3, Cloudflare R2, or MinIO
├── Notifications: Firebase Cloud Messaging
└── Deployment: Docker + Kubernetes or VPS
```

---

## 3. ARCHITECTURE PRINCIPLE: LOCAL-FIRST & CACHE-FIRST

### Data Flow On App Startup
```
1. App opens
   ↓
2. Load chat list from SQLite/Drift instantly
   ↓
3. Display: Recent chats, last messages, unread counts, cached avatars
   ↓
4. Connect to Socket.IO server in background
   ↓
5. Fetch only NEW/MISSING messages from server
   ↓
6. Patch changed rows only (don't redraw entire list)
   ↓
7. User never sees loading spinner for chat list
```

### Why This Works
- **Instant visual feedback** (psychological speed)
- **Network happens in background** (true speed)
- **Works offline** for previously loaded data
- **Reduces server load** (only sync missing, not full histories)

---

## 4. CORE APP MODULES

### Module: Authentication
- Signup with email/phone + OTP verification
- Login with secure token storage
- JWT access tokens + refresh tokens
- Device session management
- Password reset flow
- Biometric unlock (for sensitive chats)

### Module: User Profile
- Profile photo upload with compression
- Bio, username, privacy settings
- Online/offline status (via Redis)
- Blocked users list
- Device session history

### Module: One-to-One Chat
- Real-time text messaging
- Message states: sending → sent → delivered → seen
- Reply/forward/delete/edit operations
- Typing indicators
- Read receipts
- Drafts (local storage)

### Module: Group Chat
- Create/manage groups
- Admin roles and permissions
- Member list and invite links
- Announcements and pinned messages
- Mute/unmute notifications
- Shared media library

### Module: Media
- Image, video, voice note, file upload
- Thumbnail generation on server
- Resumable upload (if interrupted, continue from byte offset)
- Resumable download
- Preview caching
- Compression based on network quality

### Module: Offline Engine
- Local message cache (SQLite/Drift)
- Pending message queue with temp IDs
- Auto-sync when connection returns
- Offline media access
- Draft preservation across app restart

### Module: Notification System
- Firebase Cloud Messaging integration
- Chat badge updates
- Mention/reply alerts
- Customizable notification settings
- Silent mode support

### Module: Security & Moderation
- Rate limiting (login, OTP, message endpoints)
- Content reporting workflow
- User blocking and muting
- Signed/temporary media URLs
- File type and size validation
- Audit logs for admin actions

---

## 5. CRITICAL DATA MODELS

### User
```dart
{
  id: String,
  name: String,
  username: String,
  avatar: String (URL),
  bio: String,
  privacySettings: PrivacyLevel,
  blockedUsers: List<String>,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### Chat
```dart
{
  id: String,
  type: ChatType (ONE_TO_ONE, GROUP),
  members: List<UserId>,
  lastMessage: Message,
  unreadCount: int,
  updatedAt: DateTime,
  isMuted: bool,
  isPinned: bool
}
```

### Message
```dart
{
  id: String,
  chatId: String,
  senderId: String,
  type: MessageType (TEXT, IMAGE, VIDEO, VOICE, FILE),
  text: String?,
  mediaUrl: String?,
  thumbUrl: String?,
  status: MessageStatus (PENDING, SENDING, SENT, DELIVERED, SEEN),
  replyToId: String?,
  createdAt: DateTime,
  editedAt: DateTime?,
  deletedAt: DateTime?
}
```

### PendingMessage (Local)
```dart
{
  tempId: String (UUID),
  chatId: String,
  localPath: String?,
  payload: String,
  retryCount: int,
  createdAt: DateTime
}
```

### DownloadedMedia (Local)
```dart
{
  messageId: String,
  localPath: String,
  mimeType: String,
  size: int,
  downloadedAt: DateTime
}
```

---

## 6. CACHING STRATEGY

| Cache Layer | What | Why |
|------------|------|-----|
| **UI Cache** | Avatars, small previews, thumbnails | Instant rendering, less network |
| **Database Cache** | Recent chats, last messages, unread counts | Fast opening, offline support |
| **File Cache** | Downloaded media | Instant media access offline |
| **Memory Cache** | Active chat items, user state | Fast parsing while app running |
| **Redis (Backend)** | Online status, recent state, temp tokens | Fast presence updates, pub/sub |

---

## 7. SECURITY DESIGN (Built-In from Day 1)

### Authentication
- JWT access tokens (short-lived: 15-30 min)
- Refresh tokens (long-lived: 30 days, rotated on use)
- Tokens stored in secure local storage (NOT shared preferences)
- Device ID bound to token for session validation

### Transport
- HTTPS/TLS for all API calls
- Secure WebSocket (WSS) for Socket.IO

### Media & URLs
- Generate signed/temporary URLs on server
- URLs expire after 1 hour
- Never expose permanent public links
- Validate file type and size on server

### Rate Limiting
- Login attempts: 5 per minute per IP
- OTP requests: 3 per hour per user
- Message sending: 100 per minute per user
- Prevents brute force and bot attacks

### Moderation
- Report abuse workflow
- Block/mute users
- Admin review and action
- Audit logs for all sensitive actions

---

## 8. PERFORMANCE RULES (Make It Feel Fast)

### Startup
- ❌ DON'T wait for API before showing chat list
- ✅ DO load from SQLite, show instantly

### Chat List
- ❌ DON'T redraw entire list on new message
- ✅ DO patch only changed rows

### Conversation
- ❌ DON'T load all 10,000 messages at once
- ✅ DO use cursor pagination: load 50, then load older on scroll-up

### Images
- ❌ DON'T load full 4MB image before display
- ✅ DO show 50KB thumbnail first, load full in background

### Videos
- ❌ DON'T auto-download every video in chat
- ✅ DO show thumbnail + play button, stream/download on tap

### Database
- Create indexes on: `chatId`, `userId`, `createdAt`, `unreadCount`
- Prevents slow queries on large message tables

### Reconnect
- ❌ DON'T sync all messages on reconnect
- ✅ DO sync only messages after `lastSyncTime`

---

## 9. OFFLINE EXPERIENCE REQUIREMENTS

Users should feel productive even without internet:

✅ Read previous text messages from local DB  
✅ Open downloaded photos, videos, files from storage  
✅ See cached thumbnails for non-downloaded media  
✅ Write messages offline → queue locally with temp ID  
✅ Resume uploads/downloads when connection returns  
✅ Keep drafts and pending metadata safe after app restart  

---

## 10. UNIQUE DIFFERENTIATORS

| Feature | Value Add |
|---------|-----------|
| **Smart Low-Data Mode** | Adapt image/video quality to network speed, save mobile data |
| **Private Vault Chats** | Hide sensitive chats behind biometric lock |
| **Resume-Anytime Download** | Continue large downloads after interruption (HTTP range requests) |
| **AI Message Helper** | Smart search, summary, or reply suggestions in long chats |
| **Temporary Rooms** | Create ephemeral group chats for events/interests |
| **Smart Storage Cleaner** | Suggest deletable files while protecting important downloads |

---

## 11. DEVELOPMENT ROADMAP (13 Stages)

### Stage 1: Planning & Requirements ✅ (Current)
- [x] Define feature set
- [x] Create user flows
- [x] Design data model
- [ ] Set up design system

### Stage 2: UI/UX Design
- Design onboarding flows
- Chat list screen
- Conversation screen
- Media viewer
- Settings & dark mode
- Create design tokens

### Stage 3: Backend Foundation
- Set up NestJS project structure
- MongoDB connection
- Redis integration
- Environment management
- Logging framework
- Error handling

### Stage 4: Authentication
- Signup with OTP
- Login with token storage
- Profile creation
- Token refresh mechanism
- Device session management

### Stage 5: Real-Time Text Chat
- One-to-one messaging
- Socket.IO setup
- Message states (pending/sent/delivered/seen)
- Typing indicators
- Read receipts
- Delivery confirmation

### Stage 6: Local Cache & Offline
- SQLite/Drift schema design
- Local message storage
- Pending queue implementation
- Sync on reconnect
- Offline message reading

### Stage 7: Media Pipeline
- Image upload with compression
- Video upload (chunked)
- Voice note recording
- File upload support
- Thumbnail generation
- Resumable upload

### Stage 8: Download Manager
- Resumable download support
- Progress tracking
- Pause/resume UI
- Retry on failure
- Local media indexing

### Stage 9: Groups & Communities
- Create/manage groups
- Admin roles
- Member permissions
- Invite links
- Announcements & pinning

### Stage 10: Notifications
- Firebase Cloud Messaging setup
- Background notification handling
- Mention alerts
- Custom notification settings
- Badge management

### Stage 11: Security Hardening
- Signed media URLs
- Rate limiting implementation
- Moderation workflows
- App lock for sensitive chats
- Secure token storage
- Audit logging

### Stage 12: Testing & Optimization
- Load testing (1000 concurrent users)
- Offline scenario tests
- Poor network simulation
- Media stress tests
- UI performance profiling
- Battery/data usage optimization

### Stage 13: Deployment & Monitoring
- Deploy APIs to production
- Socket server scaling
- Redis cluster setup
- Database replication
- Media storage CDN
- Monitoring and alerting

---

## 12. CURRENT PROJECT STATUS

| Aspect | Status | Action |
|--------|--------|--------|
| **App Structure** | Empty scaffold | Need folder structure |
| **Dependencies** | Minimal | Add: Riverpod, Dio, Drift, Socket.IO, Firebase |
| **Authentication** | Not started | Start Stage 4 |
| **Local Database** | Not started | Set up Drift schema |
| **Real-time** | Not started | Socket.IO client setup |
| **Backend** | Not started | Set up NestJS project |

---

## 13. NEXT IMMEDIATE ACTIONS (Priority Order)

### Phase 1: Project Setup (This Week)
1. ✅ DONE: Understand architecture & requirements (THIS DOCUMENT)
2. Add pubspec.yaml dependencies (Riverpod, Dio, Drift, Socket.IO, Firebase)
3. Create folder structure: `lib/screens/`, `lib/models/`, `lib/services/`, `lib/widgets/`
4. Design core data models using Drift
5. Create app routing structure

### Phase 2: Authentication (Next 2 Weeks)
6. Design login/signup screens
7. Implement JWT token storage
8. Create authentication service
9. Add token refresh logic

### Phase 3: Chat Foundation (Following 2 Weeks)
10. Design chat list UI
11. Set up Drift database schema
12. Create chat service
13. Implement Socket.IO client

### Phase 4: Real-Time Messaging
14. Build conversation UI
15. Implement message sending/receiving
16. Add message states
17. Implement typing indicators

---

## 14. SUCCESS METRICS

By completion, the app should achieve:

| Metric | Target |
|--------|--------|
| App Launch to Chat List | < 500ms from SQLite cache |
| Open Conversation | < 300ms (recent messages from local DB) |
| Message Send to Display | < 100ms (optimistic UI) |
| Media Thumbnail Load | < 200ms from cache |
| Offline Mode Functionality | 100% for downloaded content |
| First-Time Install Size | < 80MB |
| Chat Sync on Reconnect | < 2 seconds (missed messages) |

---

## 15. KEY DECISIONS MADE

✅ **Local-First Architecture**: SQLite on every device, network is async  
✅ **Cursor Pagination**: Load 50 messages, expand on demand  
✅ **Optimistic UI**: Messages appear instantly, confirmed asynchronously  
✅ **Thumbnail-First Media**: Quick preview, full load in background  
✅ **JWT + Refresh Tokens**: Secure sessions with rotation  
✅ **Signed URLs**: Media never exposed as permanent public links  
✅ **Background Sync**: App responsive even during long sync operations  

---

## 16. DOCUMENT REFERENCE

This architecture document is based on the complete **High-Performance Chat App Development Document** which specifies:
- Product vision and UX goals
- Recommended tech stack rationale
- Core architectural principles
- Functional flows for all scenarios
- Performance optimization rules
- Offline experience requirements
- Complete data models
- Security design principles
- Unique feature opportunities
- 13-stage development roadmap
- Testing checklist
- Final deployment strategy

This document is your **single source of truth** for building SwiftNest.

---

## Summary: What Makes This Architecture Fast?

1. **Local-First**: Never wait for network to show data
2. **Sync-Smart**: Only fetch new messages, not full history
3. **Optimistic UI**: Messages appear instantly before server confirms
4. **Thumbnail-First**: Quick preview, full load in background
5. **Background Tasks**: Heavy work doesn't block UI
6. **Efficient Pagination**: Load only visible messages, expand on demand
7. **Smart Caching**: Multiple cache layers for different data types
8. **Resumable Transfers**: Large uploads/downloads don't restart on interruption

**Result**: App feels as fast as Telegram ⚡

---

**Document Created**: March 18, 2026  
**Project**: SwiftNest - High-Performance Chat Application  
**Status**: Ready for Implementation
