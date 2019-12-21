import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/add_button_positioned.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/slide_drag_detector.dart';
import 'package:yide/src/components/timeline_list.dart';
import 'package:yide/src/config.dart' as Config;
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/common_tools.dart';
import 'package:yide/src/tools/icon_tools.dart';
import 'package:yide/src/tools/sqlite_manager.dart';

import 'detail_list_screen.dart';
import 'edit_main_screen.dart';

class MultipleDayListScreen extends StatefulWidget implements Navigatable {
  final MultipleDayController controller = MultipleDayController();

  @override
  _MultipleDayListScreenState createState() =>
      _MultipleDayListScreenState(controller);

  @override
  Route get route => PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) {
          anim2.addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              singleDayController.setVerticalMove(false);
            }
          });
          return this;
        },
        transitionDuration: Duration(milliseconds: 1000),
        transitionsBuilder: (context, anim1, anim2, child) {
          final anim1Curved = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: anim1,
              curve: const ElasticOutCurve(1.0),
              reverseCurve: const ElasticInCurve(1.0),
            ),
          );
          final anim2Curved = const ElasticInCurve(1.0).transform(anim2.value);
          controller.updateTransition(1 - anim1Curved.value - anim2Curved);
          return FadeTransition(
            opacity: anim1Curved,
            child: child,
          );
        },
      );

  @override
  bool get withMene => false;
}

class MultipleDayController {
  List<_TranslateContainerState> _transStates = List();

  void updateTransition(double value) {
    _transStates.forEach((state) => state.offset = value);
  }
}

class _MultipleDayListScreenState extends State<MultipleDayListScreen> {
  _MultipleDayListScreenState(this._controller);

  MultipleDayController _controller;

  bool _isLoadingValue = false;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    setState(() {
      _isLoadingValue = value;
    });
  }

  ScrollController _scrollController;

  double _dragOffset = 0.0;
  bool _isPoping = false;

  static const _cellHeight = 65.0;
  static const _headerHeight = 45.0;
  static const _headerGap = 8.0;

  Map<DateTime, List<TaskPack>> _listData = LinkedHashMap();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: false);
    _update();
    _controller ??= MultipleDayController();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _controller._transStates.clear();
    super.dispose();
  }

  Future<void> _update() async {
    _isLoading = true;
    final list = await TaskDBAction.getTaskListAfterDate(DateTime.now());
    _listData.clear();
    for (var item in list) {
      final taskTime = item.data.taskTime;
      final sectionTime = DateTime(taskTime.year, taskTime.month, taskTime.day);
      if (!_listData.containsKey(sectionTime)) {
        _listData[sectionTime] = List();
      }
      _listData[sectionTime].add(item);
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: Config.backgroundGradient,
        ),
        child: SlideDragDetector(
          leftBarrier: 0.0,
          leftSecondBarrier: 0.0,
          rightBarrier: 1.0,
          onUpdate: (frac) {
            setState(() {
              frac = frac * 0.5;
              _dragOffset = frac - frac * frac * frac;
            });
          },
          onStartDrag: () => _isPoping = false,
          onRightDragEnd: (f) {
            if (_isPoping) return;
            PopRouteNotification().dispatch(context);
            haptic();
            _isPoping = true;
          },
          onRightMoveHalf: (f) {
            if (_isPoping) return;
            PopRouteNotification().dispatch(context);
            haptic();
            _isPoping = true;
          },
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  HeaderBar(
                    indent: 10.0,
                    endIndet: 15.0,
                    leadingIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          CupertinoIcons.left_chevron,
                          size: 26.0,
                          color: const Color(0xFFEDE7FF),
                        ),
                        Text(
                          '今日',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: const Color(0xFFEDE7FF),
                          ),
                        ),
                      ],
                    ),
                    onLeadingAction: () =>
                        PopRouteNotification().dispatch(context),
                    actionIcon: _isLoading
                        ? CupertinoTheme(
                            data: CupertinoThemeData(
                              brightness: Brightness.dark,
                            ),
                            child: CupertinoActivityIndicator(),
                          )
                        : const Text(
                            '编辑',
                            style: TextStyle(
                                fontSize: 16.0, color: Color(0xFFD7CAFF)),
                          ),
                    title: '日程',
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Expanded(
                    child: FractionalTranslation(
                      translation: Offset(_dragOffset, 0.0),
                      child: _TranslateContainer(
                        initOffset: 0.0,
                        controller: _controller,
                        child: _buildSectionList(),
                      ),
                    ),
                  )
                ],
              ),
              AddButtonPositioned(
                onPressed: () async {
                  isScreenTransitionVertical = true;
                  PushRouteNotification(
                    EditMainScreen(),
                    callback: (pack) async {
                      final newTask = pack as TaskPack;
                      if (newTask != null) {
                        await TaskDBAction.saveTask(newTask.data);
                        _update();
                      }
                    },
                  ).dispatch(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionList() {
    final weekdayFormatter = DateFormat('EEE', 'zh');
    final monthFormatter = DateFormat('MMMM', 'zh');
    final dateFormatter = DateFormat('dd日', 'zh');
    final dateFormatterWithMonth = DateFormat('MM月dd日', 'zh');
    final dateFormatterWithYear = DateFormat('yyyy年MM月dd日', 'zh');
    final yearFormatter = DateFormat('yyyy年', 'zh');
    final now = DateTime.now();
    final slivers = <Widget>[];
    DateTime date = now;
    for (var i = 1; i <= 7; i++) {
      date = DateTime(now.year, now.month, now.day + i);
      final isTomorrow = i == 1;
      final weekdayLabel = isTomorrow ? '明天' : weekdayFormatter.format(date);
      final dateLabel = (() {
        if (date.year != now.year) {
          return dateFormatterWithYear.format(date);
        }
        if (date.month != now.month) {
          return dateFormatterWithMonth.format(date);
        }
        return dateFormatter.format(date);
      })();
      final weekHeader = _buildWeekDayHeader(weekdayLabel, dateLabel);
      slivers.add(
        SliverPadding(
          sliver: weekHeader,
          padding: const EdgeInsets.only(
              top: _headerGap, bottom: _headerGap, left: 20.0),
        ),
      );
      final innerListData = _listData[date];
      if (innerListData != null && innerListData.isNotEmpty) {
        final cellCount = innerListData.length;
        final innerList = SliverFixedExtentList(
          itemExtent: _cellHeight,
          delegate: SliverChildBuilderDelegate(
            _taskItemBuilder(innerListData),
            childCount: cellCount,
          ),
        );
        slivers.add(
          SliverPadding(
            sliver: innerList,
            padding: const EdgeInsets.only(left: 0.0, right: 20.0),
          ),
        );
      } else {
        slivers.add(
          const SliverToBoxAdapter(
            child: SizedBox(
              height: _cellHeight,
            ),
          ),
        );
      }
    }
    slivers.add(
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 30.0,
        ),
      ),
    );
    date = date.add(Duration(days: 1));
    DateTime monthDate;
    final leftEntries = _listData.entries.where(
        (entry) => entry.key.isAfter(date) || entry.key.isAtSameMomentAs(date));
    for (var i = 0; i < 3; i++) {
      final isCurrentMonth = i == 0;
      final isDayShown = isCurrentMonth && date.day != 1;
      monthDate = DateTime(date.year, date.month + i);
      final monthLabel = monthFormatter.format(monthDate);
      final dayLabel = isDayShown
          ? dateFormatter.format(date) +
              ' - ' +
              dateFormatter.format(
                DateTime(date.year, date.month).subtract(
                  Duration(days: 1),
                ),
              )
          : '';
      final yearLabel =
          monthDate.year != now.year ? yearFormatter.format(monthDate) : '';
      final monthHeader = _buildMonthHeader(monthLabel, dayLabel, yearLabel);
      slivers.add(
        SliverPadding(
          sliver: monthHeader,
          padding: const EdgeInsets.only(
              top: _headerGap, bottom: _headerGap, left: 20.0),
        ),
      );
      final monthListData = leftEntries
          .where((entry) =>
              entry.key.year == monthDate.year &&
              entry.key.month == monthDate.month)
          .map((entry) => entry.value)
          .expand((list) => list)
          .toList();
      if (monthListData != null && monthListData.isNotEmpty) {
        final cellCount = monthListData.length;
        final innerList = SliverFixedExtentList(
          itemExtent: _cellHeight,
          delegate: SliverChildBuilderDelegate(
            _taskItemBuilder(monthListData, isDateShow: true),
            childCount: cellCount,
          ),
        );
        slivers.add(
          SliverPadding(
            sliver: innerList,
            padding: const EdgeInsets.only(left: 0.0, right: 20.0),
          ),
        );
      } else {
        slivers.add(
          const SliverToBoxAdapter(
            child: SizedBox(
              height: _cellHeight,
            ),
          ),
        );
      }
    }
    slivers.add(
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 30.0,
        ),
      ),
    );
    var lastDate = DateTime(monthDate.year, monthDate.month + 1);
    final lastEntries = _listData.entries.where((entry) =>
        entry.key.isAfter(lastDate) || entry.key.isAtSameMomentAs(lastDate));
    final yearMap = Map<int, List<TaskPack>>();
    lastEntries.forEach((entry) {
      final year = entry.key.year;
      if (yearMap.containsKey(year)) {
        yearMap[year].addAll(entry.value);
      } else {
        yearMap[year] = List<TaskPack>()..addAll(entry.value);
      }
    });
    final fromLabel = lastDate.month != DateTime.january
        ? '从${monthFormatter.format(lastDate)}开始'
        : '';
    final currentYearHeader =
        _buildYearHeader(yearFormatter.format(lastDate), fromLabel);
    slivers.add(
      SliverPadding(
        sliver: currentYearHeader,
        padding: const EdgeInsets.only(
            top: _headerGap, bottom: _headerGap, left: 20.0),
      ),
    );
    if (yearMap.containsKey(lastDate.year)) {
      final yearListData = yearMap[lastDate.year];
      final cellCount = yearListData.length;
      final innerList = SliverFixedExtentList(
        itemExtent: _cellHeight,
        delegate: SliverChildBuilderDelegate(
          _taskItemBuilder(yearListData, isDateShow: true),
          childCount: cellCount,
        ),
      );
      slivers.add(
        SliverPadding(
          sliver: innerList,
          padding: const EdgeInsets.only(left: 0.0, right: 20.0),
        ),
      );
    } else {
      slivers.add(
        const SliverToBoxAdapter(
          child: SizedBox(
            height: _cellHeight,
          ),
        ),
      );
    }
    final leftYearEntries = yearMap.entries
        .where((entry) => entry.key > lastDate.year)
        .toList()
          ..sort((a, b) => a.key - b.key);
    leftYearEntries.forEach((entry) {
      final currentYearHeader =
          _buildYearHeader(yearFormatter.format(DateTime(entry.key)), '');
      slivers.add(
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 20.0,
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          sliver: currentYearHeader,
          padding: const EdgeInsets.only(
              top: _headerGap, bottom: _headerGap, left: 20.0),
        ),
      );
      final yearListData = entry.value;
      final cellCount = yearListData.length;
      final innerList = SliverFixedExtentList(
        itemExtent: _cellHeight,
        delegate: SliverChildBuilderDelegate(
          _taskItemBuilder(yearListData, isDateShow: true),
          childCount: cellCount,
        ),
      );
      slivers.add(
        SliverPadding(
          sliver: innerList,
          padding: const EdgeInsets.only(left: 0.0, right: 20.0),
        ),
      );
    });
    slivers.add(
      const SliverToBoxAdapter(
        child: SizedBox(
          height: 60.0,
        ),
      ),
    );
    final view = CustomScrollView(
      controller: _scrollController,
      slivers: slivers,
    );
    return view;
  }

  SliverToBoxAdapter _buildWeekDayHeader(
      String weekdayLabel, String dateLabel) {
    return SliverToBoxAdapter(
      child: Container(
        alignment: Alignment.centerLeft,
        height: _headerHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          children: <Widget>[
            Text(
              weekdayLabel,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w200,
                color: const Color(0xDDFFFFFF),
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Container(
                height: 20.0,
                margin: const EdgeInsets.only(right: 20.0),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: const Color(0x88FFFFFF),
                      width: 0.3,
                    ),
                  ),
                ),
                child: Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300,
                    color: const Color(0x66FFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMonthHeader(
      String monthLabel, String dayLabel, String yearLabel) {
    final labels = <Widget>[
      Text(
        monthLabel,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w200,
          color: const Color(0xDDFFFFFF),
        ),
      ),
    ];
    if (dayLabel.isNotEmpty) {
      labels
        ..add(const SizedBox(width: 8.0))
        ..add(
          Text(
            dayLabel,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w300,
              color: const Color(0x66FFFFFF),
            ),
          ),
        );
    }
    if (yearLabel.isNotEmpty) {
      labels
        ..add(const SizedBox(width: 8.0))
        ..add(
          Text(
            yearLabel,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w300,
              color: const Color(0x66FFFFFF),
            ),
          ),
        );
    }
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(top: 1.0),
        alignment: Alignment.topLeft,
        height: _headerHeight * 16.0 / 22.0,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0x88FFFFFF),
              width: 0.3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          verticalDirection: VerticalDirection.up,
          children: labels,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildYearHeader(String yearLabel, String fromLabel) {
    final labels = <Widget>[
      Text(
        yearLabel,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w200,
          color: const Color(0xDDFFFFFF),
        ),
      ),
    ];
    if (fromLabel.isNotEmpty) {
      labels
        ..add(const SizedBox(width: 8.0))
        ..add(
          Text(
            fromLabel,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w300,
              color: const Color(0x66FFFFFF),
            ),
          ),
        );
    }
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(top: 1.0),
        alignment: Alignment.topLeft,
        height: _headerHeight * 16.0 / 22.0,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0x88FFFFFF),
              width: 0.3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          verticalDirection: VerticalDirection.up,
          children: labels,
        ),
      ),
    );
  }

  IndexedWidgetBuilder _taskItemBuilder(List<TaskPack> list,
      {bool isDateShow = false}) {
    return (context, index) {
      final pack = list[index];
      final infoRow = <Widget>[
        Icon(
          FontAwesomeIcons.solidCircle,
          color: pack.tag.iconColor,
          size: 8.0,
        ),
        const SizedBox(
          width: 8.0,
        ),
        Text(
          pack.tag.name ?? '默认',
          style: TextStyle(color: pack.tag.iconColor, fontSize: 12.0),
        ),
        const SizedBox(
          width: 20.0,
        ),
      ];
      if (isDateShow) {
        infoRow
          ..add(
            Text(
              DateFormat('yyyy.MM.dd', 'zh').format(pack.data.taskTime),
              style: const TextStyle(
                color: Color(0xFFC9A2F5),
                fontSize: 12.0,
              ),
            ),
          )
          ..add(
            const SizedBox(
              width: 20.0,
            ),
          );
      }
      infoRow.addAll([
        Icon(
          buildCupertinoIconData(0xf402),
          color: const Color(0xFFC9A2F5),
          size: 12.0,
        ),
        const SizedBox(
          width: 5.0,
        ),
        Text(
          _makeTimeLabel(pack.data),
          style: const TextStyle(
            color: Color(0xFFC9A2F5),
            fontSize: 12.0,
          ),
        ),
      ]);
      return TimelineTile(
        padding: const EdgeInsets.only(left: 42.0, bottom: 0.0),
        onTap: () async {
          singleDayController.setVerticalMove(true);
          PushRouteNotification(
            DetailListScreen(taskPack: pack),
            callback: (pack) {
              _update();
            },
          ).dispatch(context);
        },
        rows: <Widget>[
          Text(
            pack.data.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD7CAFF),
              fontSize: 15.0,
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: infoRow,
          ),
        ],
      );
    };
  }

  String _makeTimeLabel(TaskData data) {
    switch (data?.timeType) {
      case DateTimeType.fullday:
        return '全天';
      case DateTimeType.someday:
        return '某天';
      case DateTimeType.datetime:
        final date = data?.taskTime;
        return date == null || date.millisecondsSinceEpoch == 0
            ? ' - '
            : DateFormat('HH:mm').format(date);
      default:
        return ' - ';
    }
  }
}

class _TranslateContainer extends StatefulWidget {
  final double initOffset;
  final Widget child;
  final MultipleDayController controller;

  const _TranslateContainer({
    Key key,
    this.initOffset,
    @required this.child,
    this.controller,
  }) : super(key: key);
  @override
  _TranslateContainerState createState() => _TranslateContainerState();
}

class _TranslateContainerState extends State<_TranslateContainer> {
  double _offsetValue;
  double get offset => _offsetValue;
  set offset(double value) => setState(() => _offsetValue = value);

  MultipleDayController _controller;

  @override
  void initState() {
    super.initState();
    _offsetValue = widget.initOffset ?? 0.0;
    _controller = widget.controller ?? MultipleDayController();
    _controller._transStates.add(this);
  }

  @override
  Widget build(BuildContext context) {
    final offsetObject =
        isScreenTransitionVertical ? Offset(0.0, offset) : Offset(offset, 0.0);
    return FractionalTranslation(
      translation: offsetObject,
      child: widget.child,
    );
  }
}
