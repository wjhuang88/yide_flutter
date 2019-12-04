import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

class SqliteManager {
  SqliteManager._() {
    var initSqlPath = 'assets/sql/table_create.sql';
    if (_database == null) {
      print('Database is null, try to open a new database in a Future.');
      _database = openDatabase(
        'yide_app.db',
        version: 5,
        onCreate: (db, version) async {
          print('Init sqlite table at version $version.');
          var sql = await rootBundle.loadString(initSqlPath).catchError((e) {
            print('Read init sql error, sql path: $initSqlPath');
          });
          return await db.execute(sql).catchError((e) {
            print('Init table error, sql path: $initSqlPath');
          });
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          print(
              'Upgrade sqlite table from version $oldVersion to version $newVersion.');
          var sql = await rootBundle.loadString(initSqlPath).catchError((e) {
            print('Read init sql error, sql path: $initSqlPath');
          });
          if (oldVersion < 4) {
            db.batch()
              ..execute('ALTER TABLE `task_data` RENAME TO `_task_data_temp`;')
              ..execute(sql)
              ..execute(
                  'INSERT INTO `task_data` (`create_time`, `tag_id`, `task_time`, `content`, `is_finished`, `remark`, `alarm_time`) SELECT `create_time`, `tag_id`, `task_time`, `content`, `is_finished`, `remark`, `alarm_time` FROM `_task_data_temp`')
              ..execute('DROP TABLE `_task_data_temp`')
              ..commit().catchError((e) {
                print(
                    'Update table error, from version $oldVersion to $newVersion');
              });
          }
          if (oldVersion < 5) {
            var updateSql = await rootBundle
                .loadString('assets/sql/v4_to_v5.sql')
                .catchError((e) {
              print('Read update sql error, path: assets/sql/v4_to_v5.sql');
            });
            db.execute(updateSql).catchError((e) {
              print(
                  'Update table error, from version $oldVersion to $newVersion');
            });
          }
        },
      ).catchError((e) {
        print('Cannot open database.');
      });
    }
  }

  static SqliteManager instance = SqliteManager._();

  Future<Database> _database;

  Future<int> update(String sqlPath, List<dynamic> arguments) async {
    var sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read update sql error, update sql path: $sqlPath');
    });
    return (await _database).rawUpdate(sql, arguments).catchError((e) {
      print('DB update error, update sql: $sql, arguments: $arguments');
    });
  }

  Future<int> insert(String sqlPath, List<dynamic> arguments) async {
    var sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read insert sql error, insert sql path: $sqlPath');
    });
    return (await _database).rawInsert(sql, arguments).catchError((e) {
      print('DB insert error, insert sql: $sql, arguments: $arguments');
    });
  }

  Future<List<Map<String, dynamic>>> query(String sqlPath, List<dynamic> arguments) async {
    final sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read sql file error, query sql path: $sqlPath');
    });
    return (await _database).rawQuery(sql, arguments).catchError((e) {
      print('DB query error, query sql: $sql, arguments: $arguments');
    });
  }

  void dispose() async {
    (await _database).close();
  }
}
