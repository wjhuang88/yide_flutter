import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/common_tools.dart';

import 'config.dart' as Config;
import 'globle_variable.dart';
import 'screens/splash_screen.dart';
import 'tools/sqlite_manager.dart';

class ScreenContainer extends StatefulWidget implements Navigatable {
  const ScreenContainer({
    Key key,
  }) : super(key: key);

  @override
  _ScreenContainerState createState() => _ScreenContainerState();

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim2Curved = CurvedAnimation(
          parent: Tween(begin: 1.0, end: 0.0).animate(anim2),
          curve: const ElasticInCurve(1.0),
          reverseCurve: const ElasticOutCurve(1.0),
        );
        final factor = 1 - anim2Curved.value;
        final angle = -factor * Math.pi / 6;
        return Container(
          color: const Color(0xFF483667),
          child: FadeTransition(
            opacity: anim2Curved,
            child: Transform(
              alignment: const Alignment(1.0, 0.0),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(angle)
                ..translate(150 * factor)
                ..scale(1 - factor * 0.5, 0.7 + (1 - factor) * 0.3),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  bool get withMene => false;

  @override
  String get name => '菜单';
}

class _ScreenContainerState extends State<ScreenContainer> {
  _ScreenContainerState();

  DateTime _backPressedAt;

  NavigatorObserver _navigatorObserver;

  @override
  void initState() {
    super.initState();
    _navigatorObserver = NavigatorObserver();
  }

  @override
  void dispose() {
    _navigatorObserver.navigator?.dispose();
    _navigatorObserver = null;
    SqliteManager.instance.dispose();
    super.dispose();
  }

  Widget _buildNavContainer(BuildContext context,
      Navigatable Function(BuildContext context) initialPage) {
    final scope = WillPopScope(
      key: const ValueKey('main_page_willPopScope'),
      onWillPop: () async {
        final nav = Config.mainNavigatorKey.currentState;
        lastPageType = null;
        // 拦截返回按钮
        // 可以后退则后退
        if (nav.canPop()) {
          PopRouteNotification(callback: (r) => lastPageType = null)
              .dispatch(Config.mainNavigatorKey.currentContext);
          return false;
        }

        // 无法后退则检测是否连续按返回键，连续则推出app
        if (_backPressedAt == null ||
            DateTime.now().difference(_backPressedAt) > Duration(seconds: 1)) {
          _backPressedAt = DateTime.now();
          showToast('再次点击退出应用', context, Duration(seconds: 1));
          return false;
        }
        return true;
      },
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: Config.backgroundGradient),
        child: Navigator(
          key: Config.mainNavigatorKey,
          initialRoute: '/',
          onGenerateRoute: (RouteSettings settings) {
            final String name = settings.name;
            if ('/' == name) {
              return initialPage(context).route;
            } else {
              throw FlutterError(
                  'The builder for route "${settings.name}" returned null.\n'
                  'Route builders must never return null.');
            }
          },
        ),
      ),
    );
    return scope;
  }

  @override
  Widget build(BuildContext context) {
    return _buildNavContainer(context, (context) => SplashScreen());
  }
}
