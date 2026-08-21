/*
 *
 *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mindful/core/database/app_database.dart';
import 'package:mindful/core/utils/db_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// A service class responsible for interacting with the Drift database.
///
/// This class provides methods for initializing the Drift database,
class DriftDbService {
  /// Private constructor to enforce singleton pattern.
  DriftDbService._();

  /// Singleton instance of the [DriftDbService].
  static final DriftDbService instance = DriftDbService._();

  /// Instance used for database operations.
  late AppDatabase driftDb;

  /// Initializes the Drift database service.
  ///
  /// This method should be called once in the application's main method
  /// to set up the database.
  Future<void> init() async => driftDb = await _createIsolatedDb();

  /// Creates a single safe executor for both read and write operations.
  /// Using MultiExecutor with two separate NativeDatabase connections on the
  /// same file caused a race condition where the background executor could
  /// call onCreate (recreating all tables) independently of the foreground
  /// executor, wiping existing data. A single connection is safer and correct
  /// for this app's usage pattern.
  Future<AppDatabase> _createIsolatedDb() async {
    final db = LazyDatabase(
      () async {
        final dbFile = File(await getSqliteDbPath());

        /// Set cache directory for sqlite3 temp files
        final cacheBase = (await getTemporaryDirectory()).path;
        sqlite3.tempDirectory = cacheBase;

        /// Single executor — WAL journal mode allows concurrent reads without
        /// a separate read connection, and eliminates the onCreate race
        /// condition that caused data loss when two executors opened the same
        /// DB file simultaneously on app update.
        return NativeDatabase(
          dbFile,
          setup: _setup,
        );
      },
    );

    return AppDatabase(db);
  }

  /// Setup before opening db
  static void _setup(Database db) {
    /// Retry until 5 seconds then throw db lock error
    db.execute('PRAGMA busy_timeout = 5000;');

    /// Enable WAL mode: allows multiple concurrent readers alongside a
    /// single writer, giving good read performance without needing a
    /// separate read executor (which caused the onCreate race condition).
    db.execute('PRAGMA journal_mode = WAL;');
    db.execute('PRAGMA wal_autocheckpoint = 1000;');
  }
}

