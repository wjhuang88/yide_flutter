import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/components/flipping_tile.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/tap_animator.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/common_tools.dart';
import 'package:yide/src/tools/date_tools.dart';
import 'package:yide/src/models/task_data.dart';

class DetailRepeatScreen extends StatefulWidget implements Navigatable {
  final int stateCode;

  const DetailRepeatScreen({Key key, this.stateCode = 0}) : super(key: key);
  @override
  _DetailRepeatScreenState createState() => _DetailRepeatScreenState(stateCode);

  @override
  Route get route {
    return PageRouteBuilder<int>(
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

  @override
  bool get withMene => false;
}

const _colorList = const [const Color(0xFFE6A800), const Color(0xFFBD8A00)];

class _DetailRepeatScreenState extends State<DetailRepeatScreen> {
  _DetailRepeatScreenState(int _code)
      : _repeatLastState = RepeatBitMap(bitMap: _code),
        _repeatState = RepeatBitMap(bitMap: _code);

  RepeatBitMap _repeatState;
  RepeatBitMap _repeatLastState;

  ScrollController _scrollController;
  bool _backProcessing = false;

  DateTime _countUpdateTime;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset <
          _scrollController.position.minScrollExtent - 100) {
        if (_backProcessing) {
          return;
        }
        _backProcessing = true;
        haptic();
        PopRouteNotification().dispatch(context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: Column(
        children: <Widget>[
          HeaderBar(
            leadingIcon: const Icon(
              CupertinoIcons.clear,
              color: Color(0xFFD7CAFF),
              size: 40.0,
            ),
            onLeadingAction: () => PopRouteNotification().dispatch(context),
            actionIcon: const Text(
              '完成',
              style: const TextStyle(
                  fontSize: 15.0, color: const Color(0xFFEDE7FF)),
            ),
            onAction: () {
              PopRouteNotification(result: _repeatState.bitMap)
                  .dispatch(context);
            },
            title: '设置重复',
          ),
          Expanded(
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              controller: _scrollController,
              padding: const EdgeInsets.only(
                  top: 15.0, bottom: 50.0, left: 15.0, right: 15.0),
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
                          style: TextStyle(
                              color: Color(0xFFEDE7FF), fontSize: 15.0),
                        ),
                      ],
                    ),
                    Text(
                      _repeatState.makeRepeatTimeLabel(),
                      style:
                          TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                FlippingTile(
                  title: "无重复",
                  selected: _repeatState.isNoneRepeat,
                  onTap: () {
                    setState(() {
                      _repeatState.resetSelect();
                      _repeatState.reverseNoneRepeat();
                    });
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                FlippingTile(
                  title: "每日",
                  selected: _repeatState.isDailySelected,
                  onTap: () {
                    setState(() {
                      _repeatState.resetSelect();
                      _repeatState.reverseDailySelected();
                    });
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                FlippingTile.extended(
                  title: "每周",
                  selected: _repeatState.isWeekSelected,
                  onTap: () {
                    setState(() {
                      _repeatState.resetSelect();
                      _repeatState.reverseWeekSelected();
                      _repeatState.checkAndSetMonday();
                      _repeatLastState.bitMap = _repeatState.bitMap;
                    });
                  },
                  extend: Row(
                    children: weekMapShort.entries.map((entry) {
                      final selected = _repeatState.isSelectedDay(entry.key);
                      final selectedLast =
                          _repeatLastState.isSelectedDay(entry.key);
                      var colorIndex = selectedLast ? 0 : 1;

                      return Expanded(
                        child: TapAnimator(
                          duration: const Duration(milliseconds: 200),
                          builder: (factor) {
                            if (factor == 1.0) {
                              _repeatLastState.bitMap = _repeatState.bitMap;
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
                              _repeatLastState.bitMap = _repeatState.bitMap;
                              _repeatState.checkAndNotUnselect(entry.key);
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
                  selected: _repeatState.isMonthSelected,
                  onTap: () {
                    setState(() {
                      _repeatState.resetSelect();
                      _repeatState.reverseMonthSelected();
                    });
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                FlippingTile(
                  title: "每年",
                  selected: _repeatState.isYearSelected,
                  onTap: () {
                    setState(() {
                      _repeatState.resetSelect();
                      _repeatState.reverseYearSelected();
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
                          style: TextStyle(
                              color: Color(0xFFEDE7FF), fontSize: 15.0),
                        ),
                      ],
                    ),
                    Text(
                      _repeatState.makeRepeatModeLabel(),
                      style:
                          TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                FlippingTile(
                  selected: _repeatState.isNeverEnd,
                  title: '永不结束',
                  onTap: () {
                    setState(() {
                      _repeatState.resetMode();
                      _repeatState.reverseNeverEnd();
                    });
                  },
                ),
                const SizedBox(height: 10.0),
                FlippingTile.extended(
                  selected: _repeatState.isCountEnd,
                  title: _repeatState.isCountEnd
                      ? '重复 ${_repeatState.repeatCount} 次后'
                      : '一定次数',
                  extend: GestureDetector(
                    onHorizontalDragUpdate: (detail) {
                      if (_countUpdateTime != null &&
                          DateTime.now().difference(_countUpdateTime) <
                              const Duration(milliseconds: 300)) {
                        return;
                      }
                      _countUpdateTime = DateTime.now();
                      if (detail.primaryDelta < -0.0) {
                        _repeatState.decreaseCount();
                      } else if (detail.primaryDelta > 0.0) {
                        _repeatState.increaseCount();
                      }
                      setState(() {});
                      haptic();
                    },
                    child: Container(
                      height: 50.0,
                      color: const Color(0xFFE6A800),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TapAnimator(
                            behavior: HitTestBehavior.opaque,
                            builder: (factor) => Icon(
                              FontAwesomeIcons.caretLeft,
                              color:
                                  Colors.white.withOpacity(1.0 - 0.3 * factor),
                            ),
                            onTap: () {
                              setState(() {
                                _repeatState.decreaseCount();
                              });
                            },
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            '${_repeatState.repeatCount} 次',
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.white),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          TapAnimator(
                            behavior: HitTestBehavior.opaque,
                            builder: (factor) => Icon(
                                FontAwesomeIcons.caretRight,
                                color: Colors.white
                                    .withOpacity(1.0 - 0.3 * factor)),
                            onTap: () {
                              setState(() {
                                _repeatState.increaseCount();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _repeatState.resetMode();
                      _repeatState.reverseCountEnd();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
