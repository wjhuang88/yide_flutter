import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

class DBConnector {
  DBConnector._();
  DBConnector._init(this._database);
  Database _database;
  
  static Future<DBConnector> init(String name) async {
    var sql = await rootBundle.loadString('lib/db/table_create.sql');
    var db = await openDatabase(
      name,
      version: 1,
      onCreate: (db, version) async {
        return await db.execute(sql);
      }
    );
    return DBConnector._init(db);
  }

  void dispose() async {
    await _database?.close();
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    return await _database.query(table);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    return await _database.insert(table, data);
  }
}