import 'package:drift/drift.dart';
import '../drift_database.dart';
part 'users_dao.g.dart';

/// Data Access Object for Users table
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<SwiftNestDatabase>
    with _$UsersDaoMixin {
  UsersDao(SwiftNestDatabase db) : super(db);

  /// Get user by ID
  Future<User?> getUserById(String id) {
    return (select(users)..where((u) => u.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) {
    return (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  /// Get all users
  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  /// Get users by IDs
  Future<List<User>> getUsersByIds(List<String> ids) {
    return (select(users)..where((u) => u.id.isIn(ids)))
        .get();
  }

  /// Insert or update user
  Future<void> upsertUser(UsersCompanion user) async {
    await into(users).insert(user, mode: InsertMode.insertOrReplace);
  }

  /// Insert multiple users
  Future<void> insertUsers(List<UsersCompanion> userList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(users, userList);
    });
  }

  /// Update user online status
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) {
    return (update(users)..where((u) => u.id.equals(userId)))
        .write(UsersCompanion(
          isOnline: Value(isOnline),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Update user last seen
  Future<void> updateUserLastSeen(String userId, DateTime lastSeenAt) {
    return (update(users)..where((u) => u.id.equals(userId)))
        .write(UsersCompanion(
          lastSeenAt: Value(lastSeenAt),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Delete user
  Future<int> deleteUser(String userId) {
    return (delete(users)..where((u) => u.id.equals(userId)))
        .go();
  }

  /// Count total users
  Future<int> countUsers() async {
    final count = await customSelect(
      'SELECT COUNT(*) as count FROM users',
      readsFrom: {users},
    ).map((row) => row.read<int>('count')).getSingle();
    return count;
  }

  /// Search users by name
  Future<List<User>> searchUsers(String query) {
    return (select(users)
      ..where((u) => u.name.like('%$query%'))
      ..orderBy([(u) => OrderingTerm(expression: u.name)]))
        .get();
  }
}
