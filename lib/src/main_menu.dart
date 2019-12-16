import 'dart:math' as Math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/components/tap_animator.dart';
import 'package:yide/src/interfaces/navigatable.dart';

import 'notification.dart';

class MainMenu extends StatefulWidget {
  final double transformValue;
  final List<List<Map<String, Object>>> menuConfig;

  static const contentPadding =
      EdgeInsets.symmetric(horizontal: 25.0, vertical: 14.0);

  const MainMenu(
      {Key key, this.transformValue = 1.0, @required this.menuConfig})
      : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<List<Map<String, Object>>> menuConfig;

  @override
  void initState() {
    menuConfig = widget.menuConfig;
    super.initState();
  }

  @override
  void didUpdateWidget(MainMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.menuConfig != oldWidget.menuConfig ||
        widget.menuConfig.hashCode != oldWidget.menuConfig.hashCode) {
      menuConfig = widget.menuConfig;
    }
  }

  @override
  Widget build(BuildContext context) {
    final angle = (1 - widget.transformValue) * Math.pi / 6;
    return SafeArea(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(angle),
        alignment: const FractionalOffset(0.0, 0.5),
        child: Opacity(
          opacity: widget.transformValue.clamp(0.0, 1.0),
          child: ListTileTheme(
            iconColor: const Color(0xFFC19EFD),
            textColor: const Color(0xFFC19EFD),
            contentPadding: MainMenu.contentPadding,
            style: ListTileStyle.drawer,
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              children: <Widget>[
                Container(
                  height: 120.0,
                  padding: MainMenu.contentPadding,
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
                  _buildMenuItems(context),
                ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
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
        final tile = TapAnimator(
          behavior: HitTestBehavior.opaque,
          builder: (factor) => Container(
            padding: MainMenu.contentPadding,
            child: Row(
              children: <Widget>[
                SizedBox(width: 40.0 * (item['level'] as int),),
                item['icon'],
                const SizedBox(
                  width: 20.0,
                ),
                Text(
                  item['name'] as String,
                  style: TextStyle(
                    color: Color(0xFFEDE7FF).withOpacity(0.5 + (1 - factor) * 0.5),
                    fontWeight: FontWeight.w300,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          onTap: () async {
            final route = item['route'] as Function;
            final isSide = item['side'] as bool;
            if (!isSide) {
              MenuNotification(MenuNotificationType.closeMenu)
                  .dispatch(context);
            }
            if (route != null) {
              final page = route();
              if (page is Navigatable) {
                PushRouteNotification(page, isSide: isSide)
                    .dispatch(context);
              }
            }
          },
        );
        result.add(tile);
      }
    }
    return result;
  }
}
