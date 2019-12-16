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

  bool _lastRouteWithMenu = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorKey: sideNavigatorKey,
      color: const Color(0xFF472478),
      home: NotificationListener<Notification>(
        onNotification: (Notification n) {
          if (n is MenuNotification) {
            () async {
              switch (n.type) {
                case MenuNotificationType.openMenu:
                  await _screenController.openMenu();
                  break;
                case MenuNotificationType.closeMenu:
                  await _screenController.closeMenu();
                  break;
                default:
              }
              if (n.callback != null) n.callback();
            }();
          } else if (n is PushRouteNotification) {
            (() async {
              final temp = _lastRouteWithMenu;
              _lastRouteWithMenu = n.page.withMene;
              if (_lastRouteWithMenu) {
                _screenController.menuOn();
              } else {
                _screenController.menuOff();
              }
              NavigatorState nav;
              if (n.isSide) {
                nav = sideNavigatorKey.currentState;
              } else {
                nav = mainNavigatorKey.currentState;
              }
              var result;
              if (n.isReplacement) {
                result = await nav.pushReplacement(n.page.route);
              } else {
                result = await nav.push(n.page.route);
              }
              _lastRouteWithMenu = temp;
              if (_lastRouteWithMenu) {
                _screenController.menuOn();
              } else {
                _screenController.menuOff();
              }
              (n.callback ?? (arg) {})(result);
            })();
          } else if (n is PopRouteNotification) {
            NavigatorState nav;
            if (n.isSide) {
              nav = sideNavigatorKey.currentState;
            } else {
              nav = mainNavigatorKey.currentState;
            }
            nav.maybePop(n.result).then((ret) {
              (n.callback ?? (arg) {})(ret);
            });
          }
          return true;
        },
        child: ScreenContainer(
          controller: _screenController,
        ),
      ),
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
    );
  }
}
