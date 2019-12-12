import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/config.dart';

import 'notification.dart';

class MainMenu extends StatelessWidget {
  final double transformValue;
  final NavigatorObserver navigatorObserver;

  static const contentPadding =
      EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0);

  const MainMenu({Key key, this.transformValue = 1.0, this.navigatorObserver})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final angle = (1 - transformValue) * Math.pi / 6;

    NavigatorState navigator = navigatorObserver?.navigator;

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
              ]..addAll(
                  _buildMenuItems(context, navigator),
                ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, NavigatorState navigator) {
    final result = List<Widget>();
    for (var group in menuConfig) {
      result.add(
        const Divider(
          color: Color(0xFFBF93FF),
          thickness: 0.2,
          indent: 25.0,
          endIndent: 100.0,
        ),
      );
      for (var item in group) {
        final tile = ListTile(
          contentPadding: contentPadding +
              EdgeInsets.only(left: 40.0 * (item['level'] as int)),
          leading: item['icon'],
          title: Text(
            item['name'] as String,
          ),
          onTap: () {
            AppNotification(NotificationType.closeMenu).dispatch(context);
            final route = item['route'] as Function;
            if (route != null) {
              navigator.push(route());
            }
          },
        );
        result.add(tile);
      }
    }
    return result;
  }
}
