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
            leadingIcon: const Icon(
              CupertinoIcons.left_chevron,
              color: Color(0xFFD7CAFF),
              size: 30.0,
            ),
            onLeadingAction: () =>
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
