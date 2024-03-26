const mouthMap = {
  1: '一月',
  2: '二月',
  3: '三月',
  4: '四月',
  5: '五月',
  6: '六月',
  7: '七月',
  8: '八月',
  9: '九月',
  10: '十月',
  11: '十一月',
  12: '十二月',
};

const mouthMapShort = {
  1: '一',
  2: '二',
  3: '三',
  4: '四',
  5: '五',
  6: '六',
  7: '七',
  8: '八',
  9: '九',
  10: '十',
  11: '十一',
  12: '十二',
};

const weekMap = {
  1: '周一',
  2: '周二',
  3: '周三',
  4: '周四',
  5: '周五',
  6: '周六',
  7: '周日',
};

const weekMapLong = {
  1: '星期一',
  2: '星期二',
  3: '星期三',
  4: '星期四',
  5: '星期五',
  6: '星期六',
  7: '星期日',
};

const weekMapShort = {
  1: '一',
  2: '二',
  3: '三',
  4: '四',
  5: '五',
  6: '六',
  7: '日',
};

String getMonthName(int month) {
  var value = mouthMap[month];
  assert(value != null);
  return value!;
}

String getMonthNameShort(int month) {
  var value = mouthMapShort[month];
  assert(value != null);
  return value!;
}

String getWeekName(int week) {
  var value = weekMap[week];
  assert(value != null);
  return value!;
}

String getWeekNameLong(int week) {
  var value = weekMapLong[week];
  assert(value != null);
  return value!;
}

String getWeekNameShort(int week) {
  var value = weekMapShort[week];
  assert(value != null);
  return value!;
}

class DayInfo {
  DayInfo(this.weekday, this.day,
      {this.isSelected = false, required this.dateTime});

  DayInfo.fromDateTime(DateTime dateTime, {bool isSelected = false})
      : weekday = dateTime.weekday,
        day = dateTime.day,
        isSelected = isSelected,
        dateTime = dateTime;

  final int weekday;
  final int day;
  final DateTime dateTime;
  bool isSelected = false;

  @override
  String toString() {
    return '\{weekday: $weekday, monthday: $day, real: $dateTime, isSelected: $isSelected\}';
  }
}
