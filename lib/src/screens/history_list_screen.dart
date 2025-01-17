import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/timeline_list.dart';
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/interfaces/mixins/app_lifecycle_resume_provider.dart';
import 'package:yide/src/interfaces/mixins/navigatable_without_menu.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/common_tools.dart';
import 'package:yide/src/config.dart' as Config;
import 'package:yide/src/tools/sqlite_manager.dart';

import 'detail_list_screen.dart';

class HistoryListScreen extends StatefulWidget with NavigatableWithOutMenu {
  final _HistoryListScreenController _controller =
      _HistoryListScreenController();
  @override
  _HistoryListScreenState createState() => _HistoryListScreenState(_controller);

  @override
  FutureOr<void> onDragPrevious(BuildContext context, double offset) {
    PopRouteNotification().dispatch(context);
    //haptic();
  }

  @override
  void onTransitionValueChange(double value) {
    _controller.updateTransitionValue(value);
  }

  @override
  String get name => '日志';
}

class _HistoryListScreenController {
  List<_TranslateContainerState> _transStates = [];

  void updateTransitionValue(double value) {
    _transStates.forEach((state) => state.offset = value);
  }
}

class _HistoryListScreenState extends State<HistoryListScreen>
    with AppLifecycleResumeProvider {
  _HistoryListScreenState(this._controller);

  _HistoryListScreenController _controller;

  Widget _placeholder = Container(
    alignment: Alignment.topCenter,
    height: 300.0,
    width: 300.0,
    child: Config.listPlaceholder,
  );
  Widget _blank = const SizedBox();

  List<TaskPack>? _todayList;
  List<TaskPack>? _yestodyList;
  Map<DateTime, List<TaskPack>>? _monthList;
  Map<int, List<TaskPack>>? _yearsList;

  bool _isLoadingValue = false;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    setState(() {
      _isLoadingValue = value;
    });
  }

  Future<void> _update() async {
    _isLoading = true;
    final now = DateTime.now();
    final yestoday = now.subtract(Duration(days: 1));
    final list = await TaskDBAction.getTaskListFinished() ?? [];
    _todayList?.clear();
    _yestodyList?.clear();
    _monthList?.clear();
    _yearsList?.clear();
    for (var item in list) {
      final finishTime = item.data?.finishTime;
      if (_isSameDay(finishTime, now)) {
        _todayList ??= [];
        _todayList?.add(item);
      } else if (_isSameDay(finishTime, yestoday)) {
        _yestodyList ??= [];
        _yestodyList?.add(item);
      } else if (finishTime?.year == now.year) {
        _monthList ??= LinkedHashMap();
        final sectionTime = DateTime(
            finishTime?.year ?? now.year, finishTime?.month ?? now.month);
        if (!(_monthList?.containsKey(sectionTime) ?? false)) {
          _monthList?[sectionTime] = [];
        }
        _monthList?[sectionTime]?.add(item);
      } else {
        _yearsList ??= LinkedHashMap();
        final sectionYear = finishTime?.year;
        if (!(_yearsList?.containsKey(sectionYear) ?? false)) {
          _yearsList?[sectionYear ?? now.year] = [];
        }
        _yearsList?[sectionYear]?.add(item);
      }
    }

    _isLoading = false;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    return a?.year == b?.year && a?.month == b?.month && a?.day == b?.day;
  }

  @override
  void initState() {
    super.initState();
    _update();
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
        child: Column(
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
                    lastRouteName,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: const Color(0xFFEDE7FF),
                    ),
                  ),
                ],
              ),
              onLeadingAction: () => PopRouteNotification().dispatch(context),
              actionIcon: _isLoading
                  ? CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: Brightness.dark,
                      ),
                      child: CupertinoActivityIndicator(),
                    )
                  : const SizedBox(),
              title: widget.name,
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
      ),
    );
  }

  Widget _buildSectionList() {
    final slivers = <Widget>[];
    if (_todayList != null && (_todayList?.isNotEmpty ?? false)) {
      slivers.add(_buildHeader('今天'));
      final subList = SliverFixedExtentList(
        itemExtent: 65.0,
        delegate: SliverChildBuilderDelegate(_taskItemBuilder(_todayList),
            childCount: _todayList?.length),
      );
      slivers.add(subList);
    }
    if (_yestodyList != null && (_yestodyList?.isNotEmpty ?? false)) {
      slivers.add(_buildHeader('昨天'));
      final subList = SliverFixedExtentList(
        itemExtent: 65.0,
        delegate: SliverChildBuilderDelegate(_taskItemBuilder(_yestodyList),
            childCount: _yestodyList?.length),
      );
      slivers.add(subList);
    }
    if (_monthList != null && (_monthList?.isNotEmpty ?? false)) {
      _monthList?.forEach((section, list) {
        slivers.add(_buildHeader(DateFormat.MMMM('zh').format(section)));
        final subList = SliverFixedExtentList(
          itemExtent: 65.0,
          delegate: SliverChildBuilderDelegate(_taskItemBuilder(list),
              childCount: list.length),
        );
        slivers.add(subList);
      });
    }
    if (_yearsList != null && (_yearsList?.isNotEmpty ?? false)) {
      _yearsList?.forEach((section, list) {
        slivers.add(_buildHeader('$section年'));
        final subList = SliverFixedExtentList(
          itemExtent: 65.0,
          delegate: SliverChildBuilderDelegate(_taskItemBuilder(list),
              childCount: list.length),
        );
        slivers.add(subList);
      });
    }
    if (slivers.isEmpty) {
      return _isLoading ? _blank : _placeholder;
    }
    return CustomScrollView(
      slivers: slivers,
    );
  }

  SliverToBoxAdapter _buildHeader(String label) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(bottom: 1.0),
        margin: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0x88FFFFFF),
              width: 0.3,
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFC9A2F5),
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  IndexedWidgetBuilder _taskItemBuilder(List<TaskPack>? list) {
    return (context, index) {
      final pack = list?[index];
      final infoRow = <Widget>[
        Icon(
          FontAwesomeIcons.solidCircle,
          color: pack?.tag?.iconColor,
          size: 8.0,
        ),
        const SizedBox(
          width: 8.0,
        ),
        Text(
          pack?.tag?.name ?? '默认',
          style: TextStyle(color: pack?.tag?.iconColor, fontSize: 12.0),
        ),
        const SizedBox(
          width: 15.0,
        ),
        Text(
          '于 ${DateFormat("yyyy/MM/dd HH:mm").format(pack?.data?.finishTime ?? DateTime.now())} 完成',
          style: const TextStyle(
            color: Color(0xFFC9A2F5),
            fontSize: 12.0,
          ),
        ),
      ];
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.ideographic,
        children: <Widget>[
          const SizedBox(
            width: 15.0,
          ),
          Text(
            DateFormat('MM/dd', 'zh')
                .format(pack?.data?.finishTime ?? DateTime.now()),
            style: const TextStyle(
              color: Color(0x88C9A2F5),
              fontSize: 12.0,
            ),
          ),
          Expanded(
            child: TimelineTile(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 15.0, bottom: 0.0),
              onTap: () => _enterDetail(pack),
              onLongPress: () {
                detailPopup(
                  context,
                  onDetail: () => _enterDetail(pack),
                  onDone: () async {
                    await TaskDBAction.toggleTaskFinish(
                        pack?.data?.id, true, DateTime.now());
                    _update();
                  },
                  onReactive: () async {
                    await TaskDBAction.toggleTaskFinish(
                        pack?.data?.id, false, DateTime.now());
                    _update();
                  },
                  onDelete: () async {
                    await TaskDBAction.deleteTask(pack?.data);
                    _update();
                  },
                  isDone: true,
                );
              },
              rows: <Widget>[
                Text(
                  pack?.data?.content ?? '',
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
            ),
          ),
        ],
      );
    };
  }

  Future<TaskPack> _enterDetail(TaskPack? item) {
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
  final _HistoryListScreenController controller;

  const _TranslateContainer({
    super.key,
    required this.initOffset,
    required this.child,
    required this.controller,
  });
  @override
  _TranslateContainerState createState() => _TranslateContainerState();
}

class _TranslateContainerState extends State<_TranslateContainer> {
  double? _offsetValue;
  double? get offset => _offsetValue;
  set offset(double? value) => setState(() => _offsetValue = value);

  late _HistoryListScreenController _controller;

  @override
  void initState() {
    super.initState();
    _offsetValue = widget.initOffset;
    _controller = widget.controller;
    _controller._transStates.add(this);
  }

  @override
  Widget build(BuildContext context) {
    final offsetObject = isScreenTransitionVertical
        ? Offset(0.0, offset ?? 0)
        : Offset(offset ?? 0, 0.0);
    return FractionalTranslation(
      translation: offsetObject,
      child: widget.child,
    );
  }
}
