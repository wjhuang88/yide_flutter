import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/components/tap_animator.dart';
import 'package:yide/interfaces/navigatable.dart';
import 'package:yide/screens/edit_main_screen.dart';

import 'detail_comments_screen.dart';
import 'detail_map_screen.dart';
import 'detail_reminder_screen.dart';
import 'detail_repeat_screen.dart';

class DetailListScreen extends StatefulWidget implements Navigatable {
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
  @override
  Widget build(BuildContext context) {
    final contentStyle =
        const TextStyle(color: Color(0xFFEDE7FF), fontSize: 14.0);

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
            content: '最新项目会议',
            dateTime: '10月11日  19:20',
            tagName: '工作',
            tagColor: const Color(0xFF62DADB),
            onTap: () {
              Navigator.of(context).push(EditMainScreen().route);
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
                  child: Text(
                    '开始提醒&到期时间',
                    style: contentStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(DetailReminderScreen().route);
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                _ListItem(
                  iconData: FontAwesomeIcons.redo,
                  child: Text(
                    '每周重复',
                    style: contentStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(DetailRepeatScreen().route);
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                _ListItem(
                  iconData: FontAwesomeIcons.mapMarkerAlt,
                  child: Text(
                    '地址',
                    style: contentStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(DetailMapScreen().route);
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                _ListItem(
                  iconData: FontAwesomeIcons.folder,
                  child: Text(
                    '所属项目',
                    style: contentStyle,
                  ),
                  onTap: () {},
                ),
                const SizedBox(
                  height: 10.0,
                ),
                _ListItem(
                  iconData: FontAwesomeIcons.stickyNote,
                  child: Text(
                    '备注',
                    style: contentStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(DetailCommentsScreen().route);
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
    @required this.tagName,
    @required this.tagColor,
  }) : super(key: key);

  final VoidCallback onTap;
  final String content;
  final String dateTime;
  final String tagName;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return TapAnimator(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap();
      },
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
                style:
                    const TextStyle(fontSize: 22.0, color: Color(0xFFEDE7FF)),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                dateTime,
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
      onTap: () {
        onTap();
      },
      builder: (animValue) {
        final _factor = 1 - animValue * 0.2;
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            //..rotateY(-(1 - _factor) * Math.pi / 6)
            ..rotateX(-(1 - _factor) * Math.pi / 2),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
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
                child
              ],
            ),
          ),
        );
      },
    );
  }
}
