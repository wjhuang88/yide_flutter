import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/infinity_page_view.dart';
import 'package:yide/src/components/native_textfield.dart';
import 'package:yide/src/components/panel_switcher.dart';
import 'package:yide/src/components/tap_animator.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/mixins/app_lifecycle_resume_provider.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/date_tools.dart';
import 'package:yide/src/tools/icon_tools.dart';
import 'package:yide/src/tools/sqlite_manager.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/screens/detail_screens/panels/detail_datetime_panel.dart';
import 'package:yide/src/screens/detail_screens/panels/detail_tag_panel.dart';
import 'package:yide/src/screens/detail_screens/panels/detail_time_panel.dart';

class EditMainScreen extends StatefulWidget implements Navigatable {
  const EditMainScreen({super.key, this.taskPack});

  static EditScreenController controller = EditScreenController();

  final TaskPack? taskPack;

  @override
  _EditMainScreenState createState() => _EditMainScreenState(controller);

  @override
  Route get route => PageRouteBuilder<TaskPack>(
        pageBuilder: (context, anim1, anim2) => this,
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, anim1, anim2, child) {
          final anim1Curved = CurvedAnimation(
            parent: Tween(begin: 0.0, end: 1.0).animate(anim1),
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          controller.setTransitionAnim(anim1Curved);
          return child;
        },
      );

  @override
  bool get withMene => false;

  @override
  String get name => '编辑';
}

class _EditMainScreenState extends State<EditMainScreen>
    with SingleTickerProviderStateMixin, AppLifecycleResumeProvider {
  _EditMainScreenState(this._controller);

  late AnimationController _defaultAnimController;
  Animation<double>? _factorAnimationStorage;
  Animation<double> get _factorAnimation =>
      _factorAnimationStorage ??
      Tween(begin: 0.0, end: 0.0).animate(_defaultAnimController);
  set _factorAnimation(Animation<double> value) =>
      _factorAnimationStorage = value;

  EditScreenController _controller;

  NativeTextFieldController _fieldController = NativeTextFieldController();

  TaskData? _taskData;
  TaskTag? _tagData;

  String? _inputText;

  void _updateTaskData(TaskData? taskData) {
    setState(() {
      _taskData = taskData;
    });
  }

  void _updateTag(TaskTag? tag) {
    setState(() {
      _tagData = tag;
    });
  }

  @override
  void initState() {
    super.initState();
    _defaultAnimController = AnimationController(vsync: this);
    _taskData = TaskData.copy(widget.taskPack?.data ?? TaskData.defultNull());
    _tagData = widget.taskPack?.tag;
    if (_tagData == null) {
      TaskDBAction.getFirstTag().then((tag) {
        setState(() {
          _tagData = tag;
          _taskData?.tagId = tag?.id;
        });
      });
    } else {
      _taskData?.tagId = _tagData?.id;
    }

    _controller._mainState = this;
    _inputText = _taskData?.content;
  }

  @override
  void didUpdateWidget(EditMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taskPack?.data?.content != oldWidget.taskPack?.data?.content) {
      _taskData?.content = widget.taskPack?.data?.content;
    }
    if (widget.taskPack?.tag != oldWidget.taskPack?.tag) {
      _tagData = widget.taskPack?.tag;
    }
    if (widget.taskPack?.data?.taskTime != oldWidget.taskPack?.data?.taskTime) {
      _taskData?.taskTime = widget.taskPack?.data?.taskTime;
    }
    _focus();
  }

  Future<bool> _saveAndBack(
      BuildContext context, TaskData? data, TaskTag? tag) async {
    data?.content = _inputText;
    if (data?.content?.isEmpty ?? true) {
      _focus();
      return false;
    }
    data?.tagId = tag?.id;
    final pack = TaskPack(data, tag);
    final callback = Completer<bool>();
    _unfocus();
    PopRouteNotification(
      result: pack,
      callback: callback.complete,
    ).dispatch(context);
    return callback.future;
  }

  void _setTransitionAnim(Animation<double> value) {
    setState(() {
      this._factorAnimation = value;
    });
  }

  @override
  void dispose() {
    _controller._mainState = null;
    super.dispose();
  }

  void _unfocus() {
    _fieldController.unfocus();
  }

  void _focus() {
    _fieldController.focus();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _factorAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                _buildInputPanel(),
                Expanded(
                  child: const SizedBox(),
                ),
                Transform.translate(
                  offset: Offset(0.0, 200 * (1 - _factorAnimation.value)),
                  child: _DateInfo(
                    controller: _controller,
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                _BottomPanel(
                  factorAnimation: _factorAnimation,
                  controller: _controller,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      transform: Matrix4.translationValues(
          0.0, -100.0 * (1 - _factorAnimation.value), 0.0),
      margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF975ED8), Color(0xFF7352D0)]),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              offset: Offset(0.0, 2.0),
              blurRadius: 17.5,
              color: Color(0x8A37256D),
            )
          ]),
      child: Column(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 70.0),
            child: NativeTextField(
              placeholder: '记录你的任务',
              text: _inputText ?? '',
              autofocus: true,
              controller: _fieldController,
              onSubmitted: (value) {
                _saveAndBack(context, _taskData, _tagData);
              },
              onChanged: (value) {
                _inputText = value;
              },
              onFocus: () {
                _controller.hideBottomBar(
                  callback: () => _controller.setBottomPanelTitle(''),
                );
                _controller.forceSwitchToPanel('blank');
              },
              onUnfocus: _controller.showBottomBar,
            ),
          ),
          TapAnimator(
            behavior: HitTestBehavior.opaque,
            builder: (factor) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.solidCircle,
                  color: _tagData?.iconColor ?? Colors.white,
                  size: 10.0,
                ),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  _tagData?.name ?? '默认',
                  style: TextStyle(
                    color: Color.lerp(const Color(0xFFFFFFFF),
                        const Color(0xFFBBADE7), factor),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
            onTap: () {
              _controller.changeSetupPanel(DetailTagPanel.panelName, '标签');
            },
          ),
          const SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );
  }

  @override
  void onResumed() {
    _focus();
  }
}

class _DateInfo extends StatefulWidget {
  const _DateInfo({
    super.key,
    required EditScreenController controller,
  }) : _controller = controller;

  final EditScreenController _controller;

  @override
  _DateInfoState createState() => _DateInfoState();
}

class _DateInfoState extends State<_DateInfo>
    with SingleTickerProviderStateMixin {
  EditScreenController? _controller;

  bool _isNight = false;

  @override
  void initState() {
    super.initState();
    _controller = widget._controller;
    _controller?._dateInfoState = this;
    _isNight = _controller?.taskData?.timeType == DateTimeType.night;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _switchToType(DateTimeType type) {
    final taskData = _controller?.taskData;
    taskData?.timeType = type;
    _controller?.taskData = taskData;
    if (type == DateTimeType.night) {
      _isNight = true;
    } else {
      _isNight = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 80.0,
          child: GestureDetector(
            onTap: () {
              widget._controller
                  .changeSetupPanel(DetailDateTimePanel.panelName, '日期');
            },
            child: _DatePage(
              baseTime: _controller?.taskData?.taskTime,
              controller: widget._controller,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CupertinoButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    buildCupertinoIconData(0xf4b7),
                    color: !_isNight ? Colors.white : const Color(0xFFBBADE7),
                  ),
                  Text(
                    '白天',
                    style: TextStyle(
                      color: !_isNight ? Colors.white : const Color(0xFFBBADE7),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              onPressed: () => _switchToType(DateTimeType.daytime),
            ),
            CupertinoButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    buildCupertinoIconData(0xf468),
                    color: _isNight ? Colors.white : const Color(0xFFBBADE7),
                  ),
                  Text(
                    '晚间',
                    style: TextStyle(
                      color: _isNight ? Colors.white : const Color(0xFFBBADE7),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              onPressed: () => _switchToType(DateTimeType.night),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePage extends StatefulWidget {
  const _DatePage({
    super.key,
    this.baseTime,
    this.controller,
  });

  final DateTime? baseTime;
  final EditScreenController? controller;

  @override
  _DatePageState createState() => _DatePageState();
}

class _DatePageState extends State<_DatePage> {
  InfinityPageController _datePageController = InfinityPageController();
  late EditScreenController _controller;

  DateTime? _baseTime;

  void _updateBaseTime(DateTime? dateTime) {
    setState(() {
      _baseTime = dateTime;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? EditScreenController();
    _controller._datePageState = this;
    _baseTime = widget.baseTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _datePageController.dispose();
    super.dispose();
  }

  String? _getWeekDayName(DateTime? dateTime) {
    final now = DateTime.now();
    final nextDay = now.add(Duration(days: 1));
    final previousDay = now.subtract(Duration(days: 1));
    final sameDay = (DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    };
    if (dateTime == null || sameDay(dateTime, now)) {
      return '今天';
    } else if (sameDay(dateTime, nextDay)) {
      return '明天';
    } else if (sameDay(dateTime, previousDay)) {
      return '昨天';
    } else {
      return weekMapLong[dateTime.weekday];
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfinityPageView(
      controller: _datePageController,
      itemBuilder: (context, i) {
        final timeToRender = _baseTime?.add(Duration(days: i));
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _getWeekDayName(timeToRender) ?? '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3.0),
            ),
            Text(
              DateFormat('MM月dd日').format(timeToRender ?? DateTime.now()),
              style: const TextStyle(color: Color(0xFFBBADE7), fontSize: 12.0),
            ),
          ],
        );
      },
      onPageChanged: (page) {
        setState(() {
          final data = _controller.taskData;
          data?.taskTime = _baseTime?.add(Duration(days: page));
          _controller.taskData = data;
        });
      },
    );
  }
}

class _BottomPanel extends StatefulWidget {
  const _BottomPanel({
    super.key,
    required this.factorAnimation,
    this.setupTitle,
    required this.controller,
  });

  final Animation<double> factorAnimation;
  final String? setupTitle;

  final EditScreenController controller;

  @override
  _BottomPanelState createState() => _BottomPanelState();
}

class _BottomPanelState extends State<_BottomPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _bottomBarController;
  late Animation<double> _bottomBarAnimation;

  String? _setupTitle;

  late EditScreenController _controller;

  void _updateTitle(String title) {
    setState(() {
      _setupTitle = title;
    });
  }

  @override
  void initState() {
    super.initState();
    _bottomBarController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 250), value: 0.0);
    _bottomBarAnimation = CurvedAnimation(
      parent: _bottomBarController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    )..addListener(() => setState(() {}));
    _controller = widget.controller;
    _controller._bottomState = this;
    _setupTitle = widget.setupTitle ?? '';
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _setupOffset = 150.0 * (1.0 - widget.factorAnimation.value);
    final _bottomOffset = _setupOffset + (1 - _bottomBarAnimation.value) * 50;
    final _bottomOpacity = _bottomBarAnimation;
    return Container(
      child: Stack(
        children: <Widget>[
          _buildSetupPanel(
              context, _setupOffset, ReverseAnimation(_bottomOpacity),
              title: _setupTitle ?? ''),
          Offstage(
            offstage: _bottomOpacity.value < 0.01,
            child: FadeTransition(
              opacity: _bottomOpacity,
              child: _buildBottomBar(context, _bottomOffset),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double offset) {
    return Container(
      color: const Color(0xFF472478),
      transform: Matrix4.translationValues(0.0, offset, 0.0),
      height: 45.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: TapAnimator(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _controller.unfocusInput();
                PopRouteNotification().dispatch(context);
              },
              builder: (factor) {
                final color =
                    const Color(0xFFBBADE7).withOpacity(1 - factor * 0.5);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      buildCupertinoIconData(0xf2d7),
                      color: color,
                      size: 18.0,
                    ),
                    const SizedBox(
                      width: 5.5,
                    ),
                    Text(
                      '取消',
                      style: TextStyle(color: color, fontSize: 14.0),
                    ),
                  ],
                );
              },
            ),
          ),
          const VerticalDivider(
            // indent: 11.0,
            // endIndent: 11.0,
            width: 0.0,
            thickness: 0.2,
            color: const Color(0x88E8E8E8),
          ),
          Expanded(
            child: TapAnimator(
              behavior: HitTestBehavior.opaque,
              onTap: () => _controller.saveAndBack(context),
              builder: (factor) {
                final color =
                    const Color(0xFFBBADE7).withOpacity(1 - factor * 0.5);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      buildCupertinoIconData(0xf383),
                      color: color,
                      size: 18.0,
                    ),
                    const SizedBox(
                      width: 5.5,
                    ),
                    Text(
                      '保存',
                      style: TextStyle(color: color, fontSize: 14.0),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPanel(
      BuildContext context, double offset, Animation<double> titleOpacity,
      {String title = ''}) {
    return Container(
      transform: Matrix4.translationValues(0.0, offset, 0.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _controller.focusInput();
            },
            child: Container(
              height: 44.0,
              color: const Color(0xFF472478),
              child: FadeTransition(
                opacity: titleOpacity,
                child: Stack(
                  children: <Widget>[
                    Center(
                        child: Text(
                      title,
                      style: const TextStyle(
                          color: Color(0xFFBBADE7), fontSize: 14.0),
                    )),
                    Container(
                      padding: const EdgeInsets.only(right: 16.0),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.clear,
                        color: Color(0xFFBBADE7),
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            height: 0.0,
            color: Color(0xFFBBADE7),
            thickness: 0.1,
          ),
          _SetupPanelBody(
            controller: _controller,
          ),
        ],
      ),
    );
  }
}

class _SetupPanelBody extends StatefulWidget {
  final EditScreenController controller;

  const _SetupPanelBody({super.key, required this.controller});
  @override
  _SetupPanelBodyState createState() => _SetupPanelBodyState();
}

class _SetupPanelBodyState extends State<_SetupPanelBody> {
  double? _keyboardRealHeight;
  late PanelSwitcherController _setupPanelController;

  late EditScreenController _controller;

  @override
  void initState() {
    super.initState();
    _setupPanelController = PanelSwitcherController();
    _controller = widget.controller;
    _controller._panelBodyState = this;
  }

  @override
  Widget build(BuildContext context) {
    final _keyboardBuildHeight = MediaQuery.of(context).viewInsets.bottom;
    if (_keyboardBuildHeight > 0.0) {
      _keyboardRealHeight = _keyboardBuildHeight;
    }

    return PanelSwitcher(
      initPage: 'blank',
      backgroundColor: const Color(0xFF472478),
      pageMap: {
        'blank': (context, factor) => Container(
              color: const Color(0xFF472478),
              height: _keyboardRealHeight ?? 0.0,
            ),
        DetailTagPanel.panelName: (context, animation) {
          final tagData = _controller.tagData;
          return FadeTransition(
            opacity: animation,
            child: Container(
              height: _keyboardRealHeight ?? 0.0,
              child: DetailTagPanel(
                selectedTag: tagData,
                onChange: (tag) {
                  if (tagData == null ||
                      (tagData != null && tagData.id == tag.id)) {
                    return;
                  }
                  setState(() {
                    _controller.tagData = tag;
                  });
                },
              ),
            ),
          );
        },
        DetailDateTimePanel.panelName: (context, animation) {
          final taskData = _controller.taskData;
          return FadeTransition(
            opacity: animation,
            child: Container(
              height: _keyboardRealHeight ?? 0.0,
              alignment: Alignment.center,
              child: DetailDateTimePanel(
                selectedDate: taskData?.taskTime,
                onChange: (date) {
                  if (taskData?.taskTime?.year == date.year &&
                      taskData?.taskTime?.month == date.month &&
                      taskData?.taskTime?.day == date.day) {
                    return;
                  }
                  final time = taskData?.taskTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    taskData.taskTime?.hour ?? 0,
                    taskData.taskTime?.minute ?? 0,
                    taskData.taskTime?.second ?? 0,
                  );
                  _controller.updateDatePageBaseTime(time);
                  _controller.taskData = taskData;
                  _controller.datePageJumpTo(0);
                },
              ),
            ),
          );
        },
        DetailTimePanel.panelName: (context, animation) {
          final taskData = _controller.taskData;
          return FadeTransition(
            opacity: animation,
            child: Container(
              height: _keyboardRealHeight ?? 0.0,
              alignment: Alignment.center,
              child: DetailTimePanel(
                selectedDate: taskData?.taskTime,
                onChange: (date) {
                  if (taskData?.taskTime?.hour == date.hour &&
                      taskData?.taskTime?.minute == date.minute &&
                      taskData?.taskTime?.second == date.second) {
                    return;
                  }
                  taskData?.taskTime = DateTime(
                    taskData.taskTime?.year ?? DateTime.now().year,
                    taskData.taskTime?.month ?? DateTime.now().month,
                    taskData.taskTime?.day ?? DateTime.now().day,
                    date.hour,
                    date.minute,
                    date.second,
                  );
                  _controller.taskData = taskData;
                },
              ),
            ),
          );
        }
      },
      controller: _setupPanelController,
    );
  }
}

class EditScreenController {
  _EditMainScreenState? _mainState;
  _SetupPanelBodyState? _panelBodyState;
  _DatePageState? _datePageState;
  _BottomPanelState? _bottomState;
  _DateInfoState? _dateInfoState;

  TaskData? get taskData => _mainState?._taskData;
  set taskData(TaskData? value) => _mainState?._updateTaskData(value);

  TaskTag? get tagData => _mainState?._tagData;
  set tagData(TaskTag? value) => _mainState?._updateTag(value);

  void focusInput() {
    _mainState?._focus();
  }

  void unfocusInput() {
    _mainState?._unfocus();
  }

  void setTransitionAnim(Animation<double> value) {
    _mainState?._setTransitionAnim(value);
  }

  void updateDatePageBaseTime(DateTime? dateTime) {
    _datePageState?._updateBaseTime(dateTime);
  }

  void saveAndBack(BuildContext context) {
    _mainState?._saveAndBack(
        context, _mainState?._taskData, _mainState?._tagData);
  }

  void setBottomPanelTitle(String title) {
    _bottomState?._updateTitle(title);
  }

  void showBottomBar({VoidCallback? callback}) async {
    await _bottomState?._bottomBarController.reverse();
    if (callback != null) {
      callback();
    }
  }

  void hideBottomBar({VoidCallback? callback}) async {
    _bottomState?._bottomBarController.forward();
    if (callback != null) {
      callback();
    }
  }

  void datePageJumpTo(int page) {
    _datePageState?._datePageController?.jumpToPage(page);
  }

  void changeSetupPanel(String pageName, String title) {
    if (_panelBodyState?._setupPanelController?.currentPage == pageName) {
      focusInput();
      return;
    }
    unfocusInput();
    _panelBodyState?._setupPanelController?.switchTo(pageName);
    setBottomPanelTitle(title);
  }

  void forceSwitchToPanel(String pageName) {
    _panelBodyState?._setupPanelController?.switchTo(pageName);
  }

  void switchToDateType(DateTimeType type) {
    _dateInfoState?._switchToType(type);
  }
}
