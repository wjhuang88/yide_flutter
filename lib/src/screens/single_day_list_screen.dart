import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/location_methods.dart';
import 'package:yide/src/components/timeline_list.dart';
import 'package:yide/src/config.dart' as Config;
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/screens/multiple_day_list_screen.dart';
import 'package:yide/src/tools/date_tools.dart';
import 'package:yide/src/models/geo_data.dart';
import 'package:yide/src/tools/sqlite_manager.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/screens/detail_list_screen.dart';
import 'package:yide/src/screens/edit_main_screen.dart';
import 'package:yide/src/tools/icon_tools.dart';

class SingleDayListScreen extends StatefulWidget implements Navigatable {
  const SingleDayListScreen({Key key}) : super(key: key);

  static SingleDayScreenController controller = SingleDayScreenController();

  @override
  _SingleDayListScreenState createState() =>
      _SingleDayListScreenState(controller);

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) {
        anim2.addStatusListener((status) {
          if (status == AnimationStatus.dismissed) {
            controller.setVerticalMove(false);
          }
        });
        return this;
      },
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final anim2Curved = CurvedAnimation(
          parent: anim2,
          curve: const ElasticOutCurve(1.0),
          reverseCurve: const ElasticInCurve(1.0),
        ).value;
        controller.updateTransition(1 - anim2Curved);
        return FadeTransition(
          opacity: anim1Curved,
          child: Transform.scale(
            scale: 2 - anim1Curved.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  bool get withMene => true;
}

class _SingleDayListScreenState extends State<SingleDayListScreen> {
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
      child: _FadeContainer(
        controller: _controller,
        child: Container(
          decoration: BoxDecoration(gradient: Config.backgroundGradient),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  HeaderBar(
                    indent: 17.0,
                    endIndet: 17.0,
                    leadingIcon: Icon(
                      buildCupertinoIconData(0xf394),
                      color: Color(0xFFD7CAFF),
                      size: 30.0,
                    ),
                    onLeadingAction: () =>
                        MenuNotification(MenuNotificationType.openMenu)
                            .dispatch(context),
                    actionIcon: _ButtonAndLoadingIcon(
                      controller: _controller,
                      isLoading: true,
                    ),
                    onAction: () {
                      PushRouteNotification(MultipleDayListScreen())
                          .dispatch(context);
                    },
                  ),
                  const SizedBox(height: 10.0,),
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
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: SafeArea(
                  child: Container(
                    height: 55.0,
                    width: 55.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x883D2E75),
                            blurRadius: 10.5,
                            offset: Offset(0.0, 6.5),
                          ),
                        ]),
                    margin: const EdgeInsets.only(right: 10.0, bottom: 20.0),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFFFAB807),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      child: const Icon(
                        CupertinoIcons.add,
                        size: 45.0,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        isSingleDayScreenTransitionVertical = true;
                        PushRouteNotification(
                          EditMainScreen(),
                          callback: (pack) async {
                            final newTask = pack as TaskPack;
                            if (newTask != null) {
                              await TaskDBAction.saveTask(newTask.data);
                              setState(() {
                                _controller.updateListData();
                              });
                            }
                          },
                        ).dispatch(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          '总共$_taskCount件事项还剩',
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
  List<TaskPack> _taskList;
  DateTime _dateTime;

  SingleDayScreenController _controller;

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
    _taskList = await TaskDBAction.getTaskListByDate(_dateTime);
    final taskCount = _taskList.length;
    final doingCount = _taskList.where((pack) => !pack.data.isFinished).length;
    setState(() {});
    _controller.updateCountInfo(taskCount, doingCount);
  }

  @override
  Widget build(BuildContext context) {
    if (_taskList == null || _taskList.isEmpty) {
      return _placeholder;
    }
    return TimelineListView.build(
      placeholder: _placeholder,
      itemCount: _taskList.length,
      tileBuilder: (context, index) {
        final item = _taskList[index];
        final rows = <Widget>[
          Text(
            item.data.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD7CAFF),
              fontSize: 15.0,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            item.tag.name ?? '默认',
            style: TextStyle(color: item.tag.iconColor, fontSize: 12.0),
          ),
        ];
        if (item.data.catalog != null && item.data.catalog.isNotEmpty) {
          rows
            ..add(
              const SizedBox(
                height: 10.0,
              ),
            )
            ..add(
              Text(
                item.data.catalog,
                style:
                    const TextStyle(color: Color(0xFFC9A2F5), fontSize: 12.0),
              ),
            );
        }
        var remarkVisable;
        if (item.data.remark != null && item.data.remark.isNotEmpty) {
          remarkVisable = item.data.remark;
        } else {
          remarkVisable = ' - ';
        }
        rows
          ..add(const SizedBox(height: 10.0))
          ..add(
            Text(
              remarkVisable,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFC9A2F5), fontSize: 12.0),
            ),
          );
        rows.add(const SizedBox(height: 20.0));
        return TimelineTile(
          rows: rows,
          onTap: () async {
            isSingleDayScreenTransitionVertical = true;
            PushRouteNotification(
              DetailListScreen(taskPack: item),
              callback: (pack) {
                setState(() {
                  _updateListData();
                });
              },
            ).dispatch(context);
          },
        );
      },
      onGenerateLabel: (index) => _makeTimeLabel(_taskList[index]?.data),
      onGenerateDotColor: (index) => _taskList[index]?.tag?.iconColor,
    );
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
                '日程',
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
  Widget build(BuildContext context) {
    final offsetObject = isSingleDayScreenTransitionVertical
        ? Offset(0.0, offset)
        : Offset(offset, 0.0);
    return FractionalTranslation(
      translation: offsetObject,
      child: widget.child,
    );
  }
}

class _FadeContainer extends StatefulWidget {
  final double initOpacity;
  final Widget child;
  final SingleDayScreenController controller;

  const _FadeContainer({
    Key key,
    this.initOpacity,
    @required this.child,
    this.controller,
  }) : super(key: key);
  @override
  _FadeContainerState createState() => _FadeContainerState();
}

class _FadeContainerState extends State<_FadeContainer> {
  double _opacityValue;
  double get opacity => _opacityValue;
  set opacity(double value) => setState(() => _opacityValue = value);

  SingleDayScreenController _controller;

  @override
  void initState() {
    super.initState();
    _opacityValue = widget.initOpacity ?? 0.0;
    _controller = widget.controller ?? SingleDayScreenController();
    _controller._fadeStates.add(this);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration.zero,
      opacity: opacity,
      child: widget.child,
    );
  }
}

class SingleDayScreenController {
  _ListBodyState _listState;
  _HeaderPanelState _headerState;
  _ButtonAndLoadingIconState _loadingState;
  List<_TranslateContainerState> _transStates = List();
  List<_FadeContainerState> _fadeStates = List();

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
    _fadeStates.forEach((state) =>
        state.opacity = (_transitionFactor + _transitionExt).clamp(0.0, 1.0));
  }

  void updateTransitionExt(double value) {
    _transitionExt = value;
    _transStates.forEach(
        (state) => state.offset = _transitionFactor + _transitionExt - 1);
    _fadeStates.forEach((state) =>
        state.opacity = (_transitionFactor + _transitionExt).clamp(0.0, 1.0));
  }

  void setVerticalMove(bool value) {
    isSingleDayScreenTransitionVertical = value;
  }

  void updateCountInfo(int count, int doingCount) {
    _headerState?._updateCountInfo(count, doingCount);
  }
}
