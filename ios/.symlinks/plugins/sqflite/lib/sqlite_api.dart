import 'dart:async';

import 'package:sqflite/sql.dart' show ConflictAlgorithm;
import 'package:sqflite/src/open_options.dart' as impl;

export 'package:sqflite/sql.dart' show ConflictAlgorithm;
export 'package:sqflite/src/constant.dart' show inMemoryDatabasePath;
export 'package:sqflite/src/exception.dart' show DatabaseException;

/// Basic databases operations
abstract class DatabaseFactory {
  /// Open a database at [path] with the given [options]
  Future<Database> openDatabase(String path, {OpenDatabaseOptions options});

  /// Get the default databases location path
  Future<String> getDatabasesPath();

  /// Delete a database if it exists
  Future<void> deleteDatabase(String path);

  /// Check if a database exists
  Future<bool> databaseExists(String path);
}

///
/// Common API for [Database] and [Transaction] to execute SQL commands
///
abstract class DatabaseExecutor {
  /// Execute an SQL query with no return value
  Future<void> execute(String sql, [List<dynamic> arguments]);

  /// Execute a raw SQL INSERT query
  ///
  /// Returns the last inserted record id
  Future<int> rawInsert(String sql, [List<dynamic> arguments]);

  // INSERT helper
  Future<int> insert(String table, Map<String, dynamic> values,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm});

  /// Helper to query a table
  ///
  /// @param distinct true if you want each row to be unique, false otherwise.
  /// @param table The table names to compile the query against.
  /// @param columns A list of which columns to return. Passing null will
  ///            return all columns, which is discouraged to prevent reading
  ///            data from storage that isn't going to be used.
  /// @param where A filter declaring which rows to return, formatted as an SQL
  ///            WHERE clause (excluding the WHERE itself). Passing null will
  ///            return all rows for the given URL.
  /// @param groupBy A filter declaring how to group rows, formatted as an SQL
  ///            GROUP BY clause (excluding the GROUP BY itself). Passing null
  ///            will cause the rows to not be grouped.
  /// @param having A filter declare which row groups to include in the cursor,
  ///            if row grouping is being used, formatted as an SQL HAVING
  ///            clause (excluding the HAVING itself). Passing null will cause
  ///            all row groups to be included, and is required when row
  ///            grouping is not being used.
  /// @param orderBy How to order the rows, formatted as an SQL ORDER BY clause
  ///            (excluding the ORDER BY itself). Passing null will use the
  ///            default sort order, which may be unordered.
  /// @param limit Limits the number of rows returned by the query,
  /// @param offset starting index,

  /// @return the items found
  Future<List<Map<String, dynamic>>> query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset});

  /// Execute a raw SQL SELECT query
  ///
  /// Returns a list of rows that were found
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic> arguments]);

  /// Execute a raw SQL UPDATE query
  ///
  /// Returns the number of changes made
  Future<int> rawUpdate(String sql, [List<dynamic> arguments]);

  /// Convenience method for updating rows in the database.
  ///
  /// Update [table] with [values], a map from column names to new column
  /// values. null is a valid value that will be translated to NULL.
  ///
  /// [where] is the optional WHERE clause to apply when updating.
  /// Passing null will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictResolver] docs for more details
  Future<int> update(String table, Map<String, dynamic> values,
      {String where,
      List<dynamic> whereArgs,
      ConflictAlgorithm conflictAlgorithm});

  /// Executes a raw SQL DELETE query
  ///
  /// Returns the number of changes made
  Future<int> rawDelete(String sql, [List<dynamic> arguments]);

  /// Convenience method for deleting rows in the database.
  ///
  /// Delete from [table]
  ///
  /// [where] is the optional WHERE clause to apply when updating. Passing null
  /// will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictResolver] docs for more details
  ///
  /// Returns the number of rows affected if a whereClause is passed in, 0
  /// otherwise. To remove all rows and get a count pass "1" as the
  /// whereClause.
  Future<int> delete(String table, {String where, List<dynamic> whereArgs});

  /// Creates a batch, used for performing multiple operation
  /// in a single atomic operation.
  ///
  /// a batch can be commited using [Batch.commit]
  ///
  /// If the batch was created in a transaction, it will be commited
  /// when the transaction is done
  Batch batch();
}

/// Database transaction
/// to use during a transaction
abstract class Transaction implements DatabaseExecutor {}

///
/// Database to send sql commands, created during [openDatabase]
///
abstract class Database implements DatabaseExecutor {
  /// The path of the database
  String get path;

  /// Close the database. Cannot be accessed anymore
  Future<void> close();

  /// Calls in action must only be done using the transaction object
  /// using the database will trigger a dead-lock
  Future<T> transaction<T>(Future<T> action(Transaction txn), {bool exclusive});

  ///
  /// Get the database inner version
  ///
  Future<int> getVersion();

  /// Tell if the database is open, returns false once close has been called
  bool get isOpen;

  ///
  /// Set the database inner version
  /// Used internally for open helpers and automatic versioning
  ///
  Future<void> setVersion(int version);

  /// testing only
  @deprecated
  Future<T> devInvokeMethod<T>(String method, [dynamic arguments]);

  /// testing only
  @deprecated
  Future<T> devInvokeSqlMethod<T>(String method, String sql,
      [List<dynamic> arguments]);
}

typedef FutureOr<void> OnDatabaseVersionChangeFn(
    Database db, int oldVersion, int newVersion);
typedef FutureOr<void> OnDatabaseCreateFn(Database db, int version);
typedef FutureOr<void> OnDatabaseOpenFn(Database db);
typedef FutureOr<void> OnDatabaseConfigureFn(Database db);

/// to specify during [openDatabase] for [onDowngrade]
/// Downgrading will always fail
Future<void> onDatabaseVersionChangeError(
    Database db, int oldVersion, int newVersion) async {
  throw ArgumentError("can't change version from $oldVersion to $newVersion");
}

Future<void> __onDatabaseDowngradeDelete(
    Database db, int oldVersion, int newVersion) async {
  // Implementation is hidden implemented in openDatabase._onDatabaseDowngradeDelete
}
// Downgrading will delete the database and open it again
final OnDatabaseVersionChangeFn onDatabaseDowngradeDelete =
    __onDatabaseDowngradeDelete;

///
/// Options for opening the database
/// see [openDatabase] for details
///
abstract class OpenDatabaseOptions {
  factory OpenDatabaseOptions(
      {int version,
      OnDatabaseConfigureFn onConfigure,
      OnDatabaseCreateFn onCreate,
      OnDatabaseVersionChangeFn onUpgrade,
      OnDatabaseVersionChangeFn onDowngrade,
      OnDatabaseOpenFn onOpen,
      bool readOnly = false,
      bool singleInstance = true}) {
    return impl.SqfliteOpenDatabaseOptions(
        version: version,
        onConfigure: onConfigure,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade,
        onOpen: onOpen,
        readOnly: readOnly,
        singleInstance: singleInstance);
  }

  int version;
  OnDatabaseConfigureFn onConfigure;
  OnDatabaseCreateFn onCreate;
  OnDatabaseVersionChangeFn onUpgrade;
  OnDatabaseVersionChangeFn onDowngrade;
  OnDatabaseOpenFn onOpen;
  bool readOnly;
  bool singleInstance;
}

///
/// A batch is used to perform multiple operation as a single atomic unit.
/// A Batch object can be acquired by calling [Database.batch]. It provides
/// methods for adding operation. None of the operation will be
/// executed (or visible locally) until commit() is called.
///
abstract class Batch {
  /// Commits all of the operations in this batch as a single atomic unit
  /// The result is a list of the result of each operation in the same order
  /// if [noResult] is true, the result list is empty (i.e. the id inserted
  /// the count of item changed is not returned.
  ///
  /// The batch is stopped if any operation failed
  /// If [continueOnError] is true, all the operations in the batch are executed
  /// and the failure are ignored (i.e. the result for the given operation will
  /// be a DatabaseException)
  ///
  /// During [Database.onCreate], [Database.onUpgrade], [Database.onDowngrade]
  /// (we are already in a transaction) or if the batch was created in a
  /// transaction it will only be commited when
  /// the transaction is commited ([exclusive] is not used then)
  Future<List<dynamic>> commit(
      {bool exclusive, bool noResult, bool continueOnError});

  /// See [Database.rawInsert]
  void rawInsert(String sql, [List<dynamic> arguments]);

  /// See [Database.insert]
  void insert(String table, Map<String, dynamic> values,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm});

  /// See [Database.rawUpdate]
  void rawUpdate(String sql, [List<dynamic> arguments]);

  /// See [Database.update]
  void update(String table, Map<String, dynamic> values,
      {String where,
      List<dynamic> whereArgs,
      ConflictAlgorithm conflictAlgorithm});

  /// See [Database.rawDelete]
  void rawDelete(String sql, [List<dynamic> arguments]);

  /// See [Database.delete]
  void delete(String table, {String where, List<dynamic> whereArgs});

  /// See [Database.execute];
  void execute(String sql, [List<dynamic> arguments]);

  /// See [Database.query];
  void query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset});

  /// See [Database.query];
  void rawQuery(String sql, [List<dynamic> arguments]);
}
