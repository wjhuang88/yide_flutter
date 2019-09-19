import 'package:flutter/material.dart';
import 'screens/splash_screen/splash_screen.dart';
import 'components/side_menu/side_menu.dart';
import 'screens/list_screen/list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yide',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        'test': (context) => ListScreen()
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color(0xfff6f7f7)
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

