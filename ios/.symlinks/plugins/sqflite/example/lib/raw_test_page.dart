import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_example/src/utils.dart';

import 'test_page.dart';

class RawTestPage extends TestPage {
  RawTestPage() : super("Raw tests") {
    test("Options", () async {
      // Sqflite.devSetDebugModeOn(true);

      String path = await initDeleteDb("raw_query_format.db");
      Database db = await openDatabase(path);

      Batch batch = db.batch();

      batch.execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)");
      batch.rawInsert("INSERT INTO Test (name) VALUES (?)", ["item 1"]);
      batch.rawInsert("INSERT INTO Test (name) VALUES (?)", ["item 2"]);
      await batch.commit();

      // ignore: deprecated_member_use, deprecated_member_use_from_same_package
      var sqfliteOptions = SqfliteOptions()..queryAsMapList = true;
      // ignore: deprecated_member_use
      await Sqflite.devSetOptions(sqfliteOptions);
      String sql = "SELECT id, name FROM Test";
      // ignore: deprecated_member_use
      var result = await db.devInvokeSqlMethod("query", sql);
      List expected = [
        {'id': 1, 'name': 'item 1'},
        {'id': 2, 'name': 'item 2'}
      ];
      print("result as map list $result");
      expect(result, expected);

      // empty
      sql = "SELECT id, name FROM Test WHERE id=1234";
      // ignore: deprecated_member_use
      result = await db.devInvokeSqlMethod("query", sql);
      expected = [];
      print("result as map list $result");
      expect(result, expected);

      // ignore: deprecated_member_use, deprecated_member_use_from_same_package
      sqfliteOptions = SqfliteOptions()..queryAsMapList = false;
      // ignore: deprecated_member_use
      await Sqflite.devSetOptions(sqfliteOptions);

      sql = "SELECT id, name FROM Test";
      // ignore: deprecated_member_use
      var resultSet = await db.devInvokeSqlMethod("query", sql);
      var expectedResultSetMap = {
        "columns": ["id", "name"],
        "rows": [
          [1, "item 1"],
          [2, "item 2"]
        ]
      };
      print("result as r/c $resultSet");
      expect(resultSet, expectedResultSetMap);

      // empty
      sql = "SELECT id, name FROM Test WHERE id=1234";
      // ignore: deprecated_member_use
      resultSet = await db.devInvokeSqlMethod("query", sql);
      expectedResultSetMap = {};
      print("result as r/c $resultSet");
      expect(resultSet, expectedResultSetMap);

      await db.close();
    });
    test("Transaction", () async {
      String path = await initDeleteDb("simple_transaction.db");
      Database db = await openDatabase(path);
      await db.execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)");

      Future _test(int i) async {
        await db.transaction((txn) async {
          int count = Sqflite.firstIntValue(
              await txn.rawQuery("SELECT COUNT(*) FROM Test"));
          await Future.delayed(Duration(milliseconds: 40));
          await txn
              .rawInsert("INSERT INTO Test (name) VALUES (?)", ["item $i"]);
          //print(await db.query("SELECT COUNT(*) FROM Test"));
          int afterCount = Sqflite.firstIntValue(
              await txn.rawQuery("SELECT COUNT(*) FROM Test"));
          expect(count + 1, afterCount);
        });
      }

      List<Future> futures = [];
      for (int i = 0; i < 4; i++) {
        futures.add(_test(i));
      }
      await Future.wait(futures);
      await db.close();
    });

    test("Concurrency 1", () async {
      // Sqflite.devSetDebugModeOn(true);
      String path = await initDeleteDb("simple_concurrency_1.db");
      Database db = await openDatabase(path);
      var step1 = Completer();
      var step2 = Completer();
      var step3 = Completer();

      Future action1() async {
        await db
            .execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)");
        step1.complete();

        await step2.future;
        try {
          await db
              .rawQuery("SELECT COUNT(*) FROM Test")
              .timeout(Duration(seconds: 1));
          throw "should fail";
        } catch (e) {
          expect(e is TimeoutException, true);
        }

        step3.complete();
      }

      Future action2() async {
        await db.transaction((txn) async {
          // Wait for table being created;
          await step1.future;
          await txn.rawInsert("INSERT INTO Test (name) VALUES (?)", ["item 1"]);
          step2.complete();

          await step3.future;

          int count = Sqflite.firstIntValue(
              await txn.rawQuery("SELECT COUNT(*) FROM Test"));
          expect(count, 1);
        });
      }

      var future1 = action1();
      var future2 = action2();

      await Future.wait([future1, future2]);

      int count =
          Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Test"));
      expect(count, 1);

      await db.close();
    });

    test("Concurrency 2", () async {
      // Sqflite.devSetDebugModeOn(true);
      String path = await initDeleteDb("simple_concurrency_1.db");
      Database db = await openDatabase(path);
      var step1 = Completer();
      var step2 = Completer();
      var step3 = Completer();

      Future action1() async {
        await db
            .execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)");
        step1.complete();

        await step2.future;
        try {
          await db
              .rawQuery("SELECT COUNT(*) FROM Test")
              .timeout(Duration(seconds: 1));
          throw "should fail";
        } catch (e) {
          expect(e is TimeoutException, true);
        }

        step3.complete();
      }

      Future action2() async {
        // This is the change from concurrency 1
        // Wait for table being created;
        await step1.future;

        await db.transaction((txn) async {
          // Wait for table being created;
          await txn.rawInsert("INSERT INTO Test (name) VALUES (?)", ["item 1"]);
          step2.complete();

          await step3.future;

          int count = Sqflite.firstIntValue(
              await txn.rawQuery("SELECT COUNT(*) FROM Test"));
          expect(count, 1);
        });
      }

      var future1 = action1();
      var future2 = action2();

      await Future.wait([future1, future2]);

      int count =
          Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Test"));
      expect(count, 1);

      await db.close();
    });

    test("Transaction recursive", () async {
      String path = await initDeleteDb("transaction_recursive.db");
      Database db = await openDatabase(path);

      await db.execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)");

      // insert then fails to make sure the transaction is cancelled
      await db.transaction((txn) async {
        await txn.rawInsert("INSERT INTO Test (name) VALUES (?)", ["item 1"]);

        await txn.rawInsert("INSERT INTO Test (name) VALUES (?)", ["item 2"]);
      });
      int afterCount =
          Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Test"));
      expect(afterCount, 2);

      await db.close();
    });

    test("Transaction open twice", () async {
      //Sqflite.devSetDebugModeOn(true);
      String path = await initDeleteDb("transaction_open_twice.db");
      Database db = await openDatabase(path);

      await db.execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)");

      Database db2 = await openDatabase(path);

      await db.transaction((txn) async {
        await txn.rawInsert("INSERT INTO Test (name) VALUES (?)", ["item"]);
        int afterCount = Sqflite.firstIntValue(
            await txn.rawQuery("SELECT COUNT(*) FROM Test"));
        expect(afterCount, 1);

        /*
        // this is not working on Android
        int db2AfterCount =
        Sqflite.firstIntValue(await db2.rawQuery("SELECT COUNT(*) FROM Test"));
        assert(db2AfterCount == 0);
        */
      });
      int db2AfterCount = Sqflite.firstIntValue(
          await db2.rawQuery("SELECT COUNT(*) FROM Test"));
      expect(db2AfterCount, 1);

      int afterCount =
          Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Test"));
      expect(afterCount, 1);

      await db.close();
      await db2.close();
    });

    test("Debug mode (log)", () async {
      //await Sqflite.devSetDebugModeOn(false);
      String path = await initDeleteDb("debug_mode.db");
      Database db = await openDatabase(path);

      bool debugModeOn = await Sqflite.getDebugModeOn();
      await Sqflite.setDebugModeOn(true);
      await db.setVersion(1);
      await Sqflite.setDebugModeOn(false);
      // this message should not appear
      await db.setVersion(2);
      await Sqflite.setDebugModeOn(true);
      await db.setVersion(3);
      // restore
      await Sqflite.setDebugModeOn(debugModeOn);

      await db.close();
    });

    test("Demo", () async {
      // await Sqflite.devSetDebugModeOn();
      String path = await initDeleteDb("simple_demo.db");
      Database database = await openDatabase(path);

      //int version = await database.update("PRAGMA user_version");
      //print("version: ${await database.update("PRAGMA user_version")}");
      print("version: ${await database.rawQuery("PRAGMA user_version")}");

      //print("drop: ${await database.update("DROP TABLE IF EXISTS Test")}");
      await database.execute("DROP TABLE IF EXISTS Test");

      print("dropped");
      await database.execute(
          "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
      print("table created");
      int id = await database.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("some name",1234,?)',
          [456.789]);
      print("inserted1: $id");
      id = await database.rawInsert(
          'INSERT INTO Test(name, value) VALUES(?, ?)',
          ["another name", 12345678]);
      print("inserted2: $id");
      int count = await database.rawUpdate(
          'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
          ["updated name", "9876", "some name"]);
      print("updated: $count");
      expect(count, 1);
      List<Map> list = await database.rawQuery('SELECT * FROM Test');
      List<Map> expectedList = [
        {"name": "updated name", "id": 1, "value": 9876, "num": 456.789},
        {"name": "another name", "id": 2, "value": 12345678, "num": null}
      ];

      print("list: ${json.encode(list)}");
      print("expected $expectedList");
      expect(list, expectedList);

      count = await database
          .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
      print('deleted: $count');
      expect(count, 1);
      list = await database.rawQuery('SELECT * FROM Test');
      expectedList = [
        {"name": "updated name", "id": 1, "value": 9876, "num": 456.789},
      ];

      print("list: ${json.encode(list)}");
      print("expected $expectedList");
      expect(list, expectedList);

      await database.close();
    });

    test("Demo clean", () async {
      // Get a location
      var databasesPath = await getDatabasesPath();

      // Make sure the directory exists
      try {
        if (!await Directory(databasesPath).exists()) {
          await Directory(databasesPath).create(recursive: true);
        }
      } catch (_) {}

      String path = join(databasesPath, "demo.db");

      // Delete the database
      await deleteDatabase(path);

      // open the database
      Database database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
      });

      // Insert some records in a transaction
      await database.transaction((txn) async {
        int id1 = await txn.rawInsert(
            'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
        print("inserted1: $id1");
        int id2 = await txn.rawInsert(
            'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
            ["another name", 12345678, 3.1416]);
        print("inserted2: $id2");
      });

      // Update some record
      int count = await database.rawUpdate(
          'UPDATE Test SET name = ?, VALUE = ? WHERE name = ?',
          ["updated name", "9876", "some name"]);
      print("updated: $count");

      // Get the records
      List<Map> list = await database.rawQuery('SELECT * FROM Test');
      List<Map> expectedList = [
        {"name": "updated name", "id": 1, "value": 9876, "num": 456.789},
        {"name": "another name", "id": 2, "value": 12345678, "num": 3.1416}
      ];
      print(list);
      print(expectedList);
      //assert(const DeepCollectionEquality().equals(list, expectedList));
      expect(list, expectedList);

      // Count the records
      count = Sqflite.firstIntValue(
          await database.rawQuery("SELECT COUNT(*) FROM Test"));
      expect(count, 2);

      // Delete a record
      count = await database
          .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
      expect(count, 1);

      // Close the database
      await database.close();
    });

    test("Open twice", () async {
      // Sqflite.devSetDebugModeOn(true);
      String path = await initDeleteDb("open_twice.db");
      Database db = await openDatabase(path);
      await db.execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)");
      Database db2 = await openReadOnlyDatabase(path);

      int count = Sqflite.firstIntValue(
          await db2.rawQuery("SELECT COUNT(*) FROM Test"));
      expect(count, 0);
      await db.close();
      await db2.close();
    });

    test("text primary key", () async {
      // Sqflite.devSetDebugModeOn(true);
      String path = await initDeleteDb("text_primary_key.db");
      Database db = await openDatabase(path);
      // This table has no primary key however sqlite generates an hidden row id
      await db.execute("CREATE TABLE Test (name TEXT PRIMARY KEY)");
      int id = await db.insert("Test", {"name": "test"});
      expect(id, 1);
      id = await db.insert("Test", {"name": "other"});
      expect(id, 2);
      // row id is not retrieve by default
      var list = await db.query("Test");
      expect(list, [
        {"name": "test"},
        {"name": "other"}
      ]);
      list = await db.query("Test", columns: ['name', 'rowid']);
      expect(list, [
        {"name": "test", "rowid": 1},
        {"name": "other", "rowid": 2}
      ]);

      await db.close();
    });

    test("without rowid", () async {
      // Sqflite.devSetDebugModeOn(true);
      // this fails on iOS

      Database db;
      try {
        String path = await initDeleteDb("without_rowid.db");
        db = await openDatabase(path);
        // This table has no primary key and we ask sqlite not to generate
        // a rowid
        await db
            .execute("CREATE TABLE Test (name TEXT PRIMARY KEY) WITHOUT ROWID");
        int id = await db.insert("Test", {"name": "test"});
        // it seems to always return 1 on Android, 0 on iOS...
        if (Platform.isIOS) {
          expect(id, 0);
        } else {
          expect(id, 1);
        }
        id = await db.insert("Test", {"name": "other"});
        // it seems to always return 1
        if (Platform.isIOS) {
          expect(id, 0);
        } else {
          expect(id, 1);
        }
        // notice the order is based on the primary key
        var list = await db.query("Test");
        expect(list, [
          {"name": "other"},
          {"name": "test"}
        ]);
      } finally {
        await db?.close();
      }
    });

    test('Reference query', () async {
      String path = await initDeleteDb("reference_query.db");
      Database db = await openDatabase(path);
      try {
        Batch batch = db.batch();

        batch.execute("CREATE TABLE Other (id INTEGER PRIMARY KEY, name TEXT)");
        batch.execute(
            "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, other REFERENCES Other(id))");
        batch.rawInsert("INSERT INTO Other (name) VALUES (?)", ["other 1"]);
        batch.rawInsert(
            "INSERT INTO Test (other, name) VALUES (?, ?)", [1, "item 2"]);
        await batch.commit();

        var result = await db.query('Test',
            columns: ['other', 'name'], where: 'other = 1');
        print(result);
        expect(result, [
          {"other": 1, "name": "item 2"}
        ]);
        result = await db.query('Test',
            columns: ['other', 'name'], where: 'other = ?', whereArgs: [1]);
        print(result);
        expect(result, [
          {"other": 1, "name": "item 2"}
        ]);
      } finally {
        await db.close();
      }
    });
  }
}
