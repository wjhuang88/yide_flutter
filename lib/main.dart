import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';

import 'models/task_data.dart';
import 'screens/detail_screen/edit_main_screen.dart';
import 'screens/detail_screen/detail_list_screen.dart';
import 'screens/splash_screen/splash_screen.dart';
import 'screens/list_screen/list_screen.dart';
import 'screens/detail_screen/detail_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Logger.level = Level.debug;
    return MaterialApp(
      title: 'Yide',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale.fromSubtags(languageCode: 'zh'),
      ],
      onGenerateRoute: (RouteSettings settings) {
        final String name = settings.name;
        switch (name) {
          case 'list': {
            return _buildRoute(ListScreen());
          }
          case 'detail': {
            final args = settings.arguments;
            assert(args is TaskPack);
            return _buildRoute(DetailScreen(args));
          }
          case EditMainScreen.routeName: {
            return EditMainScreen.pageRoute;
          }
          case DetailListScreen.routeName: {
            return DetailListScreen.pageRoute;
          }
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

  _buildRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => child,
      transitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutSine,
            ),
          ),
          child: child,
        );
      },
    );
  }
}