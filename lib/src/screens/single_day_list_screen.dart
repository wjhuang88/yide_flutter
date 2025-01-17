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
import 'package:yide/src/components/svg_icon.dart';
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
  SingleDayListScreen({super.key});

  static SingleDayScreenController controller = SingleDayScreenController();

  @override
  _SingleDayListScreenState createState() =>
      _SingleDayListScreenState(controller);

  @override
  Future<void> onDragNext(BuildContext context, double offset) async {
    final future = Completer();
    PushRouteNotification(MultipleDayListScreen(), callback: (d) {
      controller.updateListData();
      future.complete();
    }).dispatch(context);
    //haptic();
    return future.future;
  }

  @override
  void onTransitionValueChange(double value) {
    controller.updateTransition(value);
  }

  @override
  String get name => '今日';
}

class _SingleDayListScreenState extends State<SingleDayListScreen>
    with AppLifecycleResumeProvider {
  _SingleDayListScreenState(this._controller);

  SingleDayScreenController _controller;

  DateTime _dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
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
                  title: widget.name,
                  leadingIcon: SvgIcon.menu,
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
                    child: _HeaderPanel(
                      dateTime: _dateTime,
                      controller: _controller,
                    ),
                  ),
                ),
                Expanded(
                  child: _TranslateContainer(
                    controller: _controller,
                    child: Stack(
                      children: <Widget>[
                        _ListBody(
                          controller: _controller,
                          date: _dateTime,
                        ),
                        Transform.translate(
                          offset: Offset(47.5, -98.0),
                          child: _makeLight(100.0),
                        ),
                      ],
                    ),
                  ),
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

Widget _makeLight(double size) {
  return Container(
    height: size,
    width: size,
    child: Stack(
      children: <Widget>[
        Center(
          child: Icon(
            FontAwesomeIcons.solidCircle,
            color: Color(0x22FFFFFF),
            size: size,
          ),
        ),
        Center(
          child: Icon(
            FontAwesomeIcons.solidCircle,
            color: Color(0x44FFFFFF),
            size: size * 0.85,
          ),
        ),
        Center(
          child: Icon(
            FontAwesomeIcons.solidCircle,
            color: Color(0xFFFFFFFF),
            size: size * 0.7,
          ),
        ),
      ],
    ),
  );
}

class _HeaderPanel extends StatefulWidget {
  final DateTime dateTime;
  final SingleDayScreenController controller;

  const _HeaderPanel({
    super.key,
    required this.dateTime,
    required this.controller,
  });

  @override
  _HeaderPanelState createState() => _HeaderPanelState();
}

class _HeaderPanelState extends State<_HeaderPanel> {
  String _cityName = ' - ';
  String _temp = ' - ';

  late DateTime _dateTime;

  Future<void> _updateLocAndTemp() async {
    setState(() {
      _cityName = ' - ';
      _temp = ' - ';
    });
    final location = await LocationMethods.getLocation();
    if (location.adcode?.isEmpty ?? false) {
      _cityName = (location.city?.isEmpty ?? true) ? ' - ' : location.city!;
    } else {
      final weather = await LocationMethods.getWeather(location.adcode);
      _cityName = weather.city ?? ' - ';
      _temp = weather.temperature ?? ' - ';
    }
    setState(() {});
  }

  @override
  void initState() {
    _dateTime = widget.dateTime;
    _updateLocAndTemp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          DateFormat('MM月dd日').format(_dateTime),
          style: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w200),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          getWeekNameLong(_dateTime.weekday),
          style: const TextStyle(
            fontSize: 26.0,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w200,
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.locationArrow,
              color: Color(0xFFFFFFFF),
              size: 10.0,
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(
              _cityName,
              style: const TextStyle(
                fontSize: 12.0,
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(
              '$_temp ℃',
              style: const TextStyle(
                fontSize: 12.0,
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _ListBody extends StatefulWidget {
  final SingleDayScreenController controller;
  final DateTime date;

  const _ListBody({super.key, required this.controller, required this.date});
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
  late List<TaskPack> _taskList;
  late DateTime _dateTime;

  late SingleDayScreenController _controller;

  int? _daytimeIndex;
  int? _nightIndex;

  @override
  void initState() {
    super.initState();
    _dateTime = widget.date;
    _controller = widget.controller;
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
    final now = DateTime.now();
    final dayTimeSet = SplayTreeSet<TaskPack>((a, b) =>
        -(a.data?.createTime ?? now).compareTo(b.data?.createTime ?? now));
    final nightSet = SplayTreeSet<TaskPack>((a, b) =>
        -(a.data?.createTime ?? now).compareTo(b.data?.createTime ?? now));
    baseList?.forEach((item) {
      if (item.data?.timeType == DateTimeType.night) {
        nightSet.add(item);
      } else {
        dayTimeSet.add(item);
      }
    });
    finishedList?.forEach((item) {
      if (item.data?.timeType == DateTimeType.night) {
        nightSet.add(item);
      } else {
        dayTimeSet.add(item);
      }
    });
    final repeatTaskList = await getRecurringTaskByDate(_dateTime);
    repeatTaskList.forEach((item) {
      if (item == null) {
        return;
      }
      item.isRecurring = true;
      if (item.data?.timeType == DateTimeType.night) {
        nightSet.add(item);
      } else {
        dayTimeSet.add(item);
      }
    });
    _taskList = dayTimeSet.toList()..addAll(nightSet);
    final taskCount = _taskList.length;
    _daytimeIndex = null;
    _nightIndex = null;
    if (taskCount > 0) {
      for (var i = 0; i < taskCount; i++) {
        if (_daytimeIndex != null && _nightIndex != null) {
          break;
        }
        final type = _taskList[i].data?.timeType;
        if (type == DateTimeType.daytime || type == DateTimeType.datetime) {
          _daytimeIndex ??= i;
        } else if (type == DateTimeType.night) {
          _nightIndex ??= i;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_taskList.isEmpty) {
      return _controller.isLoading ? _blank : _placeholder;
    }
    return TimelineListView.build(
      placeholder: _placeholder,
      itemCount: _taskList.length,
      tileBuilder: (context, index) {
        final item = _taskList[index];
        final isFinished = item.data?.isFinished ?? false;
        final rows = <Widget>[
          Text(
            item.data?.content ?? '',
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
            '于 ${_makeTimeLabel(item.data?.taskTime ?? DateTime.now())} 开始',
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
                color: isFinished ? finishedColor : item.tag?.iconColor,
                size: 8.0,
              ),
              const SizedBox(
                width: 5.0,
              ),
              Text(
                item.tag?.name ?? '默认',
                style: TextStyle(
                    color: isFinished ? finishedColor : item.tag?.iconColor,
                    fontSize: 12.0),
              ),
            ],
          ),
        ];
        if (item.data?.catalog != null &&
            (item.data?.catalog?.isNotEmpty ?? false)) {
          rows
            ..add(
              const SizedBox(
                height: 5.0,
              ),
            )
            ..add(
              Text(
                item.data?.catalog ?? '',
                style: TextStyle(
                    color: isFinished ? finishedColor : const Color(0xFFC9A2F5),
                    fontSize: 12.0),
              ),
            );
        }
        var remarkVisable;
        if (item.data?.remark != null &&
            (item.data?.remark?.isNotEmpty ?? false)) {
          remarkVisable = item.data?.remark;
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
                    item.data?.id, true, DateTime.now());
                _controller.updateListData();
              },
              onDelete: () async {
                await TaskDBAction.deleteTask(item.data);
                _controller.updateListData();
              },
              onReactive: () async {
                await TaskDBAction.toggleTaskFinish(
                    item.data?.id, false, DateTime.now());
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
        if (_taskList[index].isRecurring) {
          return Icon(
            buildCupertinoIconData(0xf49a),
            size: 22.0,
            color: const Color(0xFFD7CAFF),
          );
        }
        return _makeLight(15.0);
      },
      onGenerateDotColor: (index) => const Color(0xFFFFFFFF),
      onGenerateLabelColor: (index) => const Color(0xFFFFFFFF),
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
  final bool? isLoading;
  final SingleDayScreenController? controller;

  const _ButtonAndLoadingIcon({
    super.key,
    this.isLoading,
    this.controller,
  });
  @override
  _ButtonAndLoadingIconState createState() => _ButtonAndLoadingIconState();
}

class _ButtonAndLoadingIconState extends State<_ButtonAndLoadingIcon> {
  bool? _isLoadingValue;
  bool get _isLoading => _isLoadingValue ?? false;
  set _isLoading(bool? value) {
    if (value == null) {
      return;
    }
    setState(() {
      _isLoadingValue = value;
    });
  }

  late SingleDayScreenController _controller;

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
  final double? initOffset;
  final Widget child;
  final SingleDayScreenController? controller;

  const _TranslateContainer({
    super.key,
    this.initOffset,
    required this.child,
    this.controller,
  });
  @override
  _TranslateContainerState createState() => _TranslateContainerState();
}

class _TranslateContainerState extends State<_TranslateContainer> {
  double? _offsetValue;
  double get offset => _offsetValue ?? 0;
  set offset(double value) => setState(() => _offsetValue = value);

  SingleDayScreenController? _controller;

  @override
  void initState() {
    super.initState();
    _offsetValue = widget.initOffset ?? 0.0;
    _controller = widget.controller ?? SingleDayScreenController();
    _controller?._transStates.add(this);
  }

  @override
  void dispose() {
    _controller?._transStates.remove(this);
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
  _ListBodyState? _listState;
  _ButtonAndLoadingIconState? _loadingState;
  List<_TranslateContainerState> _transStates = [];

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
}
