import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/components/tap_animator.dart';
import 'package:yide/src/interfaces/navigatable.dart';

import 'notification.dart';

class MainMenu extends StatefulWidget {
  final List<List<Map<String, Object?>>> menuConfig;
  final VoidCallback? closeAction;

  static const contentPadding =
      EdgeInsets.symmetric(horizontal: 25.0, vertical: 14.0);

  const MainMenu({super.key, required this.menuConfig, this.closeAction});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late List<List<Map<String, Object?>>> menuConfig;

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
    return ListTileTheme(
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
                  style: TextStyle(color: Color(0xFFFFFFFF)),
                ),
              ],
            ),
          ),
        ]..addAll(
            _buildMenuItems(context),
          ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final result = <Widget>[];
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
                SizedBox(
                  width: 40.0 * (item['level'] as int),
                ),
                item['icon'] as Widget? ?? SizedBox(),
                const SizedBox(
                  width: 20.0,
                ),
                Text(
                  item['name'] as String,
                  style: TextStyle(
                    color:
                        Color(0xFFEDE7FF).withOpacity(0.5 + (1 - factor) * 0.5),
                    fontWeight: FontWeight.w300,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          onTap: () async {
            final route = item['route'] as Function?;
            final isSide = item['side'] as bool? ?? false;
            if (!isSide && widget.closeAction != null) {
              widget.closeAction!();
            }
            if (route != null) {
              final page = route();
              if (page is Navigatable) {
                if (!isSide && widget.closeAction != null) {
                  widget.closeAction!();
                }
                PushRouteNotification(page, isSide: isSide).dispatch(context);
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
