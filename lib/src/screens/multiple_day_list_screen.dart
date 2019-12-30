import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/add_button_positioned.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/timeline_list.dart';
import 'package:yide/src/config.dart' as Config;
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/interfaces/mixins/app_lifecycle_resume_provider.dart';
import 'package:yide/src/interfaces/mixins/navigatable_without_menu.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/screens/history_list_screen.dart';
import 'package:yide/src/tools/common_tools.dart';
import 'package:yide/src/tools/icon_tools.dart';
import 'package:yide/src/tools/sqlite_manager.dart';

import 'detail_list_screen.dart';
import 'edit_main_screen.dart';

class MultipleDayListScreen extends StatefulWidget with NavigatableWithOutMenu {
  final MultipleDayController controller = MultipleDayController();

  @override
  _MultipleDayListScreenState createState() =>
      _MultipleDayListScreenState(controller);

  @override
  FutureOr<void> onDragPrevious(BuildContext context, double offset) {
    final future = Completer();
    PopRouteNotification(callback: (d) {
      future.complete();
    }).dispatch(context);
    //haptic();
    return future.future;
  }

  @override
  bool get hasNext => true;

  @override
  FutureOr<void> onDragNext(BuildContext context, double offset) {
    final future = Completer();
    PushRouteNotification(HistoryListScreen(), callback: (d) {
      controller?.updateData();
      future.complete();
    }).dispatch(context);
    //haptic();
    return future.future;
  }

  @override
  void onTransitionValueChange(double value) {
    controller.updateTransition(value);
  }
}

class MultipleDayController {
  List<_TranslateContainerState> _transStates = List();
  _MultipleDayListScreenState _state;

  void updateTransition(double value) {
    _transStates.forEach((state) => state.offset = value);
  }

  void updateData() {
    _state?._update();
  }
}

class _MultipleDayListScreenState extends State<MultipleDayListScreen>
    with AppLifecycleResumeProvider {
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

  static const _cellHeight = 65.0;
  static const _headerHeight = 45.0;
  static const _headerGap = 8.0;

  Map<DateTime, List<TaskPack>> _listData =
      SplayTreeMap((a, b) => a.compareTo(b));

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: false);
    _update();
    _controller ??= MultipleDayController();
    _controller._state = this;
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _controller._transStates.clear();
    super.dispose();
  }

  Future<void> _update() async {
    _isLoading = true;
    final now = DateTime.now();
    final list = await TaskDBAction.getTaskListReady(now);
    final recurringList = await getRecurringTaskReady(now);
    _listData.clear();
    for (var item in list) {
      final taskTime = item.data.taskTime;
      final sectionTime = DateTime(taskTime.year, taskTime.month, taskTime.day);
      if (!_listData.containsKey(sectionTime)) {
        _listData[sectionTime] = List();
      }
      _listData[sectionTime].add(item);
    }
    recurringList.forEach((item) {
      final nextTime = item.nextTime;
      final sectionTime = DateTime(nextTime.year, nextTime.month, nextTime.day);
      if (!_listData.containsKey(sectionTime)) {
        _listData[sectionTime] = List();
      }
      _listData[sectionTime].add(item);
    });
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0x00000000),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: Config.backgroundGradient,
        ),
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
                  onAction: () {
                    PushRouteNotification(HistoryListScreen(), callback: (d) {
                      _controller.updateData();
                    }).dispatch(context);
                  },
                  actionIcon: _isLoading
                      ? CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: Brightness.dark,
                          ),
                          child: CupertinoActivityIndicator(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '日志',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: const Color(0xFFEDE7FF),
                              ),
                            ),
                            Icon(
                              CupertinoIcons.right_chevron,
                              size: 26.0,
                              color: const Color(0xFFEDE7FF),
                            ),
                          ],
                        ),
                  title: '计划',
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: _TranslateContainer(
                    initOffset: 0.0,
                    controller: _controller,
                    child: _buildSectionList(),
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
      final isFinished = pack.data.isFinished && !pack.isRecurring;
      final infoRow = <Widget>[
        Icon(
          FontAwesomeIcons.solidCircle,
          color: isFinished ? Config.finishedColor : pack.tag.iconColor,
          size: 8.0,
        ),
        const SizedBox(
          width: 8.0,
        ),
        Text(
          pack.tag.name ?? '默认',
          style: TextStyle(
              color: isFinished ? Config.finishedColor : pack.tag.iconColor,
              fontSize: 12.0),
        ),
        const SizedBox(
          width: 20.0,
        ),
      ];
      if (isDateShow) {
        infoRow
          ..add(
            Text(
              DateFormat('yyyy/MM/dd', 'zh').format(pack.data.taskTime),
              style: TextStyle(
                color: isFinished ? Config.finishedColor : Color(0xFFC9A2F5),
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
        _makeTimeIcon(pack.data),
        Text(
          _makeTimeLabel(pack.data),
          style: TextStyle(
            color: isFinished ? Config.finishedColor : Color(0xFFC9A2F5),
            fontSize: 12.0,
          ),
        ),
      ]);
      return TimelineTile(
        padding: const EdgeInsets.only(left: 42.0, bottom: 0.0),
        onTap: () => _enterDetail(pack),
        onLongPress: () {
          detailPopup(
            context,
            onDetail: () => _enterDetail(pack),
            onDone: () async {
              await TaskDBAction.toggleTaskFinish(
                  pack.data.id, true, DateTime.now());
              _update();
            },
            onDelete: () async {
              await TaskDBAction.deleteTask(pack.data);
              _update();
            },
            isDone: isFinished,
          );
        },
        rows: <Widget>[
          pack.isRecurring
              ? Transform.translate(
                  offset: const Offset(-23.0, 0.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        buildCupertinoIconData(0xf49a),
                        size: 18.0,
                        color: const Color(0xFFD7CAFF),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: _makeContentWidget(pack.data.content, isFinished),
                      ),
                    ],
                  ),
                )
              : _makeContentWidget(pack.data.content, isFinished),
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

  Widget _makeContentWidget(String content, bool isFinished) {
    return Text(
      content,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isFinished ? Config.finishedColor : Color(0xFFD7CAFF),
        fontSize: 15.0,
      ),
    );
  }

  String _makeTimeLabel(TaskData data) {
    switch (data?.timeType) {
      case DateTimeType.daytime:
        return '白天';
      case DateTimeType.night:
        return '晚间';
      case DateTimeType.datetime:
        final date = data?.taskTime;
        return date == null || date.millisecondsSinceEpoch == 0
            ? ' - '
            : DateFormat('HH:mm').format(date);
      default:
        return ' - ';
    }
  }

  Icon _makeTimeIcon(TaskData data) {
    final isFinished = data.isFinished;
    switch (data?.timeType) {
      case DateTimeType.daytime:
        return Icon(
          buildCupertinoIconData(0xf4b7),
          color: isFinished ? Config.finishedColor : const Color(0xFFC9A2F5),
          size: 16.0,
        );
      case DateTimeType.night:
        return Icon(
          buildCupertinoIconData(0xf468),
          color: isFinished ? Config.finishedColor : const Color(0xFFC9A2F5),
          size: 16.0,
        );
      default:
        return Icon(
          buildCupertinoIconData(0xf402),
          color: isFinished ? Config.finishedColor : const Color(0xFFC9A2F5),
          size: 12.0,
        );
    }
  }

  Future<TaskPack> _enterDetail(TaskPack item) {
    isScreenTransitionVertical = true;
    final future = Completer<TaskPack>();
    PushRouteNotification(
      DetailListScreen(taskPack: item),
      callback: (pack) {
        future.complete(pack);
        _update();
      },
    ).dispatch(context);
    return future.future;
  }

  @override
  void onResumed() {
    _update();
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
  void dispose() {
    _controller._transStates.remove(this);
    super.dispose();
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
