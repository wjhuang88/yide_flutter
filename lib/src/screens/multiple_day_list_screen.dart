import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tableview/flutter_tableview.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/timeline_list.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/sqlite_manager.dart';

import 'detail_list_screen.dart';

class MultipleDayListScreen extends StatefulWidget implements Navigatable {
  @override
  _MultipleDayListScreenState createState() => _MultipleDayListScreenState();

  @override
  Route get route => PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => this,
        transitionDuration: Duration(milliseconds: 400),
        transitionsBuilder: (context, anim1, anim2, child) {
          final anim1Curved = Tween<double>(begin: 0.0, end: 1.0)
              .animate(
                CurvedAnimation(
                  parent: anim1,
                  curve: const ElasticOutCurve(1.0),
                  reverseCurve: Curves.easeInToLinear,
                ),
              )
              .value;
          final anim2Curved = const ElasticInCurve(1.0).transform(anim2.value);
          return Opacity(
            opacity: anim1Curved.clamp(0.0, 1.0),
            child: Transform.scale(
              alignment: Alignment.centerRight,
              scale: anim1Curved,
              child: FractionalTranslation(
                translation: Offset(-anim2Curved, 0.0),
                child: child,
              ),
            ),
          );
        },
      );

  @override
  bool get withMene => false;
}

class _MultipleDayListScreenState extends State<MultipleDayListScreen> {
  bool _isLoadingValue = false;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    setState(() {
      _isLoadingValue = value;
    });
  }

  ScrollController _scrollController;

  static const _cellHeight = 110.0;
  static const _headerHeight = 35.0;

  Map<DateTime, List<TaskPack>> _listData = LinkedHashMap();
  Iterable<DateTime> get _sectionKeys => _listData.keys;
  Iterable<int> get _sectionCount =>
      _sectionKeys.map((date) => _listData[date].length);

  int _todaySection = 0;
  double get _todayOffset {
    if (_todaySection <= 0) {
      return 0.0;
    }
    var cellCount =
        _sectionCount.take(_todaySection - 1).reduce((a, b) => a + b);
    return _cellHeight * cellCount + (_todaySection - 1) * _headerHeight;
  }

  Future<void> _updating;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: true);
    _updating = _update();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    _isLoading = true;
    final list = await TaskDBAction.getTaskListByPage(0, 100);
    _listData.clear();
    var sectionCount = 0;
    final now = DateTime.now();
    for (var item in list) {
      final taskTime = item.data.taskTime;
      final sectionTime = DateTime(taskTime.year, taskTime.month, taskTime.day);
      if (!_listData.containsKey(sectionTime)) {
        _listData[sectionTime] = List();
        sectionCount++;
      }
      if (taskTime.year == now.year &&
          taskTime.month == now.month &&
          taskTime.day == now.day) {
        _todaySection = sectionCount;
      }
      _listData[sectionTime].add(item);
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final _sections = _sectionKeys.toList();
    final _counts = _sectionCount.toList();

    return CupertinoPageScaffold(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Column(
          children: <Widget>[
            HeaderBar(
              leadingIcon: const Icon(
                CupertinoIcons.left_chevron,
                color: Color(0xFFD7CAFF),
                size: 30.0,
              ),
              actionIcon: _isLoading
                  ? CupertinoActivityIndicator()
                  : const Text(
                      '编辑',
                      style:
                          TextStyle(fontSize: 16.0, color: Color(0xFFD7CAFF)),
                    ),
              onLeadingAction: () => PopRouteNotification().dispatch(context),
              title: '日程',
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: _sections.length > 0
                  ? _buildSectionList(_sections, _counts)
                  : const SizedBox(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionList(List<DateTime> _sections, List<int> _counts) {
    final formatterNoYear = DateFormat('MM月dd日 EEE', 'zh');
    final formatterWithYear = DateFormat('yyyy年MM月dd日 EEE', 'zh');
    final now = DateTime.now();
    final view = FlutterTableView(
      controller: _scrollController,
      listViewFatherWidgetBuilder: (context, list) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: list,
        );
      },
      sectionCount: _sections.length,
      rowCountAtSection: (i) => _listData[_sections[i]].length,
      sectionHeaderBuilder: (context, i) {
        final time = _sections[i];
        final timeLabel = time.year == now.year
            ? formatterNoYear.format(time)
            : formatterWithYear.format(time);
        return Container(
          padding: const EdgeInsets.only(left: 15.0),
          alignment: Alignment.centerLeft,
          color: Color(0xFF9051DC),
          child: Text(
            timeLabel,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w200),
          ),
        );
      },
      sectionHeaderHeight: (context, i) => _headerHeight,
      cellBuilder: (context, section, row) {
        final pack = _listData[_sections[section]][row];
        final firstMargin =
            row == 0 ? const EdgeInsets.only(top: 15.0) : EdgeInsets.zero;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(
            margin: firstMargin,
            child: TimelineDecorated(
              decorationColor: pack.tag.iconColor,
              isBorderShow: row + 1 != _counts[section],
              child: TimelineTile(
                onTap: () async {
                  PushRouteNotification(
                    DetailListScreen(taskPack: pack),
                    callback: (pack) {
                      _update();
                    },
                  ).dispatch(context);
                },
                rows: <Widget>[
                  Text(
                    _makeTimeLabel(pack.data),
                    style: const TextStyle(
                      color: Color(0xFFC9A2F5),
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
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
                  Text(
                    pack.tag.name ?? '默认',
                    style: TextStyle(color: pack.tag.iconColor, fontSize: 12.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      cellHeight: (context, section, row) => _cellHeight,
    );
    _updating?.then(
      (f) {
        if (_scrollController.offset == 0) {
          _scrollController
              .jumpTo(_todayOffset - MediaQuery.of(context).size.height / 4);
        }
      },
    );
    return view;
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
            : DateFormat('h:mm a').format(date);
      default:
        return ' - ';
    }
  }
}
