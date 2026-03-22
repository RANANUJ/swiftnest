# SwiftNest Tech Stack - Purpose & Integration Guide

## 📊 Your Complete Tech Stack Overview

This document maps each technology to specific features and explains how they work together to achieve Telegram-like performance.

---

## 🎯 Frontend Stack: Flutter

### Technology: **Flutter**
**Purpose**: Build Android and iOS apps from single Dart codebase

**Why SwiftNest Uses It**:
- ✅ Cross-platform (Android + iOS) with 90%+ code reuse
- ✅ Hot reload for fast development iteration
- ✅ Excellent performance (60-120 FPS animations)
- ✅ Rich widget library for custom chat UI
- ✅ Strong community with chat-app examples

**In SwiftNest**:
```dart
// Single codebase, runs on both platforms
void main() => runApp(MyApp());

// This code compiles to:
// - Android APK (Google Play)
// - iOS IPA (App Store)
// - Same app logic, platform-specific UI when needed
```

---

## 🔄 State Management: Riverpod or Bloc

### Technology: **Riverpod** (RECOMMENDED for SwiftNest)
**Purpose**: Manage app state efficiently without unnecessary rebuilds

**Why Riverpod Over Bloc**:
- ✅ Simpler syntax (Bloc is verbose)
- ✅ Better for async operations (great for network calls)
- ✅ Built-in dependency injection
- ✅ Works perfectly with code generation
- ✅ Easier to test

**In SwiftNest**:
```dart
// Global state provider for user authentication
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiProvider));
});

// Listen to auth state changes (login/logout)
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      loading: () => LoadingSpinner(),
      logged_in: (user) => HomeScreen(),
      logged_out: () => LoginForm(),
      error: (err) => ErrorMessage(err),
    );
  }
}
```

**What Riverpod Manages in SwiftNest**:
- ✅ User authentication state
- ✅ Chat list state (local cache + sync)
- ✅ Current conversation state
- ✅ Message list (with pagination)
- ✅ Media downloads
- ✅ Typing indicators
- ✅ Online/offline status
- ✅ Pending messages queue

**Benefits**:
- UI only rebuilds when data changes (not entire screen)
- Prevents jank and battery drain
- Makes app feel smooth and responsive

---

## 🖥️ Backend: Node.js + NestJS

### Technology: **NestJS** (Framework)
**Purpose**: Production-ready backend with modular structure

**Why NestJS**:
- ✅ Built on Express (mature, tested, fast)
- ✅ Full TypeScript support (type safety)
- ✅ Modular architecture (easy to extend)
- ✅ Excellent documentation
- ✅ Dependency injection for clean code
- ✅ Built-in validation and pipes

**In SwiftNest**:
```typescript
// Module: Chat Management
@Module({
  controllers: [ChatController],
  providers: [ChatService, ChatRepository],
  exports: [ChatService], // Can be used by other modules
})
export class ChatModule {}

// Service: Chat Logic
@Injectable()
export class ChatService {
  async sendMessage(chatId: string, message: CreateMessageDto) {
    // 1. Validate message
    // 2. Save to MongoDB
    // 3. Broadcast via Socket.IO to recipient
    // 4. Update Redis presence
    // 5. Return confirmation with server-assigned ID
  }
  
  async getMessages(chatId: string, pageToken?: string) {
    // Cursor-based pagination (not offset)
    // Returns only 50 messages, faster queries
    // Supports old message loading
  }
}

// Controller: Expose API endpoints
@Controller('chats')
export class ChatController {
  @Post(':id/messages')
  async sendMessage(@Param('id') chatId: string, @Body() dto: CreateMessageDto) {
    return this.chatService.sendMessage(chatId, dto);
  }
}
```

**NestJS Responsibilities in SwiftNest**:
- Validate all incoming data
- Manage user authentication
- Handle business logic (chat, messages, users)
- Connect to MongoDB and Redis
- Broadcast events via Socket.IO
- Serve signed URLs for media
- Rate limiting and security

---

## ⚡ Real-Time Transport: Socket.IO

### Technology: **Socket.IO**
**Purpose**: Instant message delivery, typing status, read receipts, reconnect logic

**Why Socket.IO**:
- ✅ WebSocket with fallback to HTTP polling
- ✅ Automatic reconnection handling
- ✅ Room-based broadcasting (perfect for group chats)
- ✅ Built-in acknowledgments (did server receive?)
- ✅ Works on all networks (even corporate firewalls)
- ✅ Large community, proven at scale (millions of users)

**In SwiftNest** (Backend + Frontend):

```typescript
// Backend: Socket.IO Server
io.on('connection', (socket) => {
  // User joins their personal notifications room
  socket.join(`user:${userId}`);
  
  // User joins a chat room
  socket.join(`chat:${chatId}`);
  
  // Client sends message
  socket.on('message:send', async (data, ack) => {
    const message = await chatService.sendMessage(data);
    
    // Send confirmation back to sender
    ack({ success: true, id: message.id });
    
    // Broadcast to all users in chat room
    io.to(`chat:${chatId}`).emit('message:received', message);
    
    // Notify recipient (if not in chat)
    io.to(`user:${recipientId}`).emit('notification', {
      title: 'New Message',
      body: `${senderName}: ${message.text}`,
    });
  });
  
  // Typing indicator
  socket.on('typing:start', () => {
    io.to(`chat:${chatId}`).emit('user:typing', { userId });
  });
  
  // Read receipt
  socket.on('message:read', (messageId) => {
    io.to(`chat:${chatId}`).emit('message:read_by', { userId, messageId });
  });
  
  socket.on('disconnect', () => {
    // Update presence: mark user offline
    redis.hdel(`online_users`, userId);
    io.emit('user:offline', { userId });
  });
});

// Backend: Presence Tracking
io.on('connection', (socket) => {
  // Mark user online in Redis
  redis.hset(`online_users`, userId, 'online');
  
  // Broadcast online status
  io.emit('user:online', { userId });
  
  // Check who's online
  socket.on('presence:check', async () => {
    const onlineUsers = await redis.hgetall(`online_users`);
    socket.emit('presence:list', onlineUsers);
  });
});
```

```dart
// Frontend: Socket.IO Client (Flutter)
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  
  void connect(String userId) {
    socket = IO.io('https://api.swiftnest.com', IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());
    
    socket.connect();
    
    // Receive messages
    socket.on('message:received', (data) {
      // Update local database
      db.insertMessage(data);
      
      // Update UI via Riverpod
      ref.read(messagesProvider.notifier).addMessage(data);
      
      // Show notification
      notificationService.show(data.senderName, data.text);
    });
    
    // Typing indicator
    socket.on('user:typing', (data) {
      ref.read(typingProvider.notifier).addTyping(data.userId);
    });
    
    // Handle reconnect
    socket.on('connect', () {
      print('Connected!');
      // Sync missed messages
      syncMissedMessages();
    });
    
    socket.on('disconnect', () {
      print('Disconnected, will retry...');
    });
  }
  
  // Send message
  void sendMessage(String text, String chatId) {
    socket.emit('message:send', {
      'chatId': chatId,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
    }, (response) {
      // Server confirmed receipt and assigned server ID
      if (response['success']) {
        // Replace temp ID with server ID
        db.updateMessageId(tempId, response['id']);
      }
    });
  }
  
  // Typing indicator
  void sendTyping(String chatId) {
    socket.emit('typing:start', { 'chatId': chatId });
  }
  
  // Read receipt
  void markAsRead(String messageId) {
    socket.emit('message:read', messageId);
  }
}
```

**Socket.IO in SwiftNest**:
- ✅ Instant message delivery (< 100ms)
- ✅ Typing indicators (who's typing in chat)
- ✅ Read receipts (sender knows when recipient read)
- ✅ Online/offline status
- ✅ Automatic reconnect (no manual retry needed)
- ✅ Fallback to HTTP polling if WebSocket unavailable
- ✅ Push notifications via Socket.IO (no Firebase needed!)

---

## 🗄️ Database: MongoDB

### Technology: **MongoDB**
**Purpose**: Store user profiles, chats, messages, settings, metadata with flexible schema

**Why MongoDB**:
- ✅ Flexible schema (chats can have different structures)
- ✅ JSON-like documents (match Dart/JavaScript objects)
- ✅ Excellent indexing for fast queries
- ✅ Scales horizontally (add more servers as load grows)
- ✅ Built-in replication for reliability
- ✅ No complex migrations needed

**In SwiftNest**:

```typescript
// MongoDB Schema: Users Collection
db.users.insertOne({
  _id: ObjectId("..."),
  email: "alice@example.com",
  username: "alice",
  passwordHash: "bcrypt_hash_...",
  avatar: "https://s3.amazonaws.com/...",
  bio: "Software engineer 💻",
  privacy: "public",
  blockedUsers: ["user_id_2", "user_id_3"],
  createdAt: ISODate("2026-01-15"),
  updatedAt: ISODate("2026-03-18"),
  lastActive: ISODate("2026-03-18T15:30:00Z")
});

// MongoDB Schema: Chats Collection
db.chats.insertOne({
  _id: ObjectId("..."),
  type: "ONE_TO_ONE", // or "GROUP"
  members: ["user_id_1", "user_id_2"],
  lastMessage: {
    id: ObjectId("..."),
    text: "See you tomorrow!",
    senderId: "user_id_1",
    timestamp: ISODate("2026-03-18T15:30:00Z")
  },
  unreadCount: { "user_id_2": 3 }, // User 2 has 3 unread messages
  mutedBy: [],
  pinnedMessages: ["msg_id_1", "msg_id_2"],
  createdAt: ISODate("2026-01-10"),
  updatedAt: ISODate("2026-03-18T15:30:00Z")
});

// MongoDB Schema: Messages Collection
db.messages.insertOne({
  _id: ObjectId("..."),
  chatId: ObjectId("..."),
  senderId: ObjectId("..."),
  type: "TEXT", // or "IMAGE", "VIDEO", "VOICE"
  text: "Let's grab coffee tomorrow",
  mediaUrl: null, // For images/videos
  thumbUrl: null,
  status: "SEEN", // PENDING -> SENDING -> SENT -> DELIVERED -> SEEN
  replyTo: ObjectId("..."), // If replying to another message
  createdAt: ISODate("2026-03-18T15:30:00Z"),
  editedAt: null,
  deletedAt: null,
  reactions: {
    "😂": ["user_id_1", "user_id_3"],
    "❤️": ["user_id_2"]
  }
});

// Indexed fields for fast queries
db.messages.createIndex({ chatId: 1, createdAt: -1 });
db.chats.createIndex({ "members": 1, updatedAt: -1 });
db.users.createIndex({ email: 1 });
```

**MongoDB Queries in SwiftNest**:

```typescript
// Get last 50 messages for a chat (for conversation opening)
async getMessages(chatId: string, pageToken?: string) {
  const query = { chatId };
  
  if (pageToken) {
    // Cursor pagination: get messages BEFORE this timestamp
    query.createdAt = { $lt: new Date(pageToken) };
  }
  
  const messages = await db.messages
    .find(query)
    .sort({ createdAt: -1 })
    .limit(50)
    .lean(); // Return plain objects, not Mongoose docs
  
  return messages.reverse(); // Reverse to show oldest first
}

// Get user's chats (for chat list)
async getChats(userId: string) {
  const chats = await db.chats
    .find({ members: userId })
    .sort({ updatedAt: -1 })
    .limit(30)
    .lean();
  
  return chats; // Return 30 most recent chats
}

// Mark message as read
async markAsRead(messageId: string, userId: string) {
  await db.messages.updateOne(
    { _id: messageId },
    {
      $set: { status: "SEEN" },
      $addToSet: { seenBy: userId } // Add to array if not present
    }
  );
}

// Search messages (full-text search)
async searchMessages(chatId: string, query: string) {
  // First, create a text index:
  // db.messages.createIndex({ text: "text" });
  
  const results = await db.messages
    .find(
      { chatId, $text: { $search: query } },
      { score: { $meta: "textScore" } }
    )
    .sort({ score: { $meta: "textScore" } })
    .limit(20);
  
  return results;
}
```

**MongoDB in SwiftNest**:
- ✅ Stores all persistent messages
- ✅ Tracks user profiles and relationships
- ✅ Manages chat metadata
- ✅ Supports complex queries (search, pagination)
- ✅ Scales as user base grows
- ✅ Integrates with Mongoose (Node.js ORM)

---

## ⚙️ Cache & Presence: Redis

### Technology: **Redis**
**Purpose**: Ultra-fast for online status, recent state, temporary tokens, pub/sub events

**Why Redis**:
- ✅ In-memory (nanosecond response times)
- ✅ Perfect for session storage (don't hit database for every request)
- ✅ Pub/Sub for real-time events
- ✅ Automatic expiration (tokens expire after 1 hour)
- ✅ Works with Socket.IO rooms

**In SwiftNest**:

```typescript
// Redis: Online Status (Presence)
// When user connects:
redis.hset('online_users', userId, 'online');

// When user disconnects:
redis.hdel('online_users', userId);

// Check who's online (instant, no database query)
const onlineUsers = await redis.hgetall('online_users');
// Returns: { user_id_1: 'online', user_id_2: 'online', ... }

// Send to all clients
io.emit('presence:updated', onlineUsers);

// Redis: Session Storage (JWT Refresh Tokens)
// Store refresh token hash temporarily
redis.setex(
  `refresh_token:${userId}`,
  30 * 24 * 60 * 60, // 30 days expiration
  tokenHash
);

// When token refresh requested:
const isValid = await redis.exists(`refresh_token:${userId}`);

// Logout: delete token (immediate logout, not wait for expiration)
await redis.del(`refresh_token:${userId}`);

// Redis: Temporary Data (OTP)
redis.setex(
  `otp:${email}`,
  5 * 60, // Expire in 5 minutes
  otpCode
);

// Verify OTP
const storedOtp = await redis.get(`otp:${email}`);
if (storedOtp === providedOtp) {
  // Valid
}

// Redis: Recent Data Cache
// Cache last 100 active chats to reduce MongoDB queries
redis.zadd('active_chats', Date.now(), chatId);

// Keep recent state for fast access
redis.hset(`chat:${chatId}`, 'lastMessage', JSON.stringify(message));
```

**Redis in SwiftNest**:
- ✅ Stores online/offline status (no database hits needed)
- ✅ Session tokens (fast logout/revocation)
- ✅ OTP codes for verification
- ✅ Cache frequently accessed data
- ✅ Pub/Sub for Socket.IO events
- ✅ Rate limiting counters

---

## 📁 Media Storage: S3 / R2 / MinIO

### Technology: **S3-compatible Storage** (AWS S3, Cloudflare R2, or MinIO)
**Purpose**: Store photos, videos, files, voice notes in scalable way

**Why S3-Compatible**:
- ✅ Scalable (handle petabytes of data)
- ✅ Cheap bandwidth
- ✅ CDN integration for fast downloads
- ✅ Pre-signed URLs (temporary secure access)
- ✅ Automatic backups and replication

**In SwiftNest**:

```typescript
// Backend: Generate upload signature (pre-signed URL)
@Post('media/upload-signature')
async getUploadSignature(@Body() dto: UploadDto) {
  const key = `uploads/${userId}/${uuid()}.${ext}`;
  
  // Generate pre-signed URL (valid for 30 minutes)
  const presignedUrl = s3.getSignedUrl('putObject', {
    Bucket: 'swiftnest-media',
    Key: key,
    Expires: 30 * 60, // 30 minutes
    ContentType: dto.mimeType,
  });
  
  return {
    uploadUrl: presignedUrl,
    uploadId: key, // Track this upload
    expiresIn: 30 * 60,
  };
}

// Backend: Frontend sends file directly to S3
// No bandwidth used on backend server (S3 handles it)

// Backend: Confirm upload and generate thumbnail
@Post('media/:uploadId/confirm')
async confirmUpload(@Param('uploadId') uploadId: string) {
  // Check file exists in S3
  const exists = await s3.headObject({
    Bucket: 'swiftnest-media',
    Key: uploadId,
  });
  
  // Generate thumbnail asynchronously
  startThumbnailGeneration(uploadId);
  
  // Save metadata to MongoDB
  await db.media.insertOne({
    uploadId,
    originalUrl: `https://s3.amazonaws.com/swiftnest-media/${uploadId}`,
    thumbUrl: null, // Will be filled when thumbnail ready
    size: exists.ContentLength,
    uploadedAt: new Date(),
  });
  
  return { success: true, mediaId: uploadId };
}

// Backend: Generate temporary download URL
@Get('media/:id/url')
async getMediaUrl(@Param('id') mediaId: string) {
  // Generate new signed URL every request (expires in 1 hour)
  const downloadUrl = s3.getSignedUrl('getObject', {
    Bucket: 'swiftnest-media',
    Key: mediaId,
    Expires: 60 * 60, // 1 hour
  });
  
  return { url: downloadUrl };
}
```

```dart
// Frontend: Upload to S3 directly
// 1. Get upload signature from backend
final response = await dio.post(
  '/media/upload-signature',
  data: { 'mimeType': 'image/jpeg' },
);

// 2. Upload file directly to S3 (uses Dio's resumable upload)
await dio.put(
  response.data['uploadUrl'],
  data: File(imagePath).openRead(),
  options: Options(
    contentType: 'image/jpeg',
    // Resumable: if connection breaks, continue from byte offset
  ),
  onSendProgress: (count, total) {
    print('Upload: $count / $total');
  },
);

// 3. Confirm upload
await dio.post('/media/${response.data['uploadId']}/confirm');

// 4. Use media in chat
// When displaying: check local cache first
// If not cached: fetch thumbnail from S3 (fast)
// If user wants full size: fetch full image (slow, but background)
```

**S3 in SwiftNest**:
- ✅ Direct uploads (backend bandwidth not impacted)
- ✅ Resumable uploads (interrupted upload continues)
- ✅ Secure temporary URLs (no permanent public links)
- ✅ CDN integration (global fast delivery)
- ✅ Unlimited storage (scales naturally)

---

## 💾 Offline Local DB: SQLite / Drift

### Technology: **Drift** (Type-safe SQLite wrapper for Dart)
**Purpose**: Store recent chats, messages, drafts, download metadata for instant opening

**Why Drift**:
- ✅ Type-safe (catches schema errors at compile time)
- ✅ Reactive (automatically notifies listeners of changes)
- ✅ Works offline (no network needed)
- ✅ Fast queries (indexed properly)
- ✅ Native to Dart (not generic database driver)

**In SwiftNest** (see DEPENDENCIES_AND_SETUP.md for full schema):

```dart
// Drift: Table Definitions
@DataClassName('ChatData')
class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // ONE_TO_ONE, GROUP
  TextColumn get members => text()(); // JSON array
  TextColumn get lastMessage => text().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MessageData')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get type => text().withDefault(const Constant('TEXT'))();
  TextColumn get text => text().nullable()();
  TextColumn get mediaUrl => text().nullable()();
  TextColumn get thumbUrl => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Index> get indexes => [
    Index('messages_chat_id', {chatId}),
    Index('messages_created_at', {createdAt}),
  ];
}
```

```dart
// Drift: Read & Write Operations
class ChatRepository {
  final AppDatabase db;
  
  // Load chat list from local database (instant)
  Future<List<ChatData>> getChatList() async {
    return await (db.select(db.chats)
      ..orderBy([(c) => OrderingTerm(expression: c.updatedAt, mode: OrderingMode.desc)])
      ..limit(30))
      .get();
  }
  
  // Load recent messages (instant)
  Future<List<MessageData>> getMessages(String chatId) async {
    return await (db.select(db.messages)
      ..where((m) => m.chatId.equals(chatId))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt)])
      ..limit(50))
      .get();
  }
  
  // Send message offline
  Future<void> addPendingMessage(PendingMessage msg) async {
    await db.into(db.pendingMessages).insert(msg);
  }
  
  // Save message as sent
  Future<void> saveMessage(Message msg) async {
    await db.into(db.messages).insert(msg);
  }
  
  // Stream messages (auto-updates UI)
  Stream<List<MessageData>> watchMessages(String chatId) {
    return (db.select(db.messages)
      ..where((m) => m.chatId.equals(chatId))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
      .watch();
  }
}

// Riverpod: Provide database to app
final databaseProvider = Provider((ref) => AppDatabase());

final chatListProvider = StreamProvider.autoDispose((ref) async* {
  final db = ref.watch(databaseProvider);
  yield* db.watchChats();
});

// UI: Instant rendering from local DB
class ChatListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatListProvider);
    
    return chatsAsync.when(
      data: (chats) => ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, i) => ChatListItem(chats[i]),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, st) => ErrorWidget(err),
    );
  }
}
```

**Drift in SwiftNest**:
- ✅ Instant chat list opening (no network)
- ✅ Offline message reading
- ✅ Pending message queue
- ✅ Download metadata tracking
- ✅ Draft preservation
- ✅ Automatic sync on reconnect

---

## 🌐 Networking: Dio

### Technology: **Dio**
**Purpose**: Handle APIs and resumable file upload/download cleanly

**Why Dio**:
- ✅ Resumable uploads/downloads (continue from byte offset)
- ✅ Request/response interceptors (handle auth, errors globally)
- ✅ Timeout handling
- ✅ Retry logic
- ✅ Progress tracking (show upload/download percentage)

**In SwiftNest**:

```dart
// Dio: Setup with interceptors
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.swiftnest.com',
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
  contentType: 'application/json',
));

// Interceptor: Add JWT token to every request
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await secureStorage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onError: (error, handler) async {
    // If 401 Unauthorized, try refreshing token
    if (error.response?.statusCode == 401) {
      try {
        await refreshToken();
        // Retry request
        return handler.resolve(await _retry(error.requestOptions));
      } catch (e) {
        // Refresh failed, logout user
        sendToLoginScreen();
      }
    }
    return handler.next(error);
  },
));

// Dio: Upload with resumable support
Future<void> uploadFile(File file) async {
  try {
    await dio.post(
      '/media/upload',
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      }),
      onSendProgress: (sent, total) {
        print('Upload: ${(sent / total * 100).toStringAsFixed(0)}%');
      },
    );
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      // Network interrupted, will auto-retry from byte offset
      print('Upload interrupted, will resume...');
    }
  }
}

// Dio: Download with resumable support
Future<void> downloadFile(String url, String savePath) async {
  try {
    await dio.download(
      url,
      savePath,
      deleteOnError: false, // Keep partial file for resume
      onReceiveProgress: (received, total) {
        print('Download: ${(received / total * 100).toStringAsFixed(0)}%');
      },
    );
  } on DioException {
    // Interrupted download can resume from byte offset
    // Check file size, request only missing bytes
  }
}

// Dio: API calls with automatic retry
final dioRetry = Dio()
  ..interceptors.add(SmartRetry(
    retryableStatuses: {408, 429, 500, 502, 503, 504},
    maxRetryAttempts: 3,
    retryInterval: const Duration(seconds: 1),
  ));
```

**Dio in SwiftNest**:
- ✅ All API calls (login, messages, media)
- ✅ Resumable uploads (interruption continues)
- ✅ Resumable downloads (interruption continues)
- ✅ Automatic token refresh
- ✅ Global error handling
- ✅ Timeout management
- ✅ Progress tracking

---

## 🔔 Notifications: Socket.IO (Not Firebase)

### Technology: **Socket.IO Events + flutter_local_notifications**
**Purpose**: Deliver push notifications efficiently (without Firebase dependency)

**Why Not Firebase**:
- ✅ Already using Socket.IO (no extra service)
- ✅ Simpler backend (no Firebase SDK needed)
- ✅ Notifications controlled entirely (no Google policies)
- ✅ Works with your Socket.IO infrastructure

**In SwiftNest**:

```typescript
// Backend: Send notification via Socket.IO
io.to(`user:${recipientId}`).emit('notification', {
  title: 'New Message',
  body: `${senderName}: ${messageText}`,
  chatId: chatId,
  messageId: messageId,
  type: 'CHAT',
  icon: senderAvatar,
});
```

```dart
// Frontend: Receive and display local notification
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  void initializeNotifications(SocketService socketService) {
    // Setup local notification channels
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'swiftnest_messages',
      'SwiftNest Messages',
      importance: Importance.high,
    );
    
    _notifications.createNotificationChannel(channel);
    
    // Listen to Socket.IO notifications
    socketService.socket.on('notification', (data) {
      _showNotification(
        title: data['title'],
        body: data['body'],
        payload: data['chatId'],
      );
    });
  }
  
  void _showNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'swiftnest_messages',
      'SwiftNest Messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: android,
      iOS: ios,
    );
    
    await _notifications.show(
      0,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
```

**Notifications in SwiftNest**:
- ✅ Real-time delivery (no polling)
- ✅ No Firebase overhead
- ✅ Customizable (complete control)
- ✅ Works with your backend
- ✅ Combines Socket.IO events + local notifications

---

## 🔗 How Everything Works Together

### User Journey: Opening App

```
1. User opens SwiftNest app
   ↓
2. Flutter loads (1 codebase, 2 platforms)
   ↓
3. Riverpod initializes state management
   ↓
4. Drift loads chat list from SQLite (INSTANT)
   ↓
5. UI displays chats immediately (< 500ms)
   ↓
6. Dio makes HTTP request to NestJS backend
   ↓
7. NestJS queries MongoDB for recent data
   ↓
8. Redis checks which users are online
   ↓
9. Dio receives response + updates Riverpod state
   ↓
10. UI updates only changed rows (efficient)
   ↓
11. Socket.IO connects in background
    ↓
12. Socket.IO joins user's notification room
    ↓
13. Ready for real-time messages
```

### User Journey: Sending a Message

```
1. User types message in Flutter UI
   ↓
2. User taps SEND
   ↓
3. Riverpod saves to local state (optimistic UI)
   ↓
4. Drift saves message locally with temp ID
   ↓
5. UI shows message immediately
   ↓
6. Dio sends message to NestJS backend (async)
   ↓
7. NestJS validates + saves to MongoDB
   ↓
8. NestJS broadcasts via Socket.IO to recipient
   ↓
9. Socket.IO sends ACK back with server ID
   ↓
10. Drift updates temp ID → server ID
    ↓
11. UI updates status: pending → sent
    ↓
12. Recipient receives via Socket.IO
    ↓
13. Recipient's Drift saves locally
    ↓
14. Recipient's UI updates automatically
```

### User Journey: Media Download

```
1. User taps image in chat
   ↓
2. Check local cache (fastest)
   ↓
3. If not cached:
   a. Display thumbnail from cache
   b. Show loading spinner
   c. Dio downloads from S3 (resumable)
   ↓
4. If network interrupted:
   a. Dio pauses download
   b. User can retry
   c. Resumes from byte offset (not restart)
   ↓
5. Download complete
   ↓
6. Drift saves metadata
   ↓
7. Show full image
   ↓
8. Goes offline? Can still view (cached)
```

---

## 📊 Tech Stack Summary Table

| Layer | Technology | Purpose | Why Chosen |
|-------|-----------|---------|-----------|
| **Mobile UI** | Flutter | Cross-platform app | Build once, deploy everywhere |
| **State** | Riverpod | Manage app state | Simple, async-friendly, no jank |
| **Real-Time** | Socket.IO | Instant messages | Instant delivery, reconnect logic |
| **API** | NestJS | Backend framework | Modular, TypeScript, production-ready |
| **Database** | MongoDB | Persistent storage | Flexible schema, scales well |
| **Cache** | Redis | Fast session/status | Nanosecond response times |
| **Media** | S3/R2/MinIO | Store files | Scalable, CDN-friendly, cheap |
| **Local DB** | Drift/SQLite | Offline storage | Type-safe, reactive, fast |
| **Networking** | Dio | HTTP client | Resumable uploads/downloads |
| **Notifications** | Socket.IO + Local | Push alerts | No Firebase, full control |

---

## ✅ Summary: Why This Stack for SwiftNest

1. **Speed**: Offline-first local database + optimistic UI = instant feel
2. **Reliability**: Resumable transfers + Socket.IO reconnect = never lose data
3. **Scalability**: MongoDB + Redis + S3 = handles millions of users
4. **Developer Experience**: Flutter + NestJS + TypeScript = fast development
5. **Cost**: Self-hosted (no Firebase fees), S3 pricing is cheap
6. **Control**: Custom backend (not locked into Firebase)

---

**Your app is ready to build!** Each technology is chosen for a specific reason. All pieces work together seamlessly. 🚀
