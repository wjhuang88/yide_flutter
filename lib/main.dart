import 'dart:ui';
import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';

import 'notification.dart';
import 'screens/detail_screen/detail_comments_screen.dart';
import 'screens/detail_screen/detail_map_screen.dart';
import 'screens/detail_screen/detail_reminder_screen.dart';
import 'screens/detail_screen/detail_repeat_screen.dart';
import 'screens/detail_screen/edit_main_screen.dart';
import 'screens/detail_screen/detail_list_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/timeline_list_screen.dart';

_ScreenContainerController _screenController = _ScreenContainerController();
NavigatorObserver _navigatorObserver = NavigatorObserver();

void main() {
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.level = Level.debug;
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

  bool _menuOpen = false;

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
      setState(() {
        _animValue = _animation.value;
        _offsetValue = 1.0 + (0.85 - 1.0) * _animation.value;
      });
    });
    _animation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          _menuOpen = false;
          break;
        case AnimationStatus.forward:
          _menuOpen = true;
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openMenu() {
    _animationController.forward(from: 0.1);
  }

  void _closeMenu() {
    _animationController.reverse(from: 0.9);
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
                      initialRoute: SplashScreen.routeName,
                      observers: [_navigatorObserver],
                      onGenerateRoute: (RouteSettings settings) {
                        final String name = settings.name;
                        switch (name) {
                          case SplashScreen.routeName:
                            return SplashScreen.pageRoute;
                          case EditMainScreen.routeName:
                            return EditMainScreen.pageRoute;
                          case DetailListScreen.routeName:
                            return DetailListScreen.pageRoute;
                          case TimelineListScreen.routeName:
                            return TimelineListScreen.pageRoute;
                          case DetailCommentsScreen.routeName:
                            return DetailCommentsScreen.pageRoute;
                          case FeedbackScreen.routeName:
                            return FeedbackScreen.pageRoute;
                          case DetailMapScreen.routeName:
                            return DetailMapScreen.pageRoute;
                          case DetailRepeatScreen.routeName:
                            return DetailRepeatScreen.pageRoute;
                          case DetailReminderScreen.routeName:
                            return DetailReminderScreen.pageRoute;
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
                      alignment: Alignment.centerLeft,
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
                    _navigatorObserver.navigator
                        ?.pushNamed(FeedbackScreen.routeName);
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
