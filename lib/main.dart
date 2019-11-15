import 'dart:ui';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';

import 'models/task_data.dart';
import 'notification.dart';
import 'screens/detail_screen/edit_main_screen.dart';
import 'screens/detail_screen/detail_list_screen.dart';
import 'screens/splash_screen/splash_screen.dart';
import 'screens/list_screen/list_screen.dart';
import 'screens/detail_screen/detail_screen.dart';
import 'screens/timeline_list_screen.dart';

_ScreenContainerController _screenController = _ScreenContainerController();

void main() => runApp(NotificationListener<AppNotification>(
      child: MyApp(),
      onNotification: (AppNotification n) {
        switch (n.message) {
          case 'open_menu':
            _screenController.openMenu();
            break;
          case 'close_menu':
            _screenController.closeMenu();
            break;
          default:
        }
        return true;
      },
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.level = Level.debug;
    return MaterialApp(
      home: _ScreenContainer(
        controller: _screenController,
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
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFF472478),
        fontFamily: 'SourceHanSans',
      ),
    );
  }
}

class _ScreenContainer extends StatefulWidget {
  const _ScreenContainer({
    Key key,
    this.controller,
  }) : super(key: key);

  final _ScreenContainerController controller;

  @override
  _ScreenContainerState createState() => _ScreenContainerState(controller);
}

class _ScreenContainerController {
  _ScreenContainerState _state;
  void openMenu() {
    _state?._openMenu();
  }

  void closeMenu() {
    _state?._closeMenu();
  }
}

class _ScreenContainerState extends State<_ScreenContainer>
    with SingleTickerProviderStateMixin {
  _ScreenContainerState(this._controller);
  _ScreenContainerController _controller;

  AnimationController _animationController;
  Animation _animation;

  double _offsetValue = 1.0;
  double _animValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller ??= _ScreenContainerController();
    _controller._state = this;
    _animationController = AnimationController(
        value: 0.0, duration: Duration(milliseconds: 400), vsync: this);
    _animation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic);
    _animation.addListener(() {
      setState(() {
        _animValue = _animation.value;
        _offsetValue = 1.0 + (0.85 - 1.0) * _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openMenu() {
    _animationController.forward(from: 0.0);
  }

  void _closeMenu() {
    _animationController.reverse(from: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Material(
          color: const Color(0xFF483666),
          child: _MainMenu(
            transformValue: _animValue,
          ),
        ),
        Transform(
          alignment: Alignment.centerRight,
          transform: Matrix4.identity()..scale(_offsetValue),
          child: FractionalTranslation(
            translation: Offset((1 - _offsetValue) * 5.0, 0.0),
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 130.0 * _animValue),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8346C8), Color(0xFF523F88)]),
                    borderRadius: BorderRadius.circular(25 * _animValue),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 17.0,
                        color: Color(0x8A37256D),
                      ),
                    ]
                  ),
                  child: Opacity(
                    opacity: 1 - _animValue,
                    child: Navigator(
                      initialRoute: '/',
                      onGenerateRoute: (RouteSettings settings) {
                        final String name = settings.name;
                        switch (name) {
                          case '/':
                            return MaterialPageRoute(
                                builder: (context) => SplashScreen());
                          case 'list':
                            return _buildRoute(ListScreen());
                          case 'detail':
                            final args = settings.arguments;
                            assert(args is TaskPack);
                            return _buildRoute(DetailScreen(args));
                          case EditMainScreen.routeName:
                            return EditMainScreen.pageRoute;
                          case DetailListScreen.routeName:
                            return DetailListScreen.pageRoute;
                          case TimelineListScreen.routeName:
                            return TimelineListScreen.pageRoute;
                          default:
                            throw FlutterError(
                                'The builder for route "${settings.name}" returned null.\n'
                                'Route builders must never return null.');
                        }
                      },
                    ),
                  ),
                ),
                Offstage(
                  offstage: !(_offsetValue < 1.0),
                  child: GestureDetector(
                    child: Container(
                      color: Colors.transparent,
                    ),
                    onTap: () {
                      _screenController.closeMenu();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MainMenu extends StatelessWidget {
  final double transformValue;

  const _MainMenu({Key key, this.transformValue = 1.0}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final contentPadding =
        EdgeInsets.symmetric(horizontal: 45.0, vertical: 0.0);
    final angle = (1 - transformValue) * Math.pi / 6;
    return SafeArea(
      child: Transform(
        transform: Matrix4.rotationY(angle * 2)
          ..rotateX(angle)
          ..rotateZ(-angle),
        alignment: Alignment.bottomRight,
        child: Opacity(
          opacity: (transformValue * 3 - 2).clamp(0.0, 1.0),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            children: <Widget>[
              Container(
                height: 100.0,
                padding: contentPadding,
                child: Text(
                  'App名字',
                  style: const TextStyle(color: Colors.white, fontSize: 30.0),
                ),
              ),
              ListTile(
                contentPadding: contentPadding,
                title: Text(
                  '今天',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                contentPadding: contentPadding,
                title: Text(
                  '收集箱',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                contentPadding: contentPadding,
                title: Text(
                  '归档',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}

_buildRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) => child,
    transitionDuration: Duration(milliseconds: 300),
    transitionsBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutSine,
          ),
        ),
        child: child,
      );
    },
  );
}
