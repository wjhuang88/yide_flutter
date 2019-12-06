import 'dart:ui';
import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/models/sqlite_manager.dart';

import 'notification.dart';
import 'screens/feedback_screen.dart';
import 'screens/splash_screen.dart';

_ScreenContainerController _screenController = _ScreenContainerController();
NavigatorObserver _navigatorObserver = NavigatorObserver();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      color: const Color(0xFF472478),
      home: NotificationListener<AppNotification>(
        onNotification: (AppNotification n) {
          switch (n.message) {
            case 'open_menu':
              _screenController.openMenu();
              break;
            case 'close_menu':
              _screenController.closeMenu();
              break;
            case 'drag_menu':
              final dist = n.value as double ?? 0.0;
              _screenController.dragMenu(dist);
              break;
            case 'drag_menu_end':
              _screenController.dragMenuEnd();
              break;
            default:
          }
          return true;
        },
        child: _ScreenContainer(
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
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFF472478),
        brightness: Brightness.dark,
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
  Future<void> openMenu() async {
    return _state?._openMenu();
  }

  Future<void> closeMenu() async {
    return _state?._closeMenu();
  }

  void dragMenu(double dist) {
    _state?._dragMenu(dist);
  }

  Future<void> dragMenuEnd() async {
    return _state?._dragMenuEnd();
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

  bool _menuOpen = false;
  bool _isMenuDragging = false;

  @override
  void initState() {
    super.initState();
    _controller ??= _ScreenContainerController();
    _controller._state = this;
    _animationController = AnimationController(
        value: 0.0, duration: Duration(milliseconds: 500), vsync: this);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: const ElasticOutCurve(0.9),
      reverseCurve: const ElasticInCurve(0.9),
    );
    _animation.addListener(() {
      _dragMenu(_animation.value);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    SqliteManager.instance.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    _menuOpen = true;
    return _animationController.forward(from: _animValue);
  }

  Future<void> _closeMenu() async {
    await _animationController.reverse(from: _animValue);
    setState(() {
      _menuOpen = false;
    });
  }

  void _dragMenu(double dist) {
    setState(() {
      _menuOpen = true;
      _animValue = dist;
      _offsetValue = 1.0 + (0.85 - 1.0) * dist;
    });
  }

  Future<void> _dragMenuEnd() async {
    if (_animValue >= 0.5) {
      return _openMenu();
    } else {
      return _closeMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Material(
          color: const Color(0xFF483667),
          child: Offstage(
            offstage: !_menuOpen,
            child: _MainMenu(
              transformValue: _animValue,
            ),
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
                      ]),
                  child: Opacity(
                    opacity: 1 - _animValue.clamp(0.0, 1.0),
                    child: Navigator(
                      initialRoute: '/',
                      observers: [_navigatorObserver],
                      onGenerateRoute: (RouteSettings settings) {
                        final String name = settings.name;
                        if ('/' == name) {
                          return SplashScreen().route;
                        } else {
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
                      alignment: Alignment.centerLeft,
                      color: Colors.transparent,
                    ),
                    onTap: () {
                      _screenController.closeMenu();
                    },
                    onHorizontalDragStart: (detail) {
                      final x = detail.globalPosition.dx;
                      if (x > 0) {
                        _isMenuDragging = true;
                      }
                    },
                    onHorizontalDragEnd: (detail) {
                      _isMenuDragging = false;
                      if (detail.primaryVelocity > 200.0) {
                        AppNotification('open_menu').dispatch(context);
                      } else if (detail.primaryVelocity < -200.0) {
                        AppNotification('close_menu').dispatch(context);
                      } else {
                        AppNotification('drag_menu_end').dispatch(context);
                      }
                    },
                    onHorizontalDragCancel: () {
                      _isMenuDragging = false;
                      AppNotification('drag_menu_end').dispatch(context);
                    },
                    onHorizontalDragUpdate: (detail) {
                      if (_isMenuDragging) {
                        final frac = detail.globalPosition.dx /
                            MediaQuery.of(context).size.width;
                        AppNotification('drag_menu', value: frac)
                            .dispatch(context);
                      }
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
        EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0);
    final angle = (1 - transformValue) * Math.pi / 6;
    return SafeArea(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(angle),
        alignment: const FractionalOffset(0.0, 0.5),
        child: Opacity(
          opacity: transformValue.clamp(0.0, 1.0),
          child: ListTileTheme(
            iconColor: const Color(0xFFC19EFD),
            textColor: const Color(0xFFC19EFD),
            contentPadding: contentPadding,
            style: ListTileStyle.drawer,
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              children: <Widget>[
                Container(
                  height: 120.0,
                  padding: contentPadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 70.0,
                        width: 70.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE4C8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FontAwesomeIcons.solidUser,
                          color: Color(0xFF9A76D1),
                          size: 35.0,
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      const Text(
                        '点击登录',
                        style: TextStyle(color: Color(0xFFC19EFD)),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Color(0xFFBF93FF),
                  thickness: 0.2,
                  indent: 25.0,
                  endIndent: 100.0,
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.solidStar,
                    size: 20.0,
                  ),
                  title: const Text(
                    '今天',
                  ),
                  onTap: () {
                    _screenController.closeMenu();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.inbox,
                    size: 20.0,
                  ),
                  title: const Text(
                    '收集箱',
                  ),
                  onTap: () {},
                ),
                const Divider(
                  color: Color(0xFFBF93FF),
                  thickness: 0.2,
                  indent: 25.0,
                  endIndent: 100.0,
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.plusCircle,
                    size: 20.0,
                  ),
                  title: const Text(
                    '添加项目',
                  ),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding:
                      contentPadding + const EdgeInsets.only(left: 40.0),
                  leading: const Icon(
                    FontAwesomeIcons.minusCircle,
                    size: 20.0,
                  ),
                  title: const Text(
                    '项目一',
                  ),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding:
                      contentPadding + const EdgeInsets.only(left: 40.0),
                  leading: const Icon(
                    FontAwesomeIcons.minusCircle,
                    size: 20.0,
                  ),
                  title: const Text(
                    '项目二',
                  ),
                  onTap: () {},
                ),
                const Divider(
                  color: Color(0xFFBF93FF),
                  thickness: 0.2,
                  indent: 25.0,
                  endIndent: 100.0,
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.archive,
                    size: 20.0,
                  ),
                  title: const Text(
                    '归档内容',
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.ellipsisH,
                    size: 20.0,
                  ),
                  title: const Text(
                    '更多推荐',
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.solidCommentDots,
                    size: 20.0,
                  ),
                  title: const Text(
                    '建议与反馈',
                  ),
                  onTap: () {
                    _screenController.closeMenu();
                    _navigatorObserver.navigator?.push(FeedbackScreen().route);
                  },
                ),
                const Divider(
                  color: Color(0xFFBF93FF),
                  thickness: 0.2,
                  indent: 25.0,
                  endIndent: 100.0,
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.cogs,
                    size: 20.0,
                  ),
                  title: const Text(
                    '设置',
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
