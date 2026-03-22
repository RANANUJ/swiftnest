import 'package:riverpod/riverpod.dart';
import 'drift_database.dart';
import 'database_service.dart';

/// Provider for the Drift database instance
final databaseProvider = FutureProvider<SwiftNestDatabase>((ref) async {
  final database = SwiftNestDatabase();
  return database;
});

/// Provider for database service (high-level API)
final databaseServiceProvider = FutureProvider<DatabaseService>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return DatabaseService(database);
});

/// Provider for database operations that requires the database to be available
final databaseOperationProvider = FutureProvider<SwiftNestDatabase>(
  (ref) => ref.watch(databaseProvider.future),
);
