import 'package:flutter/material.dart';

import 'package:yide/src/models/geo_data.dart';
import 'package:yide/src/tools/date_tools.dart';

enum DateTimeType { daytime, night, datetime }

class TaskTag {
  TaskTag.copy(TaskTag tag)
      : this.id = tag.id,
        this.backgroundColor = tag.backgroundColor,
        this.icon = tag.icon,
        this.iconColor = tag.iconColor,
        this.name = tag.name;

  const TaskTag({
    this.id,
    this.backgroundColor,
    this.icon,
    this.iconColor,
    this.name,
  });

  const TaskTag.defaultNull()
      : id = -1,
        backgroundColor = Colors.white,
        icon = Icons.label,
        iconColor = Colors.white,
        name = '载入中';

  final int id;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String name;
}

class TaskData {
  TaskData.copy(TaskData data)
      : this.id = data.id,
        this.createTime = data.createTime,
        this.taskTime = data.taskTime,
        this.tagId = data.tagId,
        this.isFinished = data.isFinished,
        this.content = data.content,
        this.remark = data.remark,
        this.catalog = data.catalog,
        this.timeTypeCode = data.timeTypeCode,
        this.alarmTime = data.alarmTime,
        this.finishTime = data.finishTime;

  TaskData({
    this.id,
    this.createTime,
    this.taskTime,
    this.tagId,
    this.isFinished = false,
    this.content,
    this.remark,
    this.catalog,
    this.timeTypeCode,
    this.alarmTime,
    this.finishTime,
  });

  TaskData.defultNull()
      : id = null,
        createTime = DateTime.now(),
        taskTime = DateTime.now(),
        tagId = null,
        isFinished = false,
        content = '',
        remark = '',
        catalog = '',
        timeTypeCode = 1,
        alarmTime = null;

  final int id;
  DateTime createTime;
  DateTime taskTime;
  int tagId;
  bool isFinished;
  String content;
  String remark;
  int timeTypeCode;
  String catalog;
  DateTime alarmTime;
  DateTime finishTime;

  DateTimeType get timeType {
    switch (timeTypeCode) {
      case 0:
        return DateTimeType.datetime;
      case 2:
        return DateTimeType.night;
      case 1:
        return DateTimeType.daytime;
      default:
        print(
            'Unsupported DateTimeType code: $timeTypeCode, set to default value: fullday.');
        return DateTimeType.daytime;
    }
  }

  set timeType(DateTimeType value) {
    switch (value) {
      case DateTimeType.daytime:
        timeTypeCode = 1;
        break;
      case DateTimeType.night:
        timeTypeCode = 2;
        break;
      case DateTimeType.datetime:
        timeTypeCode = 0;
        break;
    }
  }
}

class TaskDetail {
  int id;
  final ReminderBitMap reminderBitMap;
  final RepeatBitMap repeatBitMap;
  AroundData address;

  TaskDetail({this.id, this.reminderBitMap, this.repeatBitMap, this.address});

  TaskDetail.defultNull()
      : id = -1,
        reminderBitMap = ReminderBitMap(),
        repeatBitMap = RepeatBitMap.selectNone(),
        address = null;

  static TaskDetail nullDetail = TaskDetail.defultNull();
}

class TaskPack {
  final TaskData data;
  final TaskTag tag;

  TaskPack(
    this.data,
    this.tag,
  );
}

class ReminderBitMap {
  ReminderBitMap({this.bitMap = 0});
  int bitMap;

  static const List<String> labels = const [
    '准时',
    '5分钟前',
    '10分钟前',
    '15分钟前',
    '30分钟前',
    '1小时前',
    '2小时前',
    '1天前',
    '1周前'
  ];

  bool get isRightTime => bitMap & 1 != 0;
  void reverseRightTime() => bitMap ^= 1;

  bool get is5Minites => bitMap & (1 << 1) != 0;
  void reverse5Minites() => bitMap ^= 1 << 1;

  bool get is10Minites => bitMap & (1 << 2) != 0;
  void reverse10Minites() => bitMap ^= 1 << 2;

  bool get is15Minites => bitMap & (1 << 3) != 0;
  void reverse15Minites() => bitMap ^= 1 << 3;

  bool get is30Minites => bitMap & (1 << 4) != 0;
  void reverse30Minites() => bitMap ^= 1 << 4;

  bool get isHour => bitMap & (1 << 5) != 0;
  void reverseHour() => bitMap ^= 1 << 5;

  bool get is2Hour => bitMap & (1 << 6) != 0;
  void reverse2Hour() => bitMap ^= 1 << 6;

  bool get isDay => bitMap & (1 << 7) != 0;
  void reverseDay() => bitMap ^= 1 << 7;

  bool get isWeek => bitMap & (1 << 8) != 0;
  void reverseWeek() => bitMap ^= 1 << 8;

  String makeLabel() {
    return labels
        .asMap()
        .entries
        .where((entry) => bitMap & (1 << entry.key) != 0)
        .map((entry) => entry.value)
        .join('、');
  }
}

class RepeatBitMap {
  RepeatBitMap({this.bitMap = 0 + (1 << 14)});
  RepeatBitMap.selectWeek() : bitMap = 1 + (1 << 12) + (1 << 14);
  RepeatBitMap.selectNone() : bitMap = (1 << 8) + (1 << 12) + (1 << 14);
  RepeatBitMap.selectMonth() : bitMap = (1 << 9) + (1 << 12) + (1 << 14);
  RepeatBitMap.selectYear() : bitMap = (1 << 10) + (1 << 12) + (1 << 14);
  RepeatBitMap.selectDaily() : bitMap = (1 << 11) + (1 << 12) + (1 << 14);

  static int get noneBitmap => (1 << 8) + (1 << 12) + (1 << 14);

  static const _weekdayMask =
      (1 << 1) + (1 << 2) + (1 << 3) + (1 << 4) + (1 << 5);
  static const _weekendMask = (1 << 6) + (1 << 7);
  static const _allWeekMask = _weekdayMask + _weekendMask;

  static const _allTimeMask = 1 + (1 << 8) + (1 << 9) + (1 << 10) + (1 << 11);
  static const _allModeMask = (1 << 12) + (1 << 13);

  static const _countMax = 1 << 20;
  static const _countMin = 1;

  int bitMap;

  bool isSelectedDay(int day) {
    assert(day >= 1 && day <= 7);
    return (1 << day) & bitMap != 0;
  }

  void reverseWeekDay(int day) {
    assert(day >= 1 && day <= 7);
    bitMap ^= 1 << day;
  }

  bool get isWeekSelected => bitMap & 1 != 0;
  void reverseWeekSelected() => bitMap ^= 1;

  bool get isNoneRepeat => bitMap & (1 << 8) != 0;
  void reverseNoneRepeat() => bitMap ^= 1 << 8;

  bool get isMonthSelected => bitMap & (1 << 9) != 0;
  void reverseMonthSelected() => bitMap ^= 1 << 9;

  bool get isYearSelected => bitMap & (1 << 10) != 0;
  void reverseYearSelected() => bitMap ^= 1 << 10;

  bool get isDailySelected => bitMap & (1 << 11) != 0;
  void reverseDailySelected() => bitMap ^= 1 << 11;

  bool get isNeverEnd => bitMap & (1 << 12) != 0;
  void reverseNeverEnd() => bitMap ^= 1 << 12;

  bool get isCountEnd => bitMap & (1 << 13) != 0;
  void reverseCountEnd() => bitMap ^= 1 << 13;

  int get repeatCount => bitMap >> 14;

  void increaseCount() {
    if (repeatCount < _countMax) {
      bitMap += 1 << 14;
    }
  }

  void decreaseCount() {
    if (repeatCount > _countMin) {
      bitMap -= 1 << 14;
    }
  }

  void resetSelect() {
    bitMap &= ~_allTimeMask;
  }

  void resetMode() {
    bitMap &= ~_allModeMask;
  }

  void checkAndSetMonday() {
    if (!isWeekSelected) {
      return;
    }
    if (bitMap & _allWeekMask == 0) {
      bitMap |= 1 << 1;
    }
  }

  void checkAndNotUnselect(int day) {
    if (!isWeekSelected) {
      return;
    }
    final tempResult = bitMap ^ (1 << day);
    if (tempResult & _allWeekMask != 0) {
      reverseWeekDay(day);
    }
  }

  String makeRepeatModeLabel() {
    if (isNeverEnd) {
      return '始终';
    }
    if (isCountEnd) {
      return '$repeatCount 次后';
    }
    return '';
  }

  String makeRepeatTimeLabel() {
    if (isNoneRepeat) {
      return '无重复';
    }
    if (isDailySelected) {
      return '每日';
    }
    if (isMonthSelected) {
      return '每月';
    }
    if (isYearSelected) {
      return '每年';
    }
    final buffer = <String>[];
    if (bitMap & _allWeekMask == _allWeekMask) {
      return '每日';
    }
    if (bitMap & _weekdayMask == _weekdayMask) {
      int i = 7;
      while (i > 5) {
        if (bitMap & (1 << i) != 0) {
          buffer.add(getWeekName(i));
        }
        i--;
      }
      buffer.add('工作日');
      return buffer.reversed.join('、');
    }
    if (bitMap & _weekendMask == _weekendMask) {
      buffer.add('周末');
      int i = 5;
      while (i > 0) {
        if (bitMap & (1 << i) != 0) {
          buffer.add(getWeekName(i));
        }
        i--;
      }
      return buffer.reversed.join('、');
    }
    int i = 7;
    while (i > 0) {
      if (bitMap & (1 << i) != 0) {
        buffer.add(getWeekName(i));
      }
      i--;
    }
    if (buffer.length > 0) {
      return buffer.reversed.join('、');
    } else {
      return '';
    }
  }
}
