import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/components/location_methods.dart';
import 'package:yide/components/timeline_list.dart';
import 'package:yide/interfaces/navigatable.dart';
import 'package:yide/models/date_tools.dart';
import 'package:yide/models/geo_data.dart';
import 'package:yide/models/sqlite_manager.dart';
import 'package:yide/models/task_data.dart';
import 'package:yide/notification.dart';
import 'package:yide/screens/detail_screen/detail_list_screen.dart';
import 'package:yide/screens/edit_main_screen.dart';

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
  Widget _loadingPlaceholder;

  Future<List<TaskPack>> _taskList;

  String _cityName = ' - ';
  String _temp = ' - ';
  String _weather = ' - ';

  bool _isDragging = false;
  double _animDragDelta = 0.0;
  double _screenWidth = 1.0;

  DateTime _dateTime = DateTime.now();

  void _updateLocAndTemp() async {
    final location = await LocationMethods.getLocation();
    final weather = await LocationMethods.getWeather(location.adcode);
    setState(() {
      _cityName = weather.city ?? ' - ';
      _temp = weather.temperature ?? ' - ';
      _weather = weather.weather ?? ' - ';
    });
  }

  @override
  void initState() {
    super.initState();
    transitionFactor = 0.0;
    _controller ??= TimelineScreenController();

    _savedList = _placeholder = Container();
    _loadingPlaceholder = CupertinoActivityIndicator(
      radius: 16.0,
    );

    _taskList = TaskDBAction.getTaskListByDate(_dateTime);
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
        AppNotification('drag_menu_end', value: detail.primaryVelocity)
            .dispatch(context);
      },
      onHorizontalDragCancel: () {
        if (!_isDragging) {
          return;
        }
        _isDragging = false;
        AppNotification('drag_menu_end').dispatch(context);
      },
      onHorizontalDragUpdate: (detail) {
        if (_isDragging) {
          final frac =
              (detail.globalPosition.dx - _animDragDelta) / _screenWidth + 0.3;
          if (frac < 0.3) {
            return;
          }
          AppNotification('drag_menu', value: frac).dispatch(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Opacity(
          opacity: opacity,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFFAB807),
            child: const Icon(
              Icons.add,
              size: 40.0,
            ),
            onPressed: () async {
              final newTask = await Navigator.push<TaskPack>(
                  context, EditMainScreen().route);
              if (newTask != null) {
                await TaskDBAction.saveTask(newTask.data);
                setState(() {
                  _taskList = TaskDBAction.getTaskListByDate(_dateTime);
                });
              }
            },
          ),
        ),
        body: Opacity(
          opacity: opacity,
          child: Column(
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(17.0),
                    child: const Icon(
                      FontAwesomeIcons.bars,
                      color: Color(0xFFD7CAFF),
                    ),
                    onPressed: () {
                      AppNotification("open_menu").dispatch(context);
                    },
                  ),
                ),
              ),
              FractionalTranslation(
                translation: Offset(0.0, transitionFactor - 1),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 17.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 18.0),
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
                                child: Image.asset(weatherImageMap[_weather]))
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
                          return _savedList;
                        case ConnectionState.waiting:
                          return _loadingPlaceholder;
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
                                    _taskList = TaskDBAction.getTaskListByDate(
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
