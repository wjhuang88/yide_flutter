import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show rootBundle;

typedef SqlFetcherBuilder = Widget Function(BuildContext context, List<Map<String, dynamic>> date, SqliteController controller, Widget child);

class SqliteController {
  
  SqliteController._() {
    var initSqlPath = 'assets/sql/table_create.sql';
    if (_database == null) {
      print('Database is null, try to open a new database in a Future.');
      _database = openDatabase(
        'yide_app.db',
        version: 4,
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
          print('Upgrade sqlite table from version $oldVersion to version $newVersion.');
          var sql = await rootBundle.loadString(initSqlPath).catchError((e) {
            print('Read init sql error, sql path: $initSqlPath');
          });
          if (oldVersion == 1 || oldVersion == 2 || oldVersion == 3) {
            db.batch()
              ..execute('ALTER TABLE `task_data` RENAME TO `_task_data_temp`;')
              ..execute(sql)
              ..execute('INSERT INTO `task_data` (`create_time`, `tag_id`, `task_time`, `content`, `is_finished`, `remark`, `alarm_time`) SELECT `create_time`, `tag_id`, `task_time`, `content`, `is_finished`, `remark`, `alarm_time` FROM `_task_data_temp`')
              ..execute('DROP TABLE `_task_data_temp`')
              ..commit();
          }
        },
      ).catchError((e) {
        print('Cannot open database.');
      });
    }
  }

  static SqliteController instance = SqliteController._();

  Future<Database> _database;

  static bool _dirty = false;

  Future<int> update(String sqlPath, List<dynamic> arguments) async {
    var sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read update sql error, update sql path: $sqlPath');
    });
    _dirty = true;
    return (await _database)
      .rawUpdate(sql, arguments)
      .catchError((e) {
        print('DB update error, update sql: $sql, arguments: $arguments');
      });
  }

  Future<int> insert(String sqlPath, List<dynamic> arguments) async {
    var sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read insert sql error, insert sql path: $sqlPath');
    });
    _dirty = true;
    return (await _database)
      .rawInsert(sql, arguments)
      .catchError((e) {
        print('DB insert error, insert sql: $sql, arguments: $arguments');
      });
  }

  void dispose() {
    // TODO
  }
}

class SqliteFetcher extends StatefulWidget {
  const SqliteFetcher({
    Key key,
    @required this.builder,
    this.child,
    this.loading,
    this.querySqlPath = 'assets/sql/query_task.sql',
    this.queryArguments,
  }) : super(key: key);

  final SqlFetcherBuilder builder;
  final Widget child;
  final Widget loading;
  final String querySqlPath;
  final List<dynamic> queryArguments;

  @override
  _SqliteFetcherState createState() => _SqliteFetcherState();
}

class _SqliteFetcherState extends State<SqliteFetcher> {

  Future<List<Map<String, dynamic>>> _future;

  Widget _lastItem;

  @override
  void initState() {
    print('Init SqlFetching state.');
    super.initState();
    _lastItem = widget.loading;

    print('Init future object.');
    _future = _createFuture();
  }

  @override
  void didUpdateWidget(SqliteFetcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    Function eq = const ListEquality().equals;
    if (!SqliteController._dirty && _future != null && eq(oldWidget.queryArguments, widget.queryArguments)) {
      print('Clean data.');
      return;
    }
    print('Rebuilding for dirty data.');
    _future = _createFuture();
  }

  Future<List<Map<String, dynamic>>> _createFuture() async {
    print('Ready to update data Future.');
    final sql = await rootBundle.loadString(widget.querySqlPath).catchError((e) {
      print('Read sql file error, query sql path: ${widget.querySqlPath}');
    });
    return (await SqliteController.instance._database)
      .rawQuery(sql, widget.queryArguments)
      .catchError((e) {
        print('DB query error, query sql: $sql, arguments: ${widget.queryArguments}');
      })
      .whenComplete(() {
        SqliteController._dirty = false;
      });
  }

  @override
  void dispose() {
    print('SqlFetching is disposing.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      print('Future instance became null, refresh it.');
      _future = _createFuture();
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      initialData: null,
      future: _future,
      builder: (context, snapshot) {
        print('Rebuilding with state: ${snapshot.connectionState}');
        switch(snapshot.connectionState) {
          case ConnectionState.none: {
            return _lastItem;
          }
          case ConnectionState.waiting: {
            return widget.loading;
          }
          case ConnectionState.active:
          case ConnectionState.done: {
            print('Building data reciever widget');
            _lastItem = widget.builder(context, snapshot.data, SqliteController.instance, widget.child);
            return _lastItem;
          }
          default:
            return widget.loading;
        }
      },
    );
  }
}