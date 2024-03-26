import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/screens/single_day_list_screen.dart';

class SplashScreen extends StatefulWidget implements Navigatable {
  @override
  _SplashScreenState createState() => _SplashScreenState();

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
    );
  }

  @override
  bool get withMene => false;

  @override
  String get name => '启动';
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _moveController;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000), value: 0.0);
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOutQuint),
    );
    _moveAnimation.addListener(() {
      setState(() {});
    });

    _moveController.forward();
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          PushRouteNotification(SingleDayListScreen(), isReplacement: true)
              .dispatch(context);
        },
        child: FractionalTranslation(
          translation: Offset(0.0, 0.2 - 0.2 * _moveAnimation.value),
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: FadeTransition(
              opacity: _moveAnimation,
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
                        style:
                            TextStyle(fontSize: 14.0, color: Color(0xFFE4CEFF)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
