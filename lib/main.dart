import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/tools/sqlite_manager.dart';

import 'src/screen_container.dart';
import 'src/notification.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer _updateTimer;
  DateTime _lastUpdateTime;

  void _updateOnDateChange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_lastUpdateTime == null || !today.isAtSameMomentAs(_lastUpdateTime)) {
      print('Start to update recurring task list when app init.');
      TaskDBAction.updateRecurringNextTime().then((f) {
        print('Update recurring task list complete.');
      });
      _lastUpdateTime = today;
    } else {
      print('Date not change.');
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.run(_updateOnDateChange);
    _updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      print('Updated on date change.');
      _updateOnDateChange();
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationContainer(
      child: CupertinoApp(
        navigatorKey: sideNavigatorKey,
        color: const Color(0xFFCD86AD),
        initialRoute: 'page',
        onGenerateRoute: (RouteSettings settings) {
          final String name = settings.name;
          if ('page' == name) {
            return ScreenContainer().route;
          } else {
            throw FlutterError(
                'The builder for route "${settings.name}" returned null.\n'
                'Route builders must never return null.');
          }
        },
        title: 'Yide',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale.fromSubtags(languageCode: 'zh'),
        ],
        theme: const CupertinoThemeData(
            primaryColor: Color(0xFFCD86AD),
            primaryContrastingColor: Color(0xFFCD86AD),
            scaffoldBackgroundColor: Color(0xFFCD86AD),
            brightness: Brightness.light,
            textTheme: CupertinoTextThemeData(
              primaryColor: Color(0xFFFFFFFF),
            )),
      ),
    );
  }
}
