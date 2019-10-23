import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show rootBundle;

typedef SqlFetcherBuilder = Widget Function(BuildContext context, List<Map<String, dynamic>> date, SqliteController controller, Widget child);

final logger = Logger(
  printer: PrettyPrinter(methodCount: 0, lineLength: 80, printTime: true),
);

class SqliteController {

  Future<int> update(String sqlPath, List<dynamic> arguments) async {
    var sql = await rootBundle.loadString(sqlPath);
    return (await _SqliteFetcherState._database).rawUpdate(sql, arguments);
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
    this.initSqlPath = 'assets/sql/table_create.sql',
    this.querySqlPath = 'assets/sql/query_task.sql',
    this.queryArguments,
    this.controller,
  }) : super(key: key);

  final SqlFetcherBuilder builder;
  final Widget child;
  final Widget loading;
  final String initSqlPath;
  final String querySqlPath;
  final List<dynamic> queryArguments;
  final SqliteController controller;

  @override
  _SqliteFetcherState createState() => _SqliteFetcherState(controller);
}

class _SqliteFetcherState extends State<SqliteFetcher> {
  _SqliteFetcherState(this._controller);

  static Future<Database> _database;

  Future<List<Map<String, dynamic>>> _future;

  SqliteController _controller;

  Widget _lastItem;

  @override
  void initState() {
    logger.d('Init SqlFetching state.');
    super.initState();
    if (_controller == null) {
      _controller = SqliteController();
    }
    _lastItem = widget.loading;

    if (_database == null) {
      logger.d('Database is null, try to open a new database in a Future.');
      _database = openDatabase(
        'yide_app.db',
        version: 2,
        onCreate: (db, version) async {
          return await db.execute(await rootBundle.loadString(widget.initSqlPath));
        }
      );

      logger.d('Init future object.');
      _future = _updateFuture();
    }
  }

  @override
  void didUpdateWidget(SqliteFetcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    Function eq = const ListEquality().equals;
    if (_future != null && eq(oldWidget.queryArguments, widget.queryArguments)) {
      logger.d('Arguments not changed when widget rebuilding.');
      return;
    }
    logger.d('Arguments changed when widget rebuilding.');
    _future = _updateFuture();
  }

  Future<List<Map<String, dynamic>>> _updateFuture() async {
    logger.d('Ready to update data Future.');
    final sql = await rootBundle.loadString(widget.querySqlPath);
    return (await _database).rawQuery(sql, widget.queryArguments);
  }

  @override
  void dispose() {
    logger.d('SqlFetching is disposing.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      logger.d('Future instance became null, refresh it.');
      _future = _updateFuture();
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      initialData: null,
      future: _future,
      builder: (context, snapshot) {
        logger.d('Rebuilding with state: ${snapshot.connectionState}');
        switch(snapshot.connectionState) {
          case ConnectionState.none: {
            return _lastItem;
          }
          case ConnectionState.waiting: {
            return widget.loading;
          }
          case ConnectionState.active:
          case ConnectionState.done: {
            logger.d('Building data reciever widget');
            _lastItem = widget.builder(context, snapshot.data, widget.controller, widget.child);
            return _lastItem;
          }
          default:
            return widget.loading;
        }
      },
    );
  }
}