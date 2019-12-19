import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yide/src/config.dart';

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
  ScreenContainerController _screenController = ScreenContainerController();

  @override
  Widget build(BuildContext context) {
    return NotificationContainer(
      onMenuOpen: () {
        _screenController.resetMenu();
        _screenController.openMenu();
      },
      onMenuClose: () {
        _screenController.resetMenu();
        _screenController.closeMenu();
      },
      onMenuActive: _screenController.menuOn,
      onMenuDeactive: _screenController.menuOff,
      child: CupertinoApp(
        navigatorKey: sideNavigatorKey,
        color: const Color(0xFF472478),
        initialRoute: 'page',
        onGenerateRoute: (RouteSettings settings) {
          final String name = settings.name;
          if ('page' == name) {
            return ScreenContainer(
              controller: _screenController,
            ).route;
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
            primaryColor: Color(0xFF523F88),
            primaryContrastingColor: Color(0xFF483667),
            scaffoldBackgroundColor: Color(0xFF8346C8),
            brightness: Brightness.light,
            textTheme: CupertinoTextThemeData(
              primaryColor: Color(0xFFFFFFFF),
            )),
      ),
    );
  }
}
