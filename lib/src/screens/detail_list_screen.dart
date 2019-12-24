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
import 'package:yide/src/tools/common_tools.dart';
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
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInToLinear,
          ),
        );
        final opacity = AnimationPageFade(anim1Curved, anim2);
        return FractionalTranslation(
          translation: Offset(0.0, 1.0 - anim1Curved.value),
          child: FadeTransition(
            opacity: opacity,
            child: child,
          ),
        );
      },
    );
  }

  @override
  bool get withMene => false;
}

class AnimationPageFade extends CompoundAnimation<double> {
  AnimationPageFade(Animation<double> first, Animation<double> next)
      : super(first: first, next: next);
  @override
  double get value {
    final opacity = first.value - next.value;
    return opacity * opacity;
  }
}

class _DetailListScreenState extends State<DetailListScreen>
    with SingleTickerProviderStateMixin {
  TaskData _data;
  TaskTag _tag;

  TaskDetail _savedDetail;

  bool _isLoadingValue = true;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    setState(() {
      _isLoadingValue = value;
    });
  }

  ScrollController _scrollController;
  bool _backProcessing = false;

  @override
  void initState() {
    super.initState();
    _data = widget.taskPack.data;
    _tag = widget.taskPack.tag;

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset <
          _scrollController.position.minScrollExtent - 100) {
        if (_backProcessing) {
          return;
        }
        _backProcessing = true;
        haptic();
        PopRouteNotification().dispatch(context);
      }
    });

    _savedDetail ??= TaskDetail.defultNull();
    _updateDetailData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        child: Column(
          children: <Widget>[
            HeaderBar(
              leadingIcon: const Icon(
                CupertinoIcons.clear,
                color: Color(0xFFD7CAFF),
                size: 40.0,
              ),
              onLeadingAction: () => PopRouteNotification().dispatch(context),
              actionIcon: _isLoading
                  ? CupertinoActivityIndicator()
                  : const Icon(
                      CupertinoIcons.minus_circled,
                      color: Color(0xFFD7CAFF),
                      size: 25.0,
                    ),
              onAction: _isLoading
                  ? null
                  : () async {
                      final isDelete = await showCupertinoModalPopup<bool>(
                        context: context,
                        builder: (context) => CupertinoActionSheet(
                          message: Text('删除此任务？'),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              child: Text('是，我要删除！', style: const TextStyle(color: Color(0xDDFF0000), fontSize: 16.0),),
                              isDestructiveAction: true,
                              onPressed: () =>
                                  Navigator.of(context).maybePop(true),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: Text('取消', style: const TextStyle(color: Color(0xFF000000), fontSize: 16.0),),
                            isDefaultAction: true,
                            onPressed: () =>
                                Navigator.of(context).maybePop(false),
                          ),
                        ),
                      );
                      if (isDelete != null && isDelete) {
                        await _deleteTask();
                        PopRouteNotification().dispatch(context);
                      }
                    },
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: EdgeInsets.zero,
                children: <Widget>[
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
                    height: 40.0,
                  ),
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
                    onTap: _reminderForward,
                    onLongPress: () {
                      editPopup(
                        context,
                        onEdit: _reminderForward,
                        onClear: () {
                          setState(() {
                            _savedDetail.reminderBitMap.bitMap = 0;
                          });
                          _saveDetail();
                        },
                      );
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
                            _savedDetail.repeatBitMap.makeRepeatModeLabel() +
                                ' - ' +
                                _savedDetail.repeatBitMap.makeRepeatTimeLabel(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: contentStyle,
                          )
                        : Text(
                            '点击设置重复',
                            style: nocontentStyle,
                          ),
                    onTap: _repeatForward,
                    onLongPress: () {
                      editPopup(
                        context,
                        onEdit: _repeatForward,
                        onClear: () {
                          setState(() {
                            _savedDetail.repeatBitMap.bitMap =
                                RepeatBitMap.noneBitmap;
                          });
                          _saveDetail();
                        },
                      );
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
                    onTap: _addressForward,
                    onLongPress: () {
                      editPopup(
                        context,
                        onEdit: _addressForward,
                        onClear: () {
                          setState(() {
                            _savedDetail.address = null;
                          });
                          _saveDetail();
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _ListItem(
                    iconData: CupertinoIcons.folder_solid,
                    child: _data.catalog != null && _data.catalog.isNotEmpty
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
                    onTap: _remarkForward,
                    onLongPress: () {
                      editPopup(
                        context,
                        onEdit: _remarkForward,
                        onClear: () {
                          setState(() {
                            _data.remark = null;
                          });
                          _saveTask();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reminderForward() async {
    final codeAsync = Completer<int>();
    PushRouteNotification(
      DetailReminderScreen(stateCode: _savedDetail.reminderBitMap.bitMap ?? 0),
      callback: (ret) => codeAsync.complete(ret as int),
    ).dispatch(context);
    final code = await codeAsync.future;
    if (code != null) {
      setState(() {
        _savedDetail.reminderBitMap.bitMap = code;
      });
      _saveDetail();
    }
  }

  Future<void> _repeatForward() async {
    final codeAsync = Completer<int>();
    PushRouteNotification(
      DetailRepeatScreen(stateCode: _savedDetail.repeatBitMap.bitMap ?? 0),
      callback: (ret) => codeAsync.complete(ret as int),
    ).dispatch(context);
    final code = await codeAsync.future;
    if (code != null) {
      setState(() {
        _savedDetail.repeatBitMap.bitMap = code;
      });
      _saveDetail();
    }
  }

  Future<void> _addressForward() async {
    final addressAsync = Completer<AroundData>();
    PushRouteNotification(
      DetailMapScreen(address: _savedDetail.address),
      callback: (ret) => addressAsync.complete(ret as AroundData),
    ).dispatch(context);
    final address = await addressAsync.future;
    if (address != null) {
      setState(() {
        _savedDetail.address = address;
      });
      _saveDetail();
    }
  }

  Future<void> _remarkForward() async {
    final valueAsync = Completer<String>();
    PushRouteNotification(
      DetailCommentsScreen(value: _data.remark),
      callback: (ret) => valueAsync.complete(ret as String),
    ).dispatch(context);
    final value = await valueAsync.future;
    if (value != null) {
      setState(() {
        _data.remark = value;
      });
      _saveTask();
    }
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
    this.onLongPress,
  });

  final IconData iconData;
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return TapAnimator(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () {},
      onLongPress: onLongPress,
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
