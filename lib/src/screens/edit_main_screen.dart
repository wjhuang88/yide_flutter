import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/fade_in.dart';
import 'package:yide/src/components/infinity_page_view.dart';
import 'package:yide/src/components/panel_switcher.dart';
import 'package:yide/src/components/tap_animator.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/tools/date_tools.dart';
import 'package:yide/src/tools/sqlite_manager.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/screens/detail_screens/panels/detail_datetime_panel.dart';
import 'package:yide/src/screens/detail_screens/panels/detail_tag_panel.dart';
import 'package:yide/src/screens/detail_screens/panels/detail_time_panel.dart';

class EditMainScreen extends StatefulWidget implements Navigatable {
  const EditMainScreen({Key key, this.taskPack}) : super(key: key);

  static EditScreenController controller = EditScreenController();

  final TaskPack taskPack;

  @override
  _EditMainScreenState createState() => _EditMainScreenState(controller);

  @override
  Route get route => PageRouteBuilder<TaskPack>(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final offset = 1 - anim1Curved.value;
        controller.updateTransition(offset);
        return child;
      },
    );
}

class _EditMainScreenState extends State<EditMainScreen>
    with TickerProviderStateMixin {
  _EditMainScreenState(this._controller);

  TextEditingController _textEditingController;
  FocusNode _focusNode;
  double _keyboardRealHeight;

  double transitionFactor;
  EditScreenController _controller;
  FadeInController _fadeInController;

  AnimationController _bottomBarController;
  Animation _bottomBarAnimation;

  AnimationController _dateListController;
  Animation _dateListAnimation;

  PanelSwitcherController _setupPanelController;
  String _setupTitle = '';

  InfinityPageController _datePageController;

  DateTime _baseTime;

  TaskData _taskData;
  TaskTag _tagData;

  String _getWeekDayName(DateTime dateTime) {
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
  void initState() {
    super.initState();

    _taskData = widget.taskPack?.data ?? TaskData.defultNull();
    _tagData = widget.taskPack?.tag;
    if (_tagData == null) {
      TaskDBAction.getFirstTag().then((tag) {
        setState(() {
          _tagData = tag;
          _taskData.tagId = tag.id;
        });
      });
    } else {
      _taskData.tagId = _tagData.id;
    }

    transitionFactor = 1.0;
    _controller ??= EditScreenController();
    _controller._state = this;
    _textEditingController = TextEditingController(text: _taskData.content);
    _textEditingController.addListener(() {
      _taskData.content = _textEditingController.text;
    });
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _bottomBarController.forward().then((v) => _setupTitle = '');
        _setupPanelController.switchTo('blank');
      }
    });

    _bottomBarController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 250), value: 0.0);
    _bottomBarAnimation = CurvedAnimation(
        parent: _bottomBarController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic)
      ..addListener(() => setState(() {}));

    _dateListController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 250),
        value: _taskData.timeType == DateTimeType.someday ? 1.0 : 0.0);
    _dateListAnimation = CurvedAnimation(
        parent: _dateListController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic)
      ..addListener(() => setState(() {}));

    _fadeInController = FadeInController();
    _setupPanelController = PanelSwitcherController();
    _datePageController = InfinityPageController();

    _baseTime = _taskData.taskTime;
  }

  @override
  void didUpdateWidget(EditMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taskPack.data.content != oldWidget.taskPack.data.content) {
      _taskData.content = widget.taskPack.data.content;
    }
    if (widget.taskPack.tag != oldWidget.taskPack.tag) {
      _tagData = widget.taskPack.tag;
    }
    if (widget.taskPack.data.taskTime != oldWidget.taskPack.data.taskTime) {
      _taskData.taskTime = widget.taskPack.data.taskTime;
    }
    _focus();
  }

  Future<bool> _saveAndBack(
      BuildContext context, TaskData data, TaskTag tag) async {
    data.tagId = tag.id;
    final pack = TaskPack(data, tag);
    return Navigator.of(context).maybePop<TaskPack>(pack);
  }

  void _updateTransition(double value) {
    setState(() {
      this.transitionFactor = value;
    });
  }

  @override
  void dispose() {
    _datePageController.dispose();
    _bottomBarController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    _controller._state = null;
    super.dispose();
  }

  void _unfocus() {
    _focusNode.unfocus();
    _bottomBarController.reverse();
  }

  void _focus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _changePanel(String pageName, String title) {
    if (_setupPanelController.currentPage == pageName) {
      _focus();
      return;
    }
    _unfocus();
    _setupPanelController.switchTo(pageName);
    setState(() {
      _setupTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _keyboardBuildHeight = MediaQuery.of(context).viewInsets.bottom;
    if (_keyboardBuildHeight > 0.0) {
      _keyboardRealHeight = _keyboardBuildHeight;
    }

    final opacity = 1 - transitionFactor.clamp(0.0, 1.0);

    final _setupOffset = 150.0 * transitionFactor;
    final _bottomOffset = _setupOffset + (1 - _bottomBarAnimation.value) * 50;
    final _bottomOpacity = _bottomBarAnimation.value;

    return Opacity(
      opacity: opacity,
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
                const SizedBox(
                  height: 25.5,
                ),
                Expanded(
                  child: Transform.translate(
                    offset: Offset(0.0, 200 * transitionFactor),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _changePanel(DetailDateTimePanel.panelName, '日期');
                          },
                          child: Container(
                            height: 80.0,
                            child: FractionalTranslation(
                              translation:
                                  Offset(0.0, -_dateListAnimation.value * 0.1),
                              child: Opacity(
                                opacity: 1 - _dateListAnimation.value,
                                child: InfinityPageView(
                                  controller: _datePageController,
                                  itemBuilder: (context, i) {
                                    final timeToRender =
                                        _baseTime.add(Duration(days: i));
                                    return Column(
                                      children: <Widget>[
                                        Text(
                                          _getWeekDayName(timeToRender),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0),
                                        ),
                                        Text(
                                          DateFormat('MM月dd日')
                                              .format(timeToRender),
                                          style: const TextStyle(
                                              color: Color(0xFFBBADE7),
                                              fontSize: 14.0,
                                              fontFamily: ''),
                                        ),
                                      ],
                                    );
                                  },
                                  onPageChanged: (page) {
                                    setState(() {
                                      _taskData.taskTime =
                                          _baseTime.add(Duration(days: page));
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        FractionalTranslation(
                          translation: Offset(0.0, -_dateListAnimation.value),
                          child: FadeIn(
                            duration: Duration(milliseconds: 250),
                            controller: _fadeInController,
                            child: _buildDatetimeField(_taskData.timeType),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(
                      0.0, 60.0 * transitionFactor, 0.0),
                  height: 40.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildTypeSwitcher('设置时间', DateTimeType.datetime),
                      _buildTypeSwitcher('全天', DateTimeType.fullday),
                      _buildTypeSwitcher('某天', DateTimeType.someday),
                    ],
                  ),
                ),
                Stack(
                  children: <Widget>[
                    _buildSetupPanel(context, _setupOffset, 1 - _bottomOpacity,
                        title: _setupTitle),
                    Offstage(
                      offstage: _bottomOpacity < 0.01,
                      child: Opacity(
                        opacity: _bottomOpacity,
                        child: _buildBottomBar(context, _bottomOffset),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupPanel(
      BuildContext context, double offset, double titleOpacity,
      {String title = ''}) {
    return Container(
      transform: Matrix4.translationValues(0.0, offset, 0.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _focus();
            },
            child: Container(
              height: 44.0,
              color: const Color(0xFF472478),
              child: Opacity(
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
          PanelSwitcher(
            initPage: 'blank',
            backgroundColor: const Color(0xFF472478),
            pageMap: {
              'blank': (context, factor) => Container(
                    color: const Color(0xFF472478),
                    height: _keyboardRealHeight ?? 0.0,
                  ),
              DetailTagPanel.panelName: (context, factor) => Opacity(
                    opacity: factor,
                    child: Container(
                      height: _keyboardRealHeight ?? 0.0,
                      child: DetailTagPanel(
                        selectedTag: _tagData,
                        onChange: (tag) {
                          if (tag == null ||
                              (_tagData != null && _tagData.id == tag.id)) {
                            return;
                          }
                          setState(() {
                            _tagData = tag;
                          });
                        },
                      ),
                    ),
                  ),
              DetailDateTimePanel.panelName: (context, factor) {
                return Opacity(
                  opacity: factor,
                  child: Container(
                    height: _keyboardRealHeight ?? 0.0,
                    alignment: Alignment.center,
                    child: DetailDateTimePanel(
                      selectedDate: _taskData.taskTime,
                      onChange: (date) {
                        if (_taskData.taskTime.year == date.year &&
                            _taskData.taskTime.month == date.month &&
                            _taskData.taskTime.day == date.day) {
                          return;
                        }
                        setState(() {
                          _baseTime = _taskData.taskTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              _taskData.taskTime.hour,
                              _taskData.taskTime.minute,
                              _taskData.taskTime.second);
                          _datePageController.jumpToPage(0);
                        });
                      },
                    ),
                  ),
                );
              },
              DetailTimePanel.panelName: (context, factor) => Opacity(
                    opacity: factor,
                    child: Container(
                      height: _keyboardRealHeight ?? 0.0,
                      alignment: Alignment.center,
                      child: DetailTimePanel(
                        selectedDate: _taskData.taskTime,
                        onChange: (date) {
                          if (_taskData.taskTime.hour == date.hour &&
                              _taskData.taskTime.minute == date.minute &&
                              _taskData.taskTime.second == date.second) {
                            return;
                          }
                          setState(() {
                            _taskData.taskTime = DateTime(
                                _taskData.taskTime.year,
                                _taskData.taskTime.month,
                                _taskData.taskTime.day,
                                date.hour,
                                date.minute,
                                date.second);
                          });
                        },
                      ),
                    ),
                  )
            },
            controller: _setupPanelController,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSwitcher(String label, DateTimeType type) {
    return Expanded(
      child: TapAnimator(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_taskData.timeType == type) {
            return;
          }
          setState(() {
            _taskData.timeType = type;
          });
          if (type == DateTimeType.someday) {
            _dateListController.forward();
          } else {
            _dateListController.reverse();
          }
          _fadeInController.fadeIn();
          _focus();
        },
        builder: (animValue) {
          final highlightColor = const Color(0xFFFFFFFF);
          final normalColor = const Color(0xFFBBADE7);
          final tapColor = const Color(0x88BBADE7);
          return Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _taskData.timeType == type
                      ? Color.lerp(highlightColor, tapColor, animValue)
                      : Color.lerp(normalColor, tapColor, animValue),
                  fontSize: 14.0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatetimeField(DateTimeType type) {
    switch (type) {
      case DateTimeType.fullday:
        return Text(
          '全天',
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        );
      case DateTimeType.someday:
        return Text(
          '某天',
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        );
      case DateTimeType.datetime:
        return GestureDetector(
          onTap: () {
            _changePanel(DetailTimePanel.panelName, '时间');
          },
          child: Container(
            child: Text(
              DateFormat('HH:mm').format(_taskData.taskTime),
              style: const TextStyle(
                  color: Colors.white, fontSize: 20.0, fontFamily: ''),
            ),
          ),
        );
      default:
        return Text(
          '未设定',
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        );
    }
  }

  Widget _buildInputPanel() {
    return Container(
      transform: Matrix4.translationValues(0.0, -100.0 * transitionFactor, 0.0),
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
          TapAnimator(
            behavior: HitTestBehavior.opaque,
            builder: (factor) => Row(
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.solidCircle,
                  color: _tagData?.iconColor ?? Colors.white,
                  size: 10.0,
                ),
                SizedBox(
                  width: 11.0,
                ),
                Text(
                  _tagData?.name ?? '默认',
                  style: TextStyle(
                      color: Color.lerp(
                          Colors.white, const Color(0xFFBBADE7), factor),
                      fontSize: 12.0),
                ),
              ],
            ),
            onTap: () {
              _changePanel(DetailTagPanel.panelName, '标签');
            },
          ),
          const SizedBox(
            height: 8.0,
          ),
          CupertinoTextField(
            autofocus: true,
            minLines: 3,
            maxLines: 4,
            cursorWidth: 1.0,
            cursorColor: const Color(0xFFFAB807),
            controller: _textEditingController,
            focusNode: _focusNode,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardAppearance: Brightness.dark,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              _saveAndBack(context, _taskData, _tagData);
            },
            placeholder: '记录你的任务',
            placeholderStyle: const TextStyle(color: Color(0xFF9B7FE9)),
            decoration: const BoxDecoration(color: Colors.transparent),
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
              onTap: () => Navigator.of(context).maybePop(),
              builder: (factor) {
                final color =
                    const Color(0xFFBBADE7).withOpacity(1 - factor * 0.5);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.arrowAltCircleLeft,
                      color: color,
                      size: 16.0,
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
            indent: 11.0,
            endIndent: 11.0,
            width: 0.0,
            color: const Color(0xFFE8E8E8),
          ),
          Expanded(
            child: TapAnimator(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _unfocus();
              },
              builder: (factor) => Center(
                child: Text(
                  '更多设置',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:
                          const Color(0xFFBBADE7).withOpacity(1 - factor * 0.5),
                      fontSize: 14.0),
                ),
              ),
            ),
          ),
          const VerticalDivider(
            indent: 11.0,
            endIndent: 11.0,
            width: 0.0,
            color: const Color(0xFFE8E8E8),
          ),
          Expanded(
            child: TapAnimator(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _saveAndBack(context, _taskData, _tagData);
              },
              builder: (factor) {
                final color =
                    const Color(0xFFBBADE7).withOpacity(1 - factor * 0.5);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.save,
                      color: color,
                      size: 16.0,
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
}

class EditScreenController {
  _EditMainScreenState _state;

  void updateTransition(double value) {
    _state?._updateTransition(value);
  }
}
