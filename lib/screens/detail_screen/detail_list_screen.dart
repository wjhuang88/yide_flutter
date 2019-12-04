import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/components/tap_animator.dart';
import 'package:yide/interfaces/navigatable.dart';
import 'package:yide/models/address_data.dart';
import 'package:yide/models/task_data.dart';
import 'package:yide/screens/edit_main_screen.dart';

import 'detail_comments_screen.dart';
import 'detail_map_screen.dart';
import 'detail_reminder_screen.dart';
import 'detail_repeat_screen.dart';

class DetailListScreen extends StatefulWidget implements Navigatable {
  final TaskPack taskPack;

  const DetailListScreen({Key key, @required this.taskPack}) : super(key: key);

  @override
  _DetailListScreenState createState() => _DetailListScreenState();

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutCubic,
          ),
        );
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(anim1Curved.value),
          child: Opacity(
            opacity: anim1Curved.value - anim2.value,
            child: child,
          ),
        );
      },
    );
  }
}

class _DetailListScreenState extends State<DetailListScreen> {
  TaskData _data;
  TaskTag _tag;

  TaskDetail _detail;

  @override
  void initState() {
    super.initState();
    _data = widget.taskPack.data;
    _tag = widget.taskPack.tag;
    getTaskDetail(_data.id).then((value) {
      setState(() {
        _detail = value;
      });
    });
  }

  @override
  void didUpdateWidget(DetailListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taskPack.data.id != oldWidget.taskPack.data.id) {
      _data = widget.taskPack.data;
      _tag = widget.taskPack.tag;
      getTaskDetail(_data.id).then((value) {
        setState(() {
          _detail = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentStyle =
        const TextStyle(color: Color(0xFFEDE7FF), fontSize: 14.0);
    final nocontentStyle =
        const TextStyle(color: Color(0x88EDE7FF), fontSize: 14.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.chevronLeft,
            color: Color(0xFFD7CAFF),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '完成',
              style: TextStyle(fontSize: 16.0, color: Color(0xFFEDE7FF)),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _HeaderPanel(
            content: _data.content,
            dateTime: _data.taskTime,
            timeType: _data.timeType,
            tagName: _tag.name,
            tagColor: _tag.iconColor,
            onTap: () async {
              final pack =
                  await Navigator.of(context).push<TaskPack>(EditMainScreen(
                taskPack: TaskPack(_data, _tag),
              ).route);
              if (pack != null) {
                setState(() {
                  _data = pack.data;
                  _tag = pack.tag;
                });
              }
            },
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                const SizedBox(
                  height: 40.0,
                ),
                _ListItem(
                  iconData: FontAwesomeIcons.clock,
                  child: _detail?.reminderBitMap != null &&
                          _detail.reminderBitMap.bitMap != 0
                      ? Text(
                          _detail.reminderBitMap.makeLabel(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: contentStyle,
                        )
                      : Text(
                          '点击设置提醒',
                          style: nocontentStyle,
                        ),
                  onTap: () async {
                    final code = await Navigator.of(context)
                        .push<int>(DetailReminderScreen(
                      stateCode: _detail.reminderBitMap?.bitMap ?? 0,
                    ).route);
                    if (code != null) {
                      setState(() {
                        _detail.reminderBitMap?.bitMap = code;
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                _ListItem(
                  iconData: FontAwesomeIcons.redo,
                  child: _detail?.repeatBitMap != null &&
                          !(_detail.repeatBitMap.isNoneRepeat)
                      ? Text(
                          _detail.repeatBitMap.makeRepeatModeLabel() +
                              ' : ' +
                              _detail.repeatBitMap.makeRepeatTimeLabel(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: contentStyle,
                        )
                      : Text(
                          '点击设置重复',
                          style: nocontentStyle,
                        ),
                  onTap: () async {
                    final code = await Navigator.of(context)
                        .push<int>(DetailRepeatScreen(
                      stateCode: _detail.repeatBitMap?.bitMap ?? 0,
                    ).route);
                    if (code != null) {
                      setState(() {
                        _detail.repeatBitMap?.bitMap = code;
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                _ListItem(
                  iconData: FontAwesomeIcons.mapMarkerAlt,
                  child: _detail?.address != null
                      ? Text(
                          _detail.address.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: contentStyle,
                        )
                      : Text(
                          '点击添加地址',
                          style: nocontentStyle,
                        ),
                  onTap: () async {
                    final address = await Navigator.of(context)
                        .push<AroundData>(DetailMapScreen(
                      address: _detail.address,
                    ).route);
                    if (address != null) {
                      setState(() {
                        _detail.address = address;
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                _ListItem(
                  iconData: FontAwesomeIcons.folder,
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
                  iconData: FontAwesomeIcons.stickyNote,
                  child: _data.remark != null && _data.remark.isNotEmpty
                      ? Text(
                          _data.remark,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: contentStyle,
                        )
                      : Text('点击添加备注', style: nocontentStyle),
                  onTap: () async {
                    final value = await Navigator.of(context).push<String>(
                        DetailCommentsScreen(value: _data.remark).route);
                    if (value != null) {
                      setState(() {
                        _data.remark = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: IconButton(
              icon: const Icon(
                FontAwesomeIcons.trashAlt,
                color: Color(0x88EDE7FF),
                size: 21.0,
              ),
              onPressed: () {},
            ),
          ),
        ],
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
    return TapAnimator(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () {},
      builder: (_factor) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(-_factor * Math.pi / 24)
          ..rotateX(_factor * Math.pi / 36),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30.0,
              ),
              Text(
                content,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22.0, color: Color(0xFFEDE7FF)),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                dateTimeString,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14.0, color: Color(0x88EDE7FF)),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    tagName,
                    style: TextStyle(color: tagColor, fontSize: 12.0),
                  )
                ],
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
                  size: 20.0,
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
