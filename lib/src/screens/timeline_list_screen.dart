import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/location_methods.dart';
import 'package:yide/src/components/timeline_list.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/tools/date_tools.dart';
import 'package:yide/src/models/geo_data.dart';
import 'package:yide/src/tools/sqlite_manager.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/screens/detail_screen/detail_list_screen.dart';
import 'package:yide/src/screens/edit_main_screen.dart';
import 'package:yide/src/tools/icon_tools.dart';

class TimelineListScreen extends StatefulWidget implements Navigatable {
  const TimelineListScreen({Key key}) : super(key: key);

  static TimelineScreenController controller = TimelineScreenController();

  @override
  _TimelineListScreenState createState() =>
      _TimelineListScreenState(controller);

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = Curves.easeOutCubic.transform(anim1.value);
        final anim2Curved = const ElasticInCurve(1.0).transform(anim2.value);
        controller.updateTransition(1 - anim2Curved);
        return Opacity(
          opacity: anim1Curved,
          child: Transform.scale(
            scale: 2 - anim1Curved,
            child: child,
          ),
        );
      },
    );
  }
}

class _TimelineListScreenState extends State<TimelineListScreen> {
  _TimelineListScreenState(this._controller);

  double transitionFactor;
  TimelineScreenController _controller;
  Widget _savedList;
  Widget _placeholder;

  Future<List<TaskPack>> _taskList;

  String _cityName = ' - ';
  String _temp = ' - ';
  String _weather = ' - ';

  bool _isDragging = false;
  double _animDragDelta = 0.0;
  double _screenWidth = 1.0;

  DateTime _dateTime = DateTime.now();

  bool _isLoadingValue = true;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    setState(() {
      _isLoadingValue = value;
    });
  }

  Future<void> _updateLocAndTemp() async {
    _isLoading = true;
    final location = await LocationMethods.getLocation();
    final weather = await LocationMethods.getWeather(location.adcode);
    _cityName = weather.city ?? ' - ';
    _temp = weather.temperature ?? ' - ';
    _weather = weather.weather ?? ' - ';
    _isLoading = false;
  }

  Future<List<TaskPack>> _updateListData() async {
    _isLoading = true;
    final result = await TaskDBAction.getTaskListByDate(_dateTime);
    _isLoading = false;
    return result;
  }

  @override
  void initState() {
    super.initState();
    transitionFactor = 0.0;
    _controller ??= TimelineScreenController();

    _savedList = _placeholder = Container();

    _taskList = _updateListData();
    _updateLocAndTemp();

    _controller._state = this;
  }

  @override
  void dispose() {
    _controller._state = null;
    super.dispose();
  }

  void _updateTransition(double value) {
    setState(() {
      this.transitionFactor = value;
    });
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

  @override
  Widget build(BuildContext context) {
    final opacity = (transitionFactor).clamp(0.0, 1.0);
    return GestureDetector(
      onHorizontalDragStart: (detail) {
        final x = detail.globalPosition.dx;
        if (x < 100.0 && x > 0) {
          _isDragging = true;
          _animDragDelta = x;
          _screenWidth = MediaQuery.of(context).size.width;
        }
      },
      onHorizontalDragEnd: (detail) {
        if (!_isDragging) {
          return;
        }
        _isDragging = false;
        AppNotification(NotificationType.dragMenuEnd, value: detail.primaryVelocity)
            .dispatch(context);
      },
      onHorizontalDragCancel: () {
        if (!_isDragging) {
          return;
        }
        _isDragging = false;
        AppNotification(NotificationType.dragMenuEnd).dispatch(context);
      },
      onHorizontalDragUpdate: (detail) {
        if (_isDragging) {
          final frac =
              (detail.globalPosition.dx - _animDragDelta) / _screenWidth + 0.3;
          if (frac < 0.3) {
            return;
          }
          AppNotification(NotificationType.dragMenu, value: frac).dispatch(context);
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        child: Opacity(
          opacity: opacity,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CupertinoButton(
                          padding: const EdgeInsets.all(17.0),
                          child: Icon(
                            buildCupertinoIconData(0xf394),
                            color: Color(0xFFD7CAFF),
                            size: 30.0,
                          ),
                          onPressed: () {
                            AppNotification(NotificationType.openMenu).dispatch(context);
                          },
                        ),
                        _isLoading
                            ? Container(
                                padding: const EdgeInsets.only(right: 17.0),
                                child: CupertinoActivityIndicator(),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  FractionalTranslation(
                    translation: Offset(0.0, transitionFactor - 1),
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
                      child: Stack(
                        children: <Widget>[
                          _buildHeaderColumn(),
                          Positioned(
                            right: 5.0,
                            top: 0.0,
                            child: weatherImageMap[_weather] != null
                                ? Container(
                                    height: 32.0,
                                    width: 32,
                                    child:
                                        Image.asset(weatherImageMap[_weather]))
                                //? Container(height: 32.0, width: 32, child: Image.asset('assets/images/weather/test1.png'))
                                : CupertinoActivityIndicator(
                                    radius: 16.0,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Expanded(
                    child: FractionalTranslation(
                      translation: Offset(transitionFactor - 1, 0.0),
                      child: FutureBuilder<List<TaskPack>>(
                        future: _taskList,
                        initialData: null,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return _savedList;
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final dataList = snapshot.data;
                              _savedList = TimelineListView.build(
                                placeholder: _placeholder,
                                itemCount: dataList.length,
                                tileBuilder: (context, index) {
                                  final item = dataList[index];
                                  final rows = <Widget>[
                                    Text(
                                      item.data.content,
                                      maxLines: 1,
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
                                      style: TextStyle(
                                          color: item.tag.iconColor,
                                          fontSize: 12.0),
                                    ),
                                  ];
                                  if (item.data.catalog != null &&
                                      item.data.catalog.isNotEmpty) {
                                    rows
                                      ..add(
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                      )
                                      ..add(Text(
                                        item.data.catalog,
                                        style: const TextStyle(
                                            color: Color(0xFFC9A2F5),
                                            fontSize: 12.0),
                                      ));
                                  }
                                  if (item.data.remark != null &&
                                      item.data.remark.isNotEmpty) {
                                    rows
                                      ..add(const SizedBox(height: 10.0))
                                      ..add(Text(
                                        item.data.remark,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFFC9A2F5),
                                            fontSize: 12.0),
                                      ));
                                  }
                                  return TimelineTile(
                                    rows: rows,
                                    onTap: () async {
                                      await Navigator.of(context)
                                          .push<TaskPack>(DetailListScreen(
                                        taskPack: item,
                                      ).route);
                                      setState(() {
                                        _taskList =
                                            TaskDBAction.getTaskListByDate(
                                                _dateTime);
                                      });
                                    },
                                  );
                                },
                                onGenerateLabel: (index) =>
                                    _makeTimeLabel(dataList[index]?.data),
                                onGenerateDotColor: (index) =>
                                    dataList[index]?.tag?.iconColor,
                              );
                              return _savedList;
                            default:
                              return _placeholder;
                          }
                        },
                      ),
                    ),
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
                    margin: const EdgeInsets.only(right: 20.0, bottom: 20.0),
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
                        final newTask = await Navigator.push<TaskPack>(
                            context, EditMainScreen().route);
                        if (newTask != null) {
                          await TaskDBAction.saveTask(newTask.data);
                          setState(() {
                            _taskList =
                                TaskDBAction.getTaskListByDate(_dateTime);
                          });
                        }
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

  Widget _buildHeaderColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '总共10件事项还剩',
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
                '5',
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
                  '气温：$_temp℃',
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
}

class TimelineScreenController {
  _TimelineListScreenState _state;

  void updateTransition(double value) {
    _state?._updateTransition(value);
  }
}
