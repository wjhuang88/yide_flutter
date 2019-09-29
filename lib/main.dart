import 'package:flutter/material.dart';

import 'components/side_menu/side_menu.dart';
import 'screens/splash_screen/splash_screen.dart';
import 'screens/new_task_screen/new_task_screen.dart';

import 'screens/list_screen/list_screen_v2.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yide',
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        final String name = settings.name;
        switch (name) {
          case 'test':
            return PageRouteBuilder(
              pageBuilder: (context, anim1, anim2) => ListScreenV2(),
              transitionDuration: Duration(milliseconds: 500),
              transitionsBuilder: (context, anim1, anim2, child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                      parent: anim1,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: child,
                );
              },
            );
            break;
          case 'add':
            return MaterialPageRoute(
              builder: (context) => NewTaskScreen(),
              fullscreenDialog: true,
            );
            break;
          default:
            throw FlutterError(
              'The builder for route "${settings.name}" returned null.\n'
              'Route builders must never return null.'
            );
        }
      },
      routes: {
        '/': (context) => SplashScreen(),
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color(0xfff6f7f7),
        fontFamily: 'SourceHanSans',
      ),
    );
  }
}

class MainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: <Widget>[
        SideMenu(),
        Expanded(
          child: Container(color: Colors.white,)
        ),
        //SideTimeline(width: 140, color: Color(0xff262626),)
      ],
    );
  }
}

