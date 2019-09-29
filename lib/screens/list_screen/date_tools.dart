const _mouthMap = {
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

const _weekMap = {
  1: '周一',
  2: '周二',
  3: '周三',
  4: '周四',
  5: '周五',
  6: '周六',
  7: '周日',
};

String getMonthName(int month) {
  var value = _mouthMap[month];
  assert(value != null);
  return value;
}

String getWeekName(int week) {
  var value = _weekMap[week];
  assert(value != null);
  return value;
}