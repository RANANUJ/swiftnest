/// Services layer - Core backend services
/// 
/// This module provides:
/// - Database service (Drift with SQLite)
/// - Authentication service
/// - Network service (Dio)
/// - Socket.IO real-time service
/// - Sync engine (offline message queue)
/// - Media service (upload/download/cache)
/// - Notification service

export 'database/index.dart';
export 'socket/index.dart';
export 'sync/index.dart';
export 'media/index.dart';
