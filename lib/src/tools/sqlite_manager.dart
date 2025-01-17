import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yide/src/models/geo_data.dart';
import 'package:yide/src/models/task_data.dart';

class SqliteManager {
  SqliteManager._() {
    if (_database == null) {
      print('Database is null, try to open a new database.');
      _database = openDatabase(
        'yide_app.db',
        version: 10,
        onCreate: (db, version) async {
          print('Init sqlite table at version $version.');
          _execute(db, 'assets/sql/table_create.sql');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          print(
              'Upgrading sqlite table from version $oldVersion to version $newVersion.');

          if (oldVersion < 4) {
            print('Ready to execute upgrade sql from any version to v4');
            await _execute(db, 'assets/sql/v3_to_v4.sql');
          }
          if (oldVersion < 5) {
            print('Ready to execute upgrade sql from v4 to v5');
            await _execute(db, 'assets/sql/v4_to_v5.sql');
          }
          if (oldVersion < 6) {
            print('Ready to execute upgrade sql from v5 to v6');
            await _execute(db, 'assets/sql/v5_to_v6.sql');
          }
          if (oldVersion < 7) {
            print('Ready to execute upgrade sql from v6 to v7');
            await _execute(db, 'assets/sql/v6_to_v7.sql');
          }
          if (oldVersion < 8) {
            print('Ready to execute upgrade sql from v7 to v8');
            await _execute(db, 'assets/sql/v7_to_v8.sql');
          }
          if (oldVersion < 9) {
            print('Ready to execute upgrade sql from v8 to v9');
            await _execute(db, 'assets/sql/v8_to_v9.sql');
          }
          if (oldVersion < 10) {
            print('Ready to execute upgrade sql from v9 to v10');
            await _execute(db, 'assets/sql/v9_to_v10.sql');
          }
        },
      ).catchError((e) {
        print('Cannot open database.\n$e');
      });
    }
  }

  Future<dynamic> _execute(Database db, String path,
      [List<dynamic> arguments = const []]) async {
    final sqlBatch = await rootBundle.loadString(path).catchError((e) {
      print('Read sql error, sql path: $path\n$e');
    });
    final sqlList =
        sqlBatch.trim().split(';').where((token) => token.isNotEmpty);
    final sqlListLen = sqlList.length;

    if (sqlListLen <= 0) {
      return;
    } else if (sqlListLen == 1) {
      return db.execute(sqlList.first, arguments).catchError((e) {
        print('Execute sql error, sql path: ${sqlList.first}\n$e');
      });
    } else {
      final batch = db.batch();
      sqlList.forEach((sql) {
        batch.execute(sql, arguments);
      });
      return batch.commit().catchError((e) {
        print('Execute sql error, sql list: $sqlList\n$e');
      });
    }
  }

  Future<int> _deleteInTransaction(Database db, String path,
      [List<dynamic> arguments = const []]) async {
    final sqlBatch = await rootBundle.loadString(path).catchError((e) {
      print('Read sql error, sql path: $path\n$e');
    });
    final sqlList =
        sqlBatch.trim().split(';').where((token) => token.isNotEmpty);
    final sqlListLen = sqlList.length;
    if (sqlListLen <= 0) {
      return 0;
    } else {
      return db.transaction<int>((txn) async {
        final batch = txn.batch();
        sqlList.forEach((sql) {
          batch.rawDelete(sql, arguments);
        });
        final result = await batch.commit().catchError((e) {
          print('Delete error, sql list: $sqlList\n$e');
        });
        return result.map((value) => value as int).reduce((l, r) => l + r);
      }).catchError((e) {
        print('Delete transaction error, sql path: $path\n$e');
      });
    }
  }

  static SqliteManager instance = SqliteManager._();

  Future<Database>? _database;

  Future<int?> batchUpdate(
      String sqlPath, List<List<dynamic>> arguments) async {
    assert(arguments.length >= 1,
        'This method is used for more than 1 update in one batch, but found ${arguments.length}.');
    final sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read update sql error, update sql path: $sqlPath\n$e');
    });
    final batch = (await _database)?.batch();
    arguments.forEach((arg) {
      batch?.rawUpdate(sql, arg);
    });
    final results = await batch?.commit().catchError((e) {
      print('DB update error, update sql: $sql, arguments: $arguments\n$e');
    });
    return results?.map((value) => value as int).reduce((lt, rt) => lt + rt);
  }

  Future<int> update(String sqlPath,
      [List<dynamic> arguments = const []]) async {
    final sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read update sql error, update sql path: $sqlPath\n$e');
    });
    return (await _database)!.rawUpdate(sql, arguments).catchError((e) {
      print('DB update error, update sql: $sql, arguments: $arguments\n$e');
    });
  }

  Future<int?> batchInsert(
      String sqlPath, List<List<dynamic>> arguments) async {
    assert(arguments.length > 1,
        'This method is used for more than 1 update in one batch, but found ${arguments.length}.');
    final sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read insert sql error, insert sql path: $sqlPath\n$e');
    });
    final batch = (await _database)?.batch();
    arguments.forEach((arg) {
      batch?.rawInsert(sql, arg);
    });
    final results = await batch?.commit().catchError((e) {
      print('DB insert error, insert sql: $sql, arguments: $arguments\n$e');
    });
    return results?.map((value) => value as int).reduce((lt, rt) => lt + rt);
  }

  Future<int?> insert(String sqlPath,
      [List<dynamic> arguments = const []]) async {
    final sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read insert sql error, insert sql path: $sqlPath\n$e');
    });
    return (await _database)?.rawInsert(sql, arguments).catchError((e) {
      print('DB insert error, insert sql: $sql, arguments: $arguments\n$e');
    });
  }

  Future<List<Map<String, dynamic>>?> query(String sqlPath,
      [List<dynamic> arguments = const []]) async {
    final sql = await rootBundle.loadString(sqlPath).catchError((e) {
      print('Read sql file error, query sql path: $sqlPath\n$e');
    });
    return (await _database)?.rawQuery(sql, arguments).catchError((e) {
      print('DB query error, query sql: $sql, arguments: $arguments\n$e');
    });
  }

  Future<void> execute(String sqlPath,
      [List<dynamic> arguments = const []]) async {
    final db = await _database;
    return _execute(db!, sqlPath, arguments);
  }

  Future<int> deleteInTransaction(String sqlPath,
      [List<dynamic> arguments = const []]) async {
    return _deleteInTransaction(await _database!, sqlPath, arguments);
  }

  void dispose() async {
    if (_database != null) {
      (await _database)?.close();
    }
  }
}

class TaskDBAction {
  TaskDBAction._internal();

  static SqliteManager _dbManager = SqliteManager.instance;

  static TaskPack _makePackFromQueryResult(Map<String, dynamic> dataRaw) {
    final data = TaskData(
      id: dataRaw['id'] as int,
      createTime: dataRaw['create_time'] is int
          ? DateTime.fromMillisecondsSinceEpoch(dataRaw['create_time'] as int)
          : null,
      tagId: dataRaw['tag_id'] as int,
      taskTime: dataRaw['task_time'] is int
          ? DateTime.fromMillisecondsSinceEpoch(dataRaw['task_time'] as int)
          : null,
      content: dataRaw['content'] as String,
      isFinished: (dataRaw['is_finished'] as int) == 1,
      remark: dataRaw['remark'] as String,
      alarmTime: dataRaw['alarm_time'] is int
          ? DateTime.fromMillisecondsSinceEpoch(dataRaw['alarm_time'] as int)
          : null,
      timeTypeCode: dataRaw['time_type_code'] as int,
      finishTime: dataRaw['finish_time'] is int
          ? DateTime.fromMillisecondsSinceEpoch(dataRaw['finish_time'] as int)
          : null,
    );

    final tag = TaskTag(
      id: dataRaw['tag_id'] as int,
      backgroundColor: dataRaw['background_color'] is int
          ? Color(dataRaw['background_color'] as int)
          : const Color(0xFFFFFFFF),
      iconColor: dataRaw['icon_color'] is int
          ? Color(dataRaw['icon_color'] as int)
          : const Color(0xFFFFFFFF),
      name: dataRaw['tag_name'] as String,
      icon: FontAwesomeIcons.solidCircle,
    );

    return TaskPack(data, tag);
  }

  static TaskTag _makeTagFromQueryResult(Map<String, dynamic> dataRaw) {
    return TaskTag(
      id: dataRaw['id'] as int,
      backgroundColor: dataRaw['background_color'] is int
          ? Color(dataRaw['background_color'] as int)
          : const Color(0xFFFFFFFF),
      iconColor: dataRaw['icon_color'] is int
          ? Color(dataRaw['icon_color'] as int)
          : const Color(0xFFFFFFFF),
      name: dataRaw['name'] as String,
      icon: FontAwesomeIcons.solidCircle,
    );
  }

  static Future<List<TaskTag>?> getAllTaskTag() async {
    final result = await _dbManager.query('assets/sql/query_tag.sql');
    return result?.map(_makeTagFromQueryResult).toList();
  }

  static Future<TaskTag?> getFirstTag() async {
    final result = await _dbManager.query('assets/sql/query_first_tag.sql');
    if (result?.length == 0) {
      return null;
    }
    assert(result?.length == 1,
        'Querying first tag should return 1 and only 1 result, but ${result?.length} found.');
    final tagRaw = result?.first;
    return _makeTagFromQueryResult(tagRaw!);
  }

  static Future<TaskTag?> getTaskTagById(int? id) async {
    if (id == null) {
      return null;
    }
    final result =
        await _dbManager.query('assets/sql/query_tag_by_id.sql', [id]);
    assert(result?.length == 1,
        'Querying tag data by id should return 1 and only 1 result, but ${result?.length} found.');
    final tagRaw = result?.first;
    return _makeTagFromQueryResult(tagRaw!);
  }

  static Future<bool> isTaskExists(int? id) async {
    if (id == null) {
      return false;
    }
    final result =
        await _dbManager.query('assets/sql/query_task_count.sql', [id]);
    if (result == null) {
      return false;
    }
    assert(result.length == 1,
        'Querying task count by id should return 1 and only 1 result, but ${result.length} found.');
    final count = result.first['count'] as int;
    return count > 0;
  }

  static Future<TaskPack?> getTaskById(int? id) async {
    if (id == null) {
      return null;
    }
    final result =
        await _dbManager.query('assets/sql/query_task_by_id.sql', [id]);
    assert(result?.length == 1,
        'Querying task data by id should return 1 and only 1 result, but ${result?.length} found.');

    final dataRaw = result?.first;
    return _makePackFromQueryResult(dataRaw!);
  }

  static Future<Iterable<TaskPack>?> getTaskFinishedListByDate(
      DateTime? date) async {
    if (date == null) {
      return null;
    }

    DateTime dateBegin = DateTime(date.year, date.month, date.day);
    DateTime dateEnd = DateTime(date.year, date.month, date.day + 1);

    final result = await _dbManager.query(
        'assets/sql/query_task_finished_by_date.sql',
        [dateBegin.millisecondsSinceEpoch, dateEnd.millisecondsSinceEpoch]);

    return result?.map(_makePackFromQueryResult);
  }

  static Future<Iterable<TaskPack>?> getTaskListTodo(DateTime? date) async {
    if (date == null) {
      return null;
    }

    DateTime queryDate = DateTime(date.year, date.month, date.day + 1)
        .subtract(Duration(seconds: 1));

    final result = await _dbManager.query(
        'assets/sql/query_task_todo.sql', [queryDate.millisecondsSinceEpoch]);

    return result?.map(_makePackFromQueryResult);
  }

  static List<dynamic> _makeTaskQueryArgs(TaskData? taskData,
      [bool isUpdate = false]) {
    final body = [
      DateTime.now().millisecondsSinceEpoch,
      taskData?.tagId,
      taskData?.taskTime?.millisecondsSinceEpoch,
      taskData?.content,
      taskData?.isFinished ?? false ? 1 : 0,
      taskData?.remark,
      taskData?.alarmTime?.millisecondsSinceEpoch,
      taskData?.timeTypeCode,
      taskData?.finishTime?.millisecondsSinceEpoch,
    ];
    if (isUpdate) {
      body.add(taskData?.id);
    }
    return body;
  }

  static Future<int?> saveTask(TaskData? task) async {
    const insertSqlPath = 'assets/sql/insert_task.sql';
    const updateSqlPath = 'assets/sql/update_task_by_id.sql';
    final isExist = await isTaskExists(task?.id);
    if (isExist) {
      return _dbManager.update(updateSqlPath, _makeTaskQueryArgs(task, true));
    } else {
      return _dbManager.insert(insertSqlPath, _makeTaskQueryArgs(task));
    }
  }

  static Future<int> deleteTask(TaskData? task) async {
    final isExist = await isTaskExists(task?.id);
    if (!isExist) {
      return 0;
    } else {
      return _dbManager
          .deleteInTransaction('assets/sql/delete_task.sql', [task?.id]);
    }
  }

  static Future<int> toggleTaskFinish(
      int? id, bool isFinished, DateTime finishTime) async {
    const sql = 'assets/sql/toggle_task_finish.sql';
    final isExist = await isTaskExists(id);
    if (isExist) {
      return _dbManager.update(
          sql, [isFinished ? 1 : 0, finishTime.millisecondsSinceEpoch, id]);
    } else {
      return 0;
    }
  }

  static Future<List<TaskPack>?> getTaskListReady(DateTime? date) async {
    if (date == null) {
      return null;
    }

    final queryDate = DateTime(date.year, date.month, date.day + 1);

    final result = await _dbManager.query(
        'assets/sql/query_task_ready.sql', [queryDate.millisecondsSinceEpoch]);

    return result?.map(_makePackFromQueryResult).toList();
  }

  static Future<List<TaskPack>?> getTaskListFinished() async {
    final result = await _dbManager.query('assets/sql/query_task_finished.sql');
    return result?.map(_makePackFromQueryResult).toList();
  }

  static Future<List<TaskPack>?> getTaskListByPage(
      int pagination, int perPage) async {
    final result = await _dbManager.query(
        'assets/sql/query_task_by_page.sql', [perPage, perPage * pagination]);
    return result?.map(_makePackFromQueryResult).toList();
  }

  static Future<bool> isTaskDetailExists(int? id) async {
    if (id == null) {
      return false;
    }
    final result =
        await _dbManager.query('assets/sql/query_task_detail_count.sql', [id]);
    if (result == null) {
      return false;
    }
    assert(result.length == 1,
        'Querying detail count by id should return 1 and only 1 result, but ${result.length} found.');
    final count = result.first['count'] as int;
    return count > 0;
  }

  static Future<TaskDetail?> getTaskDetailById(int? id) async {
    if (id == null) {
      return null;
    }
    final result =
        await _dbManager.query('assets/sql/query_task_detail_by_id.sql', [id]);
    if (result?.length == 0) {
      return null;
    } else {
      final raw = result?.first;
      return TaskDetail(
        id: raw?['id'] as int,
        reminderBitMap:
            ReminderBitMap(bitMap: raw?['reminder_bitmap'] as int ?? 0),
        repeatBitMap: raw?['repeat_bitmap'] != null
            ? RepeatBitMap(bitMap: raw?['repeat_bitmap'] as int)
            : RepeatBitMap.selectNone(),
        address: AroundData(
          name: raw?['address'] as String,
          coordinate: Coordinate(
              latitude: raw?['latitude'] as double,
              longitude: raw?['longitude'] as double),
        ),
      );
    }
  }

  static List<dynamic> _makeDetailQueryArgs(TaskDetail? detail,
      [bool isUpdate = false]) {
    final body = [
      DateTime.now().millisecondsSinceEpoch,
      detail?.reminderBitMap?.bitMap,
      detail?.repeatBitMap?.bitMap,
      detail?.address?.name,
      detail?.address?.coordinate?.latitude,
      detail?.address?.coordinate?.longitude,
    ];
    if (isUpdate) {
      return body..add(detail?.id);
    } else {
      return body..insert(0, detail?.id);
    }
  }

  static Future<int?> saveTaskDetail(TaskDetail? detail) async {
    const insertSqlPath = 'assets/sql/insert_task_detail.sql';
    const updateSqlPath = 'assets/sql/update_task_detail_by_id.sql';

    final isExists = await isTaskDetailExists(detail?.id);
    if (isExists) {
      return _dbManager.update(
          updateSqlPath, _makeDetailQueryArgs(detail, true));
    } else {
      return _dbManager.insert(insertSqlPath, _makeDetailQueryArgs(detail));
    }
  }

  static Future<bool> isTaskRecurringExists(int? taskId) async {
    if (taskId == null) {
      return false;
    }
    final result = await _dbManager
        .query('assets/sql/query_task_recurring_count.sql', [taskId]);
    if (result == null) {
      return false;
    }
    assert(result.length == 1,
        'Querying task recurring count by id should return 1 and only 1 result, but ${result.length} found.');
    final count = result.first['count'] as int;
    return count > 0;
  }

  static TaskRecurring _makeRecurringFromQueryMap(Map<String, dynamic> map) {
    return TaskRecurring(
      id: map['id'] as int,
      taskId: map['task_id'] as int,
      repeatModeCode: map['repeat_mode'] as int,
      repeatMaxNum: map['repeat_max_num'] as int,
      daysOfWeekCode: map['days_of_week_code'] as int,
      daysOfMonthCode: map['days_of_month_code'] as int,
      monthsOfYearCode: map['months_of_year_code'] as int,
      taskTime: map['task_time'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['task_time'] as int)
          : null,
      nextTime: map['next_time'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['next_time'] as int)
          : null,
    );
  }

  static Future<Iterable<TaskRecurring>?> getTaskRecurringByDate(
      DateTime? date) async {
    if (date == null) {
      return null;
    }
    DateTime dateBegin = DateTime(date.year, date.month, date.day);
    DateTime dateEnd = DateTime(date.year, date.month, date.day + 1);

    final result = await _dbManager.query(
        'assets/sql/query_task_recurring_by_date.sql',
        [dateBegin.millisecondsSinceEpoch, dateEnd.millisecondsSinceEpoch]);
    return result?.map(_makeRecurringFromQueryMap);
  }

  static Future<Iterable<TaskRecurring>?> getTaskRecurringReady(
      DateTime? date) async {
    if (date == null) {
      return null;
    }
    DateTime dateQuery = DateTime(date.year, date.month, date.day + 1);

    final result = await _dbManager.query(
        'assets/sql/query_task_recurring_ready.sql',
        [dateQuery.millisecondsSinceEpoch]);
    return result?.map(_makeRecurringFromQueryMap);
  }

  static Future<Iterable<TaskRecurring>?> getAllTaskRecurring() async {
    final result =
        await _dbManager.query('assets/sql/query_task_recurring_all.sql');
    return result?.map(_makeRecurringFromQueryMap);
  }

  static TaskRecurring _makeRecurringNextTime(
      TaskRecurring recurring, DateTime today) {
    recurring.nextTime ??= recurring.taskTime ?? DateTime.now();
    if (recurring.nextTime!.isAfter(today) ||
        recurring.nextTime!.isAtSameMomentAs(today)) {
      return recurring;
    }
    switch (recurring.repeatMode) {
      case RepeatMode.daily:
        recurring.nextTime = today.add(Duration(days: 1));
        return recurring;
      case RepeatMode.weekly:
        final weekList = recurring.daysOfWeek;
        if (weekList.isEmpty) {
          return recurring;
        }
        var date = recurring.nextTime;
        while (!weekList.contains(date!.weekday) || date.isBefore(today)) {
          date = date.add(Duration(days: 1));
        }
        recurring.nextTime = date;
        return recurring;
      case RepeatMode.monthly:
        var date = recurring.nextTime;
        while (date!.isBefore(today)) {
          date = DateTime(date.year, date.month + 1, date.day);
        }
        recurring.nextTime = date;
        return recurring;
      case RepeatMode.annual:
        var date = recurring.nextTime;
        while (date!.isBefore(today)) {
          date = DateTime(date.year + 1, date.month, date.day);
        }
        recurring.nextTime = date;
        return recurring;
      case RepeatMode.none:
        return recurring;
    }
  }

  static Future<int?> updateRecurring(TaskRecurring recurring) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day + 1)
        .subtract(Duration(seconds: 1));
    final recurringForSave = _makeRecurringNextTime(recurring, today);
    return saveTaskRecurring(recurringForSave);
  }

  static Future<int?> updateRecurringNextTime() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day + 1)
        .subtract(Duration(seconds: 1));
    final srcList = await getAllTaskRecurring();
    final updatedList = srcList?.map((recurring) {
      return _makeRecurringNextTime(recurring, today);
    });
    return updateTaskRecurringBatch(updatedList!);
  }

  static List<dynamic> _makeRecurringQueryArgs(TaskRecurring recurring,
      [bool isUpdate = false]) {
    final body = [
      recurring.taskId,
      recurring.repeatModeCode,
      recurring.repeatMaxNum,
      recurring.daysOfWeekCode,
      recurring.daysOfMonthCode,
      recurring.monthsOfYearCode,
      recurring.taskTime?.millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
      recurring.nextTime?.millisecondsSinceEpoch,
    ];
    if (isUpdate) {
      body.add(recurring.taskId);
    }
    return body;
  }

  static Future<int?> saveTaskRecurring(TaskRecurring recurring) async {
    const insertSqlPath = 'assets/sql/insert_task_recurring.sql';
    const updateSqlPath = 'assets/sql/update_task_recurring_by_task_id.sql';
    const deleteSqlPath = 'assets/sql/delete_task_recurring.sql';

    if (recurring.repeatMode == RepeatMode.none) {
      return _dbManager.deleteInTransaction(deleteSqlPath, [recurring.taskId]);
    }

    final isExist = await isTaskRecurringExists(recurring.taskId);
    if (isExist) {
      return _dbManager.update(
          updateSqlPath, _makeRecurringQueryArgs(recurring, true));
    } else {
      return _dbManager.insert(
          insertSqlPath, _makeRecurringQueryArgs(recurring));
    }
  }

  static Future<int?> updateTaskRecurringBatch(
      Iterable<TaskRecurring> recurrings) async {
    const updateSqlPath = 'assets/sql/update_task_recurring_by_task_id.sql';
    final args = recurrings
        .map((recurring) => _makeRecurringQueryArgs(recurring, true))
        .toList();
    if (args.length > 0) {
      return _dbManager.batchUpdate(updateSqlPath, args);
    }
    return 0;
  }
}
