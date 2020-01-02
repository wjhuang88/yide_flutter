import 'package:flutter/cupertino.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/interfaces/mixins/navigatable_menu_side.dart';
import 'package:yide/src/notification.dart';


class SetupScreen extends StatelessWidget with NavigatableMenuSide {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: <Widget>[
          HeaderBar(
            actionIcon: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '返回',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: const Color(0xFFEDE7FF),
                  ),
                ),
                Icon(
                  CupertinoIcons.right_chevron,
                  size: 26.0,
                  color: const Color(0xFFEDE7FF),
                ),
              ],
            ),
            onAction: () =>
                PopRouteNotification(isSide: true).dispatch(context),
            title: name,
          ),
          Text('测试'),
          Expanded(
            child: Text('测试'),
          ),
          Container(height: 200, child: Text('测试')),
        ],
      ),
    );
  }

  @override
  String get name => '设置';
}
