import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'notification.dart';
import 'screens/feedback_screen.dart';

class MainMenu extends StatelessWidget {
  final double transformValue;
  final NavigatorObserver navigatorObserver;

  const MainMenu({Key key, this.transformValue = 1.0, this.navigatorObserver})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final contentPadding =
        EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0);
    final angle = (1 - transformValue) * Math.pi / 6;

    NavigatorState navigator =
        navigatorObserver?.navigator ?? Navigator.of(context);

    return SafeArea(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(angle),
        alignment: const FractionalOffset(0.0, 0.5),
        child: Opacity(
          opacity: transformValue.clamp(0.0, 1.0),
          child: ListTileTheme(
            iconColor: const Color(0xFFC19EFD),
            textColor: const Color(0xFFC19EFD),
            contentPadding: contentPadding,
            style: ListTileStyle.drawer,
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              children: <Widget>[
                Container(
                  height: 120.0,
                  padding: contentPadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 70.0,
                        width: 70.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE4C8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FontAwesomeIcons.solidUser,
                          color: Color(0xFF9A76D1),
                          size: 35.0,
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      const Text(
                        '点击登录',
                        style: TextStyle(color: Color(0xFFC19EFD)),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Color(0xFFBF93FF),
                  thickness: 0.2,
                  indent: 25.0,
                  endIndent: 100.0,
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.solidStar,
                    size: 20.0,
                  ),
                  title: const Text(
                    '今天',
                  ),
                  onTap: () => AppNotification(NotificationType.closeMenu)
                      .dispatch(context),
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.inbox,
                    size: 20.0,
                  ),
                  title: const Text(
                    '收集箱',
                  ),
                  onTap: () {},
                ),
                const Divider(
                  color: Color(0xFFBF93FF),
                  thickness: 0.2,
                  indent: 25.0,
                  endIndent: 100.0,
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.plusCircle,
                    size: 20.0,
                  ),
                  title: const Text(
                    '添加项目',
                  ),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding:
                      contentPadding + const EdgeInsets.only(left: 40.0),
                  leading: const Icon(
                    FontAwesomeIcons.minusCircle,
                    size: 20.0,
                  ),
                  title: const Text(
                    '项目一',
                  ),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding:
                      contentPadding + const EdgeInsets.only(left: 40.0),
                  leading: const Icon(
                    FontAwesomeIcons.minusCircle,
                    size: 20.0,
                  ),
                  title: const Text(
                    '项目二',
                  ),
                  onTap: () {},
                ),
                const Divider(
                  color: Color(0xFFBF93FF),
                  thickness: 0.2,
                  indent: 25.0,
                  endIndent: 100.0,
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.archive,
                    size: 20.0,
                  ),
                  title: const Text(
                    '归档内容',
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.ellipsisH,
                    size: 20.0,
                  ),
                  title: const Text(
                    '更多推荐',
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.solidCommentDots,
                    size: 20.0,
                  ),
                  title: const Text(
                    '建议反馈',
                  ),
                  onTap: () {
                    AppNotification(NotificationType.closeMenu)
                        .dispatch(context);
                    navigator.push(FeedbackScreen().route);
                  },
                ),
                const Divider(
                  color: Color(0xFFBF93FF),
                  thickness: 0.2,
                  indent: 25.0,
                  endIndent: 100.0,
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.cogs,
                    size: 20.0,
                  ),
                  title: const Text(
                    '设置',
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}