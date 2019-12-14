import 'dart:async';
import 'dart:math' as Math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/tap_animator.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/models/geo_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/sqlite_manager.dart';
import 'package:yide/src/models/task_data.dart';
import 'package:yide/src/screens/edit_main_screen.dart';
import 'package:yide/src/tools/icon_tools.dart';

import 'detail_screens/detail_comments_screen.dart';
import 'detail_screens/detail_map_screen.dart';
import 'detail_screens/detail_reminder_screen.dart';
import 'detail_screens/detail_repeat_screen.dart';

class DetailListScreen extends StatefulWidget implements Navigatable {
  final TaskPack taskPack;

  const DetailListScreen({Key key, @required this.taskPack}) : super(key: key);

  @override
  _DetailListScreenState createState() => _DetailListScreenState();

  @override
  Route get route {
    return PageRouteBuilder<TaskPack>(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: Duration(milliseconds: 600),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: anim1,
            curve: const ElasticOutCurve(1.0),
            reverseCurve: Curves.easeInToLinear,
          ),
        );
        final opacity = (anim1Curved.value - anim2.value).clamp(0.0, 1.0);
        return Transform.scale(
          alignment: Alignment.centerRight,
          scale: anim1Curved.value,
          child: Opacity(
            opacity: opacity * opacity,
            child: child,
          ),
        );
      },
    );
  }

  @override
  bool get withMene => false;
}

class _DetailListScreenState extends State<DetailListScreen>
    with SingleTickerProviderStateMixin {
  TaskData _data;
  TaskTag _tag;

  TaskDetail _savedDetail;

  double _dragOffset;
  double _dragOffsetStart = 1.0;
  bool _isDragging;
  double _dragDelta = 0.0;
  double _screenWidth = 1.0;

  bool _isLoadingValue = true;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    setState(() {
      _isLoadingValue = value;
    });
  }

  AnimationController _dragController;
  Animation _dragAnim;

  @override
  void initState() {
    super.initState();
    _data = widget.taskPack.data;
    _tag = widget.taskPack.tag;

    _dragOffset = 0.0;
    _isDragging = false;
    _dragController = AnimationController(
        vsync: this, value: 0.0, duration: Duration(milliseconds: 500));
    _dragAnim = CurvedAnimation(
      parent: _dragController,
      curve: const ElasticOutCurve(0.9),
    );
    _dragAnim.addListener(() {
      setState(() {
        _dragOffset = _dragOffsetStart *
            (1 - _dragAnim.value); // lerp from _dragOffsetStart to 0.0
      });
    });

    _savedDetail ??= TaskDetail.defultNull();
    _updateDetailData();
  }

  Future<void> _updateDetailData() async {
    _isLoading = true;
    final detail = await TaskDBAction.getTaskDetailById(_data.id);
    setState(() {
      _savedDetail = detail ?? _savedDetail;
    });
    _isLoading = false;
  }

  Future<int> _saveTask() async {
    _isLoading = true;
    final r = await TaskDBAction.saveTask(_data);
    _isLoading = false;
    return r;
  }

  Future<int> _saveDetail() async {
    _isLoading = true;
    _savedDetail.id = _data.id;
    final r = await TaskDBAction.saveTaskDetail(_savedDetail);
    _isLoading = false;
    return r;
  }

  Future<int> _deleteTask() async {
    _isLoading = true;
    final r = await TaskDBAction.deleteTask(_data);
    _isLoading = false;
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final contentStyle =
        const TextStyle(color: Color(0xFFEDE7FF), fontSize: 14.0);
    final nocontentStyle =
        const TextStyle(color: Color(0x88EDE7FF), fontSize: 14.0);

    return Container(
      decoration: BoxDecoration(
        gradient: backgroundGradient,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        child: FractionalTranslation(
          translation: Offset(_dragOffset, 0.0),
          child: Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()..scale(1 - _dragOffset * 0.3),
            child: GestureDetector(
              onHorizontalDragStart: (detail) {
                final x = detail.globalPosition.dx;
                if (x > 0) {
                  _isDragging = true;
                  _dragDelta = x;
                  _screenWidth = MediaQuery.of(context).size.width;
                }
              },
              onHorizontalDragEnd: (detail) {
                if (!_isDragging) {
                  return;
                }
                _isDragging = false;
                if (detail.primaryVelocity > 700.0 || _dragOffset >= 0.2) {
                  PopRouteNotification().dispatch(context);
                } else {
                  _dragController.forward(from: 0);
                }
              },
              onHorizontalDragCancel: () {
                if (!_isDragging) {
                  return;
                }
                _isDragging = false;
                if (_dragOffset >= 0.2) {
                  PopRouteNotification().dispatch(context);
                } else {
                  _dragController.forward(from: 0);
                }
              },
              onHorizontalDragUpdate: (detail) {
                if (_isDragging) {
                  final frac =
                      (detail.globalPosition.dx - _dragDelta) / _screenWidth;
                  if (frac >= 0.6) {
                    _isDragging = false;
                    PopRouteNotification().dispatch(context);
                  } else {
                    setState(() {
                      final factor = 0.6 * frac;
                      _dragOffsetStart =
                          _dragOffset = factor - factor * factor * factor;
                    });
                  }
                }
              },
              child: Column(
                children: <Widget>[
                  HeaderBar(
                    leadingIcon: const Icon(
                      CupertinoIcons.left_chevron,
                      color: Color(0xFFD7CAFF),
                      size: 30.0,
                    ),
                    actionIcon:
                        _isLoading ? CupertinoActivityIndicator() : null,
                    onLeadingAction: () => PopRouteNotification().dispatch(context),
                  ),
                  _HeaderPanel(
                    content: _data.content,
                    dateTime: _data.taskTime,
                    timeType: _data.timeType,
                    tagName: _tag.name,
                    tagColor: _tag.iconColor,
                    onTap: () async {
                      final packAsync = Completer<TaskPack>();
                      PushRouteNotification(
                        EditMainScreen(taskPack: TaskPack(_data, _tag)),
                        callback: (ret) => packAsync.complete(ret as TaskPack),
                      ).dispatch(context);
                      final pack = await packAsync.future;
                      if (pack != null) {
                        setState(() {
                          _data = pack.data;
                          _tag = pack.tag;
                          _data.tagId = _tag.id;
                        });
                        _saveTask();
                      }
                    },
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        _ListItem(
                          iconData: buildCupertinoIconData(0xf3c8),
                          child: _savedDetail.reminderBitMap != null &&
                                  _savedDetail.reminderBitMap.bitMap != 0
                              ? Text(
                                  _savedDetail.reminderBitMap.makeLabel(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: contentStyle,
                                )
                              : Text(
                                  '点击设置提醒',
                                  style: nocontentStyle,
                                ),
                          onTap: () async {
                            final codeAsync = Completer<int>();
                            PushRouteNotification(
                              DetailReminderScreen(
                                  stateCode:
                                      _savedDetail.reminderBitMap.bitMap ?? 0),
                              callback: (ret) => codeAsync.complete(ret as int),
                            ).dispatch(context);
                            final code = await codeAsync.future;
                            if (code != null) {
                              setState(() {
                                _savedDetail.reminderBitMap.bitMap = code;
                              });
                              _saveDetail();
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        _ListItem(
                          iconData: CupertinoIcons.restart,
                          child: _savedDetail.repeatBitMap != null &&
                                  !(_savedDetail.repeatBitMap.isNoneRepeat)
                              ? Text(
                                  _savedDetail.repeatBitMap
                                          .makeRepeatModeLabel() +
                                      ' - ' +
                                      _savedDetail.repeatBitMap
                                          .makeRepeatTimeLabel(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: contentStyle,
                                )
                              : Text(
                                  '点击设置重复',
                                  style: nocontentStyle,
                                ),
                          onTap: () async {
                            final codeAsync = Completer<int>();
                            PushRouteNotification(
                              DetailRepeatScreen(
                                  stateCode:
                                      _savedDetail.repeatBitMap.bitMap ?? 0),
                              callback: (ret) => codeAsync.complete(ret as int),
                            ).dispatch(context);
                            final code = await codeAsync.future;
                            if (code != null) {
                              setState(() {
                                _savedDetail.repeatBitMap.bitMap = code;
                              });
                              _saveDetail();
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        _ListItem(
                          iconData: buildCupertinoIconData(0xf3a3),
                          child: _savedDetail.address != null &&
                                  _savedDetail.address.name?.isNotEmpty == true
                              ? Text(
                                  _savedDetail.address.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: contentStyle,
                                )
                              : Text(
                                  '点击添加地址',
                                  style: nocontentStyle,
                                ),
                          onTap: () async {
                            final addressAsync = Completer<AroundData>();
                            PushRouteNotification(
                              DetailMapScreen(address: _savedDetail.address),
                              callback: (ret) =>
                                  addressAsync.complete(ret as AroundData),
                            ).dispatch(context);
                            final address = await addressAsync.future;
                            if (address != null) {
                              setState(() {
                                _savedDetail.address = address;
                              });
                              _saveDetail();
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        _ListItem(
                          iconData: CupertinoIcons.folder_solid,
                          child:
                              _data.catalog != null && _data.catalog.isNotEmpty
                                  ? Text(
                                      _data.catalog,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: contentStyle,
                                    )
                                  : Text(
                                      '没有所属项目',
                                      style: nocontentStyle,
                                    ),
                          onTap: () {},
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        _ListItem(
                          iconData: buildCupertinoIconData(0xf418),
                          child: _data.remark != null && _data.remark.isNotEmpty
                              ? Text(
                                  _data.remark,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: contentStyle,
                                )
                              : Text('点击添加备注', style: nocontentStyle),
                          onTap: () async {
                            final valueAsync = Completer<String>();
                            PushRouteNotification(
                              DetailCommentsScreen(value: _data.remark),
                              callback: (ret) =>
                                  valueAsync.complete(ret as String),
                            ).dispatch(context);
                            final value = await valueAsync.future;
                            if (value != null) {
                              setState(() {
                                _data.remark = value;
                              });
                              _saveTask();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: CupertinoButton(
                      child: const Icon(
                        FontAwesomeIcons.trashAlt,
                        color: Color(0x88EDE7FF),
                        size: 25.0,
                      ),
                      onPressed: () async {
                        final isDelete = await showCupertinoDialog<bool>(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('将要删除本事项，请您��认'),
                            content: Text('删除事项后将无法恢复，请确认此次操作是您的真实意图'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('取消'),
                                isDefaultAction: true,
                                onPressed: () =>
                                    Navigator.of(context).maybePop(false),
                              ),
                              CupertinoDialogAction(
                                child: Text('确定删除'),
                                isDestructiveAction: true,
                                onPressed: () =>
                                    Navigator.of(context).maybePop(true),
                              ),
                            ],
                          ),
                        );
                        if (isDelete) {
                          await _deleteTask();
                          PopRouteNotification().dispatch(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({
    Key key,
    @required this.onTap,
    @required this.content,
    @required this.dateTime,
    @required this.timeType,
    @required this.tagName,
    @required this.tagColor,
  }) : super(key: key);

  final VoidCallback onTap;
  final String content;
  final DateTime dateTime;
  final DateTimeType timeType;
  final String tagName;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    var dateTimeString;
    switch (timeType) {
      case DateTimeType.fullday:
        dateTimeString = DateFormat('MM月dd日 全天').format(dateTime);
        break;
      case DateTimeType.someday:
        dateTimeString = '某天';
        break;
      case DateTimeType.datetime:
        dateTimeString = DateFormat('MM月dd日 HH:mm').format(dateTime);
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17.0),
      child: TapAnimator(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () {},
        builder: (_factor) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateY(-_factor * Math.pi / 24)
            ..rotateX(_factor * Math.pi / 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.solidCircle,
                    color: tagColor,
                    size: 8.0,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    tagName ?? '默认',
                    style: TextStyle(color: tagColor, fontSize: 12.0),
                  )
                ],
              ),
              const SizedBox(
                height: 14.0,
              ),
              Text(
                dateTimeString,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFFEDE7FF),
                    fontWeight: FontWeight.w200),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                content,
                textAlign: TextAlign.start,
                style:
                    const TextStyle(fontSize: 20.0, color: Color(0xFFEDE7FF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  _ListItem({
    @required this.iconData,
    @required this.child,
    @required this.onTap,
  });

  final IconData iconData;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapAnimator(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () {},
      builder: (animValue) {
        final _factor = 1 - animValue * 0.2;
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(-(1 - _factor) * Math.pi / 2),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            padding: const EdgeInsets.only(right: 20.0),
            height: 60.0,
            decoration: const BoxDecoration(
              color: Color(0x12FFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 20.0,
                ),
                Icon(
                  iconData,
                  size: 25.0,
                  color: Color(0x88EDE7FF),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                Expanded(child: child)
              ],
            ),
          ),
        );
      },
    );
  }
}
