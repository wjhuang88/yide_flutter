import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/navigatable.dart';

import 'notification.dart';

class SetupScreen extends StatelessWidget implements Navigatable {
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
            onLeadingAction: () => PopRouteNotification(isSide: true)
                .dispatch(notificationContext),
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

  @override
  Route get route {
    return PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => this,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, anim1, anim2, child) {
          final anim1Curved = Tween<double>(begin: 0.0, end: 1.0)
              .animate(
                CurvedAnimation(
                  parent: anim1,
                  curve: const ElasticOutCurve(1.0),
                  reverseCurve: Curves.easeInExpo,
                ),
              )
              .value;
          final angle = (1 - anim1Curved) * Math.pi / 4;
          return Opacity(
            opacity: anim1Curved.clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment(-0.6, 0.0),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(angle)
                ..translate(-150 * (1 - anim1Curved))
                ..scale(anim1Curved, 0.7 + anim1Curved * 0.3),
              child: child,
            ),
          );
        });
  }

  @override
  bool get withMene => false;
}
