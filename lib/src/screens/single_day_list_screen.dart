import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/add_button_positioned.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/location_methods.dart';
import 'package:yide/src/components/timeline_list.dart';
import 'package:yide/src/config.dart' as Config;
import 'package:yide/src/config.dart';
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/interfaces/mixins/app_lifecycle_resume_provider.dart';
import 'package:yide/src/interfaces/mixins/navigatable_with_menu.dart';
import 'package:yide/src/screens/multiple_day_list_screen.dart';
import 'package:yide/src/tools/common_tools.dart';
import 'package:yide/src/tools/date_tools.dart';
import 'package:yide/src/models/geo_data.dart';
import 'package:yide/src/tools/sqlite_manager.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/screens/detail_list_screen.dart';
import 'package:yide/src/screens/edit_main_screen.dart';
import 'package:yide/src/tools/icon_tools.dart';

class SingleDayListScreen extends StatefulWidget with NavigatableWithMenu {
  SingleDayListScreen({Key key}) : super(key: key);

  static SingleDayScreenController controller = SingleDayScreenController();

  @override
  _SingleDayListScreenState createState() =>
      _SingleDayListScreenState(controller);

  @override
  Future<void> onDragNext(BuildContext context, double offset) async {
    final future = Completer();
    PushRouteNotification(MultipleDayListScreen(), callback: (d) {
      controller?.updateListData();
      future.complete();
    }).dispatch(context);
    haptic();
    return future.future;
  }

  @override
  void onTransitionValueChange(double value) {
    controller?.updateTransition(value);
  }
}

class _SingleDayListScreenState extends State<SingleDayListScreen>
    with AppLifecycleResumeProvider {
  _SingleDayListScreenState(this._controller);

  SingleDayScreenController _controller;

  DateTime _dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller ??= SingleDayScreenController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      child: Container(
        decoration: BoxDecoration(gradient: Config.backgroundGradient),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                HeaderBar(
                  indent: 17.0,
                  endIndet: 15.0,
                  title: '今日',
                  leadingIcon: Icon(
                    buildCupertinoIconData(0xf394),
                    color: Color(0xFFD7CAFF),
                    size: 30.0,
                  ),
                  onLeadingAction: widget.openMenu,
                  actionIcon: _ButtonAndLoadingIcon(
                    controller: _controller,
                    isLoading: true,
                  ),
                  onAction: () {
                    PushRouteNotification(MultipleDayListScreen(),
                        callback: (pack) {
                      setState(() {
                        _controller.updateListData();
                      });
                    }).dispatch(context);
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                _TranslateContainer(
                  controller: _controller,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 17.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15.0),
                    height: 182.0,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF975ED8), Color(0xFF7352D0)]),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0.0, 6.0),
                            blurRadius: 23.0,
                            color: Color(0x8A4F3A8C),
                          )
                        ]),
                    child: _HeaderPanel(
                      dateTime: _dateTime,
                      controller: _controller,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: _TranslateContainer(
                      controller: _controller,
                      child: _ListBody(
                        controller: _controller,
                        date: _dateTime,
                      )),
                ),
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
                      _controller.updateListData();
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

  @override
  void onResumed() {
    _controller?.updateListData();
  }
}

class _HeaderPanel extends StatefulWidget {
  final int taskCount;
  final int doingTaskCount;
  final DateTime dateTime;
  final SingleDayScreenController controller;

  const _HeaderPanel({
    Key key,
    this.taskCount,
    this.doingTaskCount,
    this.dateTime,
    this.controller,
  }) : super(key: key);

  @override
  _HeaderPanelState createState() => _HeaderPanelState();
}

class _HeaderPanelState extends State<_HeaderPanel> {
  String _cityName = ' - ';
  String _temp = ' - ';
  String _weather = ' - ';

  int _taskCount;
  int _doingTaskCount;
  DateTime _dateTime;

  SingleDayScreenController _controller;

  Future<void> _updateLocAndTemp() async {
    setState(() {
      _cityName = ' - ';
      _temp = ' - ';
      _weather = ' - ';
    });
    final location = await LocationMethods.getLocation();
    if (location.adcode?.isEmpty ?? false) {
      _cityName = location.city.isEmpty ? ' - ' : location.city;
    } else {
      final weather = await LocationMethods.getWeather(location.adcode);
      _cityName = weather.city ?? ' - ';
      _temp = weather.temperature ?? ' - ';
      _weather = weather.weather ?? ' - ';
    }
    setState(() {});
  }

  void _updateCountInfo(int count, int doingCount) {
    if (_taskCount == count && _doingTaskCount == doingCount) {
      return;
    }
    setState(() {
      _taskCount = count;
      _doingTaskCount = doingCount;
    });
  }

  @override
  void initState() {
    _taskCount = widget.taskCount ?? 0;
    _doingTaskCount = widget.doingTaskCount ?? 0;
    _dateTime = widget.dateTime;
    _controller = widget.controller ?? SingleDayScreenController();
    _controller._headerState = this;
    _updateLocAndTemp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildContentPanel(),
        _buildWeatherIcon(),
      ],
    );
  }

  Widget _buildContentPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '今日共计 $_taskCount 项事务，剩余',
          style: const TextStyle(
              fontSize: 14.0,
              color: Color(0xFFDEC0FF),
              fontWeight: FontWeight.w200),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: <Widget>[
              const SizedBox(
                width: 50.0,
              ),
              Text(
                '$_doingTaskCount',
                style: const TextStyle(
                  fontSize: 75.0,
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w200,
                ),
              ),
              SizedBox(
                width: 50.0,
                child: Text(
                  '未完成',
                  style: const TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w200),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  DateFormat('yyyy.MM.dd').format(_dateTime),
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFFDEC0FF),
                      fontWeight: FontWeight.w200),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  getWeekNameLong(_dateTime.weekday),
                  style: const TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFFDEC0FF),
                      fontWeight: FontWeight.w200),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _cityName,
                  style: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFFDEC0FF),
                      fontWeight: FontWeight.w200),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  '气温：$_temp ℃',
                  style: const TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFFDEC0FF),
                      fontWeight: FontWeight.w200),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _buildWeatherIcon() {
    return Positioned(
      right: 5.0,
      top: 0.0,
      child: weatherImageMap[_weather] != null
          ? GestureDetector(
              onTap: _updateLocAndTemp,
              child: Container(
                  height: 32.0,
                  width: 32,
                  child: Image.asset(weatherImageMap[_weather])),
            )
          //? Container(height: 32.0, width: 32, child: Image.asset('assets/images/weather/test1.png'))
          : CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Brightness.dark,
              ),
              child: CupertinoActivityIndicator(
                radius: 12.0,
              ),
            ),
    );
  }
}

class _ListBody extends StatefulWidget {
  final SingleDayScreenController controller;
  final DateTime date;

  const _ListBody({Key key, this.controller, this.date}) : super(key: key);
  @override
  _ListBodyState createState() => _ListBodyState();
}

class _ListBodyState extends State<_ListBody> {
  Widget _placeholder = Container(
    alignment: Alignment.topCenter,
    height: 300.0,
    width: 300.0,
    child: Config.listPlaceholder,
  );
  Widget _blank = const SizedBox();
  List<TaskPack> _taskList;
  DateTime _dateTime;

  SingleDayScreenController _controller;

  int _daytimeIndex;
  int _nightIndex;

  @override
  void initState() {
    super.initState();
    _dateTime = widget.date ?? DateTime.now();
    _controller = widget.controller ?? SingleDayScreenController();
    _controller._listState = this;
    _execUpdateListData().then((d) {
      _controller.isLoading = false;
    });
  }

  Future<void> _updateListData() async {
    _controller.isLoading = true;
    await _execUpdateListData();
    _controller.isLoading = false;
  }

  Future<void> _execUpdateListData() async {
    final baseList = await TaskDBAction.getTaskListTodo(_dateTime);
    final finishedList =
        await TaskDBAction.getTaskFinishedListByDate(_dateTime);
    final dayTimeSet = SplayTreeSet<TaskPack>(
        (a, b) => a.data.taskTime.compareTo(b.data.taskTime));
    final nightSet = SplayTreeSet<TaskPack>(
        (a, b) => a.data.taskTime.compareTo(b.data.taskTime));
    baseList.forEach((item) {
      if (item.data.timeType == DateTimeType.night) {
        nightSet.add(item);
      } else {
        dayTimeSet.add(item);
      }
    });
    finishedList.forEach((item) {
      if (item.data.timeType == DateTimeType.night) {
        nightSet.add(item);
      } else {
        dayTimeSet.add(item);
      }
    });
    _taskList = dayTimeSet.toList()..addAll(nightSet);
    final taskCount = _taskList.length;
    final doingCount = _taskList.where((pack) => !pack.data.isFinished).length;
    _daytimeIndex = null;
    _nightIndex = null;
    if (taskCount > 0) {
      for (var i = 0; i < taskCount; i++) {
        if (_daytimeIndex != null && _nightIndex != null) {
          break;
        }
        final type = _taskList[i].data.timeType;
        if (type == DateTimeType.daytime || type == DateTimeType.datetime) {
          _daytimeIndex ??= i;
        } else if (type == DateTimeType.night) {
          _nightIndex ??= i;
        }
      }
    }
    setState(() {});
    _controller.updateCountInfo(taskCount, doingCount);
  }

  @override
  Widget build(BuildContext context) {
    if (_taskList == null || _taskList.isEmpty) {
      return _controller.isLoading ? _blank : _placeholder;
    }
    return TimelineListView.build(
      placeholder: _placeholder,
      itemCount: _taskList.length,
      tileBuilder: (context, index) {
        final item = _taskList[index];
        final isFinished = item.data.isFinished;
        final rows = <Widget>[
          Text(
            item.data.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isFinished ? finishedColor : Color(0xFFD7CAFF),
              fontSize: 15.0,
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            '于 ${_makeTimeLabel(item.data.taskTime)} 开始',
            style: TextStyle(
                color: isFinished ? finishedColor : const Color(0xFFC9A2F5),
                fontSize: 12.0),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.solidCircle,
                color: isFinished ? finishedColor : item.tag.iconColor,
                size: 8.0,
              ),
              const SizedBox(
                width: 5.0,
              ),
              Text(
                item.tag.name ?? '默认',
                style: TextStyle(
                    color: isFinished ? finishedColor : item.tag.iconColor,
                    fontSize: 12.0),
              ),
            ],
          ),
        ];
        if (item.data.catalog != null && item.data.catalog.isNotEmpty) {
          rows
            ..add(
              const SizedBox(
                height: 5.0,
              ),
            )
            ..add(
              Text(
                item.data.catalog,
                style: TextStyle(
                    color: isFinished ? finishedColor : const Color(0xFFC9A2F5),
                    fontSize: 12.0),
              ),
            );
        }
        var remarkVisable;
        if (item.data.remark != null && item.data.remark.isNotEmpty) {
          remarkVisable = item.data.remark;
        } else {
          remarkVisable = '';
        }
        rows
          ..add(const SizedBox(height: 5.0))
          ..add(
            Text(
              remarkVisable,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: isFinished ? finishedColor : const Color(0xFFC9A2F5),
                  fontSize: 12.0),
            ),
          );
        rows.add(const SizedBox(height: 20.0));
        return TimelineTile(
          rows: rows,
          onTap: () => _enterDetail(item),
          onLongPress: () async {
            detailPopup(
              context,
              onDetail: () => _enterDetail(item),
              onDone: () async {
                await TaskDBAction.toggleTaskFinish(
                    item.data.id, true, DateTime.now());
                _controller.updateListData();
              },
              onDelete: () async {
                await TaskDBAction.deleteTask(item.data);
                _controller.updateListData();
              },
              onReactive: () async {
                await TaskDBAction.toggleTaskFinish(
                    item.data.id, false, DateTime.now());
                _controller.updateListData();
              },
              isDone: isFinished,
            );
          },
        );
      },
      onGenerateLabel: (index) {
        if (index == _daytimeIndex) {
          return '白天';
        } else if (index == _nightIndex) {
          return '晚间';
        } else {
          return '';
        }
      },
      onGenerateDotIcon: (index) {
        final type = _taskList[index].data.timeType;
        switch (type) {
          case DateTimeType.night:
            return Icon(
              buildCupertinoIconData(0xf468),
              size: 22.0,
              color: const Color(0xFFD7CAFF),
            );
          default:
            return Icon(
              buildCupertinoIconData(0xf4b7),
              size: 22.0,
              color: const Color(0xFFD7CAFF),
            );
        }
      },
      onGenerateDotColor: (index) => const Color(0xFFD7CAFF),
      onGenerateLabelColor: (index) => const Color(0xFFC9A2F5),
    );
  }

  Future<TaskPack> _enterDetail(TaskPack item) {
    isScreenTransitionVertical = true;
    final future = Completer<TaskPack>();
    PushRouteNotification(
      DetailListScreen(taskPack: item),
      callback: (pack) {
        future.complete(pack);
        setState(() {
          _updateListData();
        });
      },
    ).dispatch(context);
    return future.future;
  }
}

String _makeTimeLabel(DateTime time) {
  final now = DateTime.now();
  if (time.year == now.year && time.month == now.month && time.day == now.day) {
    return '今天';
  } else if (time.year == now.year) {
    return DateFormat('MM月dd日').format(time);
  } else {
    return DateFormat('yyyy年MM月dd日').format(time);
  }
}

class _ButtonAndLoadingIcon extends StatefulWidget {
  final bool isLoading;
  final SingleDayScreenController controller;

  const _ButtonAndLoadingIcon({
    Key key,
    this.isLoading,
    this.controller,
  }) : super(key: key);
  @override
  _ButtonAndLoadingIconState createState() => _ButtonAndLoadingIconState();
}

class _ButtonAndLoadingIconState extends State<_ButtonAndLoadingIcon> {
  bool _isLoadingValue;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    if (value == null) {
      return;
    }
    setState(() {
      _isLoadingValue = value;
    });
  }

  SingleDayScreenController _controller;

  @override
  void initState() {
    super.initState();
    _isLoadingValue = widget.isLoading ?? true;
    _controller = widget.controller ?? SingleDayScreenController();
    _controller._loadingState = this;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            padding: EdgeInsets.zero,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Brightness.dark,
              ),
              child: CupertinoActivityIndicator(),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '计划',
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
          );
  }
}

class _TranslateContainer extends StatefulWidget {
  final double initOffset;
  final Widget child;
  final SingleDayScreenController controller;

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

  SingleDayScreenController _controller;

  @override
  void initState() {
    super.initState();
    _offsetValue = widget.initOffset ?? 0.0;
    _controller = widget.controller ?? SingleDayScreenController();
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

class SingleDayScreenController {
  _ListBodyState _listState;
  _HeaderPanelState _headerState;
  _ButtonAndLoadingIconState _loadingState;
  List<_TranslateContainerState> _transStates = List();

  double _transitionFactor = 0.0;
  double _transitionExt = 0.0;

  bool get isLoading => _loadingState?._isLoading ?? false;
  set isLoading(bool value) => _loadingState?._isLoading = value;

  void updateListData() {
    _listState?._updateListData();
  }

  void updateTransition(double value) {
    _transitionFactor = value;
    _transStates.forEach(
        (state) => state.offset = _transitionFactor + _transitionExt - 1);
  }

  void updateTransitionExt(double value) {
    _transitionExt = value;
    _transStates.forEach(
        (state) => state.offset = _transitionFactor + _transitionExt - 1);
  }

  void updateCountInfo(int count, int doingCount) {
    _headerState?._updateCountInfo(count, doingCount);
  }
}
