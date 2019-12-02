import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/interfaces/navigatable.dart';
import 'package:yide/screens/timeline_list_screen.dart';

class SplashScreen extends StatelessWidget implements Navigatable {

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.push(context, TimelineListScreen().route);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: const Icon(
                    FontAwesomeIcons.jedi,
                    size: 150.0,
                    color: Color(0xFFE4CEFF),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: const Text(
                    '点击继续',
                    style: TextStyle(fontSize: 14.0, color: Color(0xFFE4CEFF)),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (context, anim1, anim2, child) {
        return Opacity(
          opacity: 1 - anim2.value,
          child: child,
        );
      },
    );
  }
}
