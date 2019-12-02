import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/components/flipping_tile.dart';
import 'package:yide/components/tap_animator.dart';
import 'package:yide/interfaces/navigatable.dart';
import 'package:yide/models/date_tools.dart';

class DetailRepeatScreen extends StatefulWidget implements Navigatable {
  @override
  _DetailRepeatScreenState createState() => _DetailRepeatScreenState();

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic),
        );
        return FractionalTranslation(
          translation: Offset(0.0, 1 - anim1Curved.value),
          child: Opacity(
            opacity: anim1Curved.value,
            child: child,
          ),
        );
      },
    );
  }
}

const _colorList = const [const Color(0xFFE6A800), const Color(0xFFBD8A00)];

const _weekdayMask = (1 << 1) + (1 << 2) + (1 << 3) + (1 << 4) + (1 << 5);
const _weekendMask = (1 << 6) + (1 << 7);
const _allWeekMask = _weekdayMask + _weekendMask;

class _DetailRepeatScreenState extends State<DetailRepeatScreen> {
  /// bitmap: 从低位往高位，每一位1表示有效0表示无效，
  /// 第一位表示是否选中周重复，接下来每一位对应一周中的一天
  int _selectedWeekDay = 0;
  int _selectedWeekDayLast = 0;

  bool _isNoneRepeat = true;
  bool get _isWeekSelected => _selectedWeekDay & 1 != 0;
  set _isWeekSelected(bool value) =>
      value ? _selectedWeekDay |= 1 : _selectedWeekDay &= ~1;
  bool _isMonthSelected = false;
  bool _isYearSelected = false;
  bool _isDailySelected = false;

  bool _isNeverEnd = true;
  bool _isCountEnd = false;
  int _count = 1;

  @override
  void initState() {
    super.initState();
  }

  String _makeEndLabel() {
    if (_isNeverEnd) {
      return '永不结束';
    }
    if (_isCountEnd) {
      return '$_count 次后';
    }
    return '';
  }

  String _makeLabel() {
    if (_isNoneRepeat) {
      return '无重复';
    }
    if (_isDailySelected) {
      return '每日';
    }
    if (_isMonthSelected) {
      return '每月';
    }
    if (_isYearSelected) {
      return '每年';
    }
    final buffer = <String>[];
    if (_selectedWeekDay & _allWeekMask == _allWeekMask) {
      return '每日';
    }
    if (_selectedWeekDay & _weekdayMask == _weekdayMask) {
      int i = 7;
      while (i > 5) {
        if (_selectedWeekDay & (1 << i) != 0) {
          buffer.add(getWeekName(i));
        }
        i--;
      }
      buffer.add('工作日');
      return buffer.reversed.join('、');
    }
    if (_selectedWeekDay & _weekendMask == _weekendMask) {
      buffer.add('周末');
      int i = 5;
      while (i > 0) {
        if (_selectedWeekDay & (1 << i) != 0) {
          buffer.add(getWeekName(i));
        }
        i--;
      }
      return buffer.reversed.join('、');
    }
    int i = 7;
    while (i > 0) {
      if (_selectedWeekDay & (1 << i) != 0) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.times,
            color: Color(0xFFD7CAFF),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '设置重复',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '完成',
              style: TextStyle(fontSize: 16.0, color: Color(0xFFEDE7FF)),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ListView(
            padding: const EdgeInsets.only(top: 15.0, bottom: 50.0),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        FontAwesomeIcons.solidCircle,
                        color: Color(0xFFFAB807),
                        size: 8,
                      ),
                      const SizedBox(
                        width: 11.5,
                      ),
                      const Text(
                        '重复周期',
                        style:
                            TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                      ),
                    ],
                  ),
                  Text(
                    _makeLabel(),
                    style: TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                  ),
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              FlippingTile(
                title: "无重复",
                selected: _isNoneRepeat,
                onTap: () {
                  setState(() {
                    _isNoneRepeat = true;
                    _isWeekSelected = false;
                    _isMonthSelected = false;
                    _isYearSelected = false;
                    _isDailySelected = false;
                  });
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              FlippingTile(
                title: "每日",
                selected: _isDailySelected,
                onTap: () {
                  setState(() {
                    _isNoneRepeat = false;
                    _isWeekSelected = false;
                    _isMonthSelected = false;
                    _isYearSelected = false;
                    _isDailySelected = true;
                  });
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              FlippingTile.extended(
                title: "每周",
                selected: _isWeekSelected,
                onTap: () {
                  setState(() {
                    _isNoneRepeat = false;
                    _isWeekSelected = true;
                    _isMonthSelected = false;
                    _isYearSelected = false;
                    _isDailySelected = false;
                  });
                },
                extend: Row(
                  children: weekMapShort.entries.map((entry) {
                    final selected = (1 << entry.key) & _selectedWeekDay != 0;
                    final selectedLast =
                        (1 << entry.key) & _selectedWeekDayLast != 0;
                    var colorIndex = selectedLast ? 0 : 1;

                    return Expanded(
                      child: TapAnimator(
                        duration: const Duration(milliseconds: 200),
                        builder: (factor) {
                          if (factor == 1.0) {
                            _selectedWeekDayLast = _selectedWeekDay;
                            colorIndex = selected ? 0 : 1;
                          }
                          return Container(
                            height: 50.0,
                            alignment: Alignment.center,
                            color: _colorList[colorIndex]
                                .withOpacity(1.0 - factor),
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                            ),
                          );
                        },
                        onTap: () {
                          setState(() {
                            _selectedWeekDayLast = _selectedWeekDay;
                            if (selected) {
                              _selectedWeekDay &= ~(1 << entry.key);
                            } else {
                              _selectedWeekDay |= (1 << entry.key);
                            }
                          });
                        },
                        onComplete: () {
                          setState(() {});
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              FlippingTile(
                title: "每月",
                selected: _isMonthSelected,
                onTap: () {
                  setState(() {
                    _isNoneRepeat = false;
                    _isWeekSelected = false;
                    _isMonthSelected = true;
                    _isYearSelected = false;
                    _isDailySelected = false;
                  });
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              FlippingTile(
                title: "每年",
                selected: _isYearSelected,
                onTap: () {
                  setState(() {
                    _isNoneRepeat = false;
                    _isWeekSelected = false;
                    _isMonthSelected = false;
                    _isYearSelected = true;
                    _isDailySelected = false;
                  });
                },
              ),
              const SizedBox(
                height: 45.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        FontAwesomeIcons.solidCircle,
                        color: Color(0xFFFAB807),
                        size: 8,
                      ),
                      const SizedBox(
                        width: 11.5,
                      ),
                      const Text(
                        '结束',
                        style:
                            TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                      ),
                    ],
                  ),
                  Text(
                    _makeEndLabel(),
                    style: TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              FlippingTile(
                selected: _isNeverEnd,
                title: '永不结束',
                onTap: () {
                  setState(() {
                    _isNeverEnd = true;
                    _isCountEnd = false;
                  });
                },
              ),
              const SizedBox(height: 10.0),
              FlippingTile.extended(
                selected: _isCountEnd,
                title: _isCountEnd ? '重复 $_count 次后' : '一定次数',
                extend: Container(
                  height: 50.0,
                  color: const Color(0xFFE6A800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TapAnimator(
                        behavior: HitTestBehavior.opaque,
                        builder: (factor) => Icon(
                          FontAwesomeIcons.caretLeft,
                          color: Colors.white.withOpacity(1.0 - 0.3 * factor),
                        ),
                        onTap: () {
                          if (_count > 1) {
                            setState(() {
                              _count--;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Text(
                        '$_count 次',
                        style: TextStyle(fontSize: 15.0, color: Colors.white),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      TapAnimator(
                        behavior: HitTestBehavior.opaque,
                        builder: (factor) => Icon(FontAwesomeIcons.caretRight,
                            color:
                                Colors.white.withOpacity(1.0 - 0.3 * factor)),
                        onTap: () {
                          setState(() {
                            _count++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    _isNeverEnd = false;
                    _isCountEnd = true;
                  });
                },
              ),
            ],
          )),
    );
  }
}
