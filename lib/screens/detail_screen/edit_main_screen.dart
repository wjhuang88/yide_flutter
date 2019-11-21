import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/components/fade_in.dart';
import 'package:yide/components/infinity_page_view.dart';
import 'package:yide/components/tap_animator.dart';
import 'package:yide/models/date_tools.dart';
import 'package:yide/models/task_data.dart';
import 'package:yide/screens/detail_screen/detail_tag_screen.dart';

class EditMainScreen extends StatefulWidget {
  static const String routeName = 'new';

  const EditMainScreen({Key key, this.transitionFactor, this.controller})
      : super(key: key);
  static Route get pageRoute => _buildRoute();

  final double transitionFactor;
  final EditScreenController controller;

  @override
  _EditMainScreenState createState() => _EditMainScreenState(controller);
}

enum _DateTimeType { fullday, someday, datetime }

class _EditMainScreenState extends State<EditMainScreen> {
  _EditMainScreenState(this._controller);

  TextEditingController _textEditingController;
  FocusNode _focusNode;
  double _keyboardRealHeight;

  double transitionFactor;
  EditScreenController _controller;
  FadeInController _fadeInController;

  _DateTimeType _dateTimeType;
  DateTime _baseTime;

  String _content;
  TaskTag _tagData;
  DateTime _dateTime;

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
    transitionFactor = widget.transitionFactor;
    _controller ??= EditScreenController();
    _controller._state = this;
    _textEditingController = TextEditingController(text: _content);
    _textEditingController.addListener(() {
      _content = _textEditingController.text;
    });
    _focusNode = FocusNode();

    _fadeInController = FadeInController();

    _dateTimeType = _DateTimeType.fullday;
    _dateTime ??= DateTime.now();
    _baseTime = _dateTime;
    _tagData ??=
        const TaskTag(id: '1', name: '生活', iconColor: Color(0xFFAF71F5));
  }

  @override
  void didUpdateWidget(EditMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transitionFactor != oldWidget.transitionFactor) {
      transitionFactor = oldWidget.transitionFactor;
    }
  }

  void _updateTransition(double value) {
    setState(() {
      this.transitionFactor = value;
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _keyboardBuildHeight = MediaQuery.of(context).viewInsets.bottom;
    if (_keyboardBuildHeight > 0.0) {
      _keyboardRealHeight = _keyboardBuildHeight;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Opacity(
              opacity: 1 - transitionFactor.clamp(0.0, 1.0),
              child: _buildInputPanel(),
            ),
            const SizedBox(
              height: 25.5,
            ),
            Expanded(
              child: Transform.translate(
                offset: Offset(0.0, 200 * transitionFactor),
                child: Opacity(
                  opacity: 1 - transitionFactor.clamp(0.0, 1.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 80.0,
                        child: InfinityPageView(
                          itemBuilder: (context, i) {
                            final timeToRender =
                                _baseTime.add(Duration(days: i));
                            return Column(
                              children: <Widget>[
                                Text(
                                  _getWeekDayName(timeToRender),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                ),
                                const SizedBox(
                                  height: 12.0,
                                ),
                                Text(
                                  DateFormat('MM月dd日').format(timeToRender),
                                  style: const TextStyle(
                                      color: Color(0xFFBBADE7), fontSize: 14.0),
                                ),
                              ],
                            );
                          },
                          onPageChanged: (page) {
                            _dateTime = _baseTime.add(Duration(days: page));
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      FadeIn(
                        duration: Duration(milliseconds: 250),
                        controller: _fadeInController,
                        child: _buildDatetimeField(_dateTimeType),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              transform:
                  Matrix4.translationValues(0.0, 60.0 * transitionFactor, 0.0),
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildTypeSwitcher('设置时间', _DateTimeType.datetime),
                  _buildTypeSwitcher('全天', _DateTimeType.fullday),
                  _buildTypeSwitcher('某天', _DateTimeType.someday),
                ],
              ),
            ),
            _buildBottomBar(context),
            _buildSetupPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupPanel() {
    return Container(
      transform: Matrix4.translationValues(0.0, 150.0 * transitionFactor, 0.0),
      color: const Color(0xFF472478),
      height: _keyboardRealHeight ?? 0.0,
    );
  }

  Widget _buildTypeSwitcher(String label, _DateTimeType type) {
    return Expanded(
      child: TapAnimator(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_dateTimeType == type) {
            return;
          }
          setState(() {
            _dateTimeType = type;
          });
          _fadeInController.fadeIn();
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
                  color: _dateTimeType == type
                      ? Color.lerp(highlightColor, tapColor, animValue)
                      : Color.lerp(normalColor, tapColor, animValue),
                  fontSize: 14.0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatetimeField(_DateTimeType type) {
    switch (type) {
      case _DateTimeType.fullday:
        return Text(
          '全天',
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        );
      case _DateTimeType.someday:
        return Text(
          '某天',
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        );
      case _DateTimeType.datetime:
        return Text(
          DateFormat('hh:mm').format(_dateTime),
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
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
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.solidCircle,
                color: _tagData.iconColor,
                size: 10.0,
              ),
              SizedBox(
                width: 11.0,
              ),
              TapAnimator(
                builder: (factor) => Text(
                  _tagData.name,
                  style: TextStyle(
                      color: Color.lerp(
                          Colors.white, const Color(0xFFBBADE7), factor),
                      fontSize: 12.0),
                ),
                onTap: () async {
                  final tagResult = await Navigator.of(context)
                      .pushNamed<TaskTag>(DetailTagScreen.routeName,
                          arguments: _tagData);
                  setState(() {
                    _tagData = tagResult ?? _tagData;
                  });
                },
              ),
            ],
          ),
          CupertinoTextField(
            autofocus: true,
            minLines: 3,
            maxLines: 4,
            controller: _textEditingController,
            focusNode: _focusNode,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
            textAlign: TextAlign.center,
            keyboardAppearance: Brightness.dark,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              Navigator.of(context).maybePop();
            },
            placeholder: '记录你今天的任务',
            placeholderStyle: const TextStyle(color: Color(0xFF9B7FE9)),
            decoration: const BoxDecoration(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: const Color(0xFF472478),
      transform: Matrix4.translationValues(0.0, 150.0 * transitionFactor, 0.0),
      height: 45.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).maybePop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    FontAwesomeIcons.arrowAltCircleLeft,
                    color: Color(0xFFBBADE7),
                    size: 16.0,
                  ),
                  const SizedBox(
                    width: 5.5,
                  ),
                  const Text(
                    '返回',
                    style: const TextStyle(
                        color: Color(0xFFBBADE7), fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
          const _VerticleDivider(),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _focusNode.unfocus();
              },
              child: Center(
                child: const Text(
                  '更多设置',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xFFBBADE7), fontSize: 14.0),
                ),
              ),
            ),
          ),
          const _VerticleDivider(),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    FontAwesomeIcons.save,
                    color: Color(0xFFBBADE7),
                    size: 16.0,
                  ),
                  const SizedBox(
                    width: 5.5,
                  ),
                  const Text(
                    '保存',
                    style: const TextStyle(
                        color: Color(0xFFBBADE7), fontSize: 14.0),
                  ),
                ],
              ),
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

_buildRoute() {
  EditScreenController controller = EditScreenController();
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) {
      return EditMainScreen(
        controller: controller,
        transitionFactor: 1.0,
      );
    },
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, anim1, anim2, child) {
      var curve = Curves.easeOutCubic;
      var offset = 1 - curve.transform(anim1.value);
      controller.updateTransition(offset);
      return child;
    },
  );
}

class _VerticleDivider extends StatelessWidget {
  const _VerticleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 11.0),
      decoration: const BoxDecoration(
          border:
              Border(right: BorderSide(color: Color(0xFFE8E8E8), width: 0.5))),
    );
  }
}
