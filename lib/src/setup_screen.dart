import 'package:flutter/cupertino.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/interfaces/navigatable.dart';

import 'notification.dart';

class SetupScreen extends StatelessWidget with SlideNavigatable {
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
            title: '设置',
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
}