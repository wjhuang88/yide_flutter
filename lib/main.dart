import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/screen_container.dart';
import 'src/notification.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ScreenContainerController _screenController =
      ScreenContainerController();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      color: const Color(0xFF472478),
      home: NotificationListener<AppNotification>(
        onNotification: (AppNotification n) {
          switch (n.type) {
            case NotificationType.openMenu:
              _screenController.openMenu();
              break;
            case NotificationType.closeMenu:
              _screenController.closeMenu();
              break;
            case NotificationType.dragMenu:
              final dist = n.value as double ?? 0.0;
              _screenController.dragMenu(dist);
              break;
            case NotificationType.dragMenuEnd:
              final v = n.value as double ?? 0.0;
              _screenController.dragMenuEnd(v);
              break;
            default:
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
      theme: CupertinoThemeData(
        primaryColor: const Color(0xFFFFFFFF),
        scaffoldBackgroundColor: const Color(0xFF8346C8),
        brightness: Brightness.dark,
      ),
    );
  }
}
