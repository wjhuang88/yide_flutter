import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yide/src/tools/common_tools.dart';

import 'config.dart';
import 'main_menu.dart';
import 'notification.dart';
import 'screens/splash_screen.dart';
import 'tools/sqlite_manager.dart';

class ScreenContainer extends StatefulWidget {
  const ScreenContainer({
    Key key,
    this.controller,
  }) : super(key: key);

  final ScreenContainerController controller;

  @override
  _ScreenContainerState createState() => _ScreenContainerState(controller);
}

class ScreenContainerController {
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

  Future<void> dragMenuEnd(double v) async {
    return _state?._dragMenuEnd(v);
  }
}

class _ScreenContainerState extends State<ScreenContainer>
    with SingleTickerProviderStateMixin {
  _ScreenContainerState(this._controller);
  ScreenContainerController _controller;

  AnimationController _animationController;
  Animation _animation;

  double _offsetValue;
  double _animValue;
  double _animStartValue;
  double _animEndValue;
  double _animDragDelta;
  double _screenWidth;

  bool _menuOpen = false;
  bool _menuMoving = false;
  bool _isMenuDragging = false;

  DateTime _backPressedAt;

  @override
  void initState() {
    super.initState();
    _offsetValue = 0.0;
    _animValue = 0.0;
    _animStartValue = 0.0;
    _animEndValue = 1.0;
    _animDragDelta = 0.0;
    _screenWidth = 1.0;

    _controller ??= ScreenContainerController();
    _controller._state = this;
    _animationController = AnimationController(
        value: 0.0, duration: Duration(milliseconds: 500), vsync: this);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: const ElasticOutCurve(0.9),
      reverseCurve: const ElasticInCurve(0.9),
    );
    _animation.addListener(() {
      final value = _animStartValue +
          (_animEndValue - _animStartValue) * _animation.value;
      setState(() {
        _menuOpen = true;
        _animValue = value;
        _offsetValue = value * 0.7;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    SqliteManager.instance.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    if (_menuMoving) {
      return;
    }
    _menuMoving = true;
    _menuOpen = true;
    _animStartValue = _offsetValue + 0.3;
    _animEndValue = 1.0;
    await _animationController.forward(from: 0.0);
    _animStartValue = 0.0;
    _menuMoving = false;
  }

  Future<void> _closeMenu() async {
    if (_menuMoving) {
      return;
    }
    _menuMoving = true;
    _animStartValue = 0.0;
    _animEndValue = _offsetValue;
    await _animationController.reverse(from: 1.0);
    _animEndValue = 1.0;
    setState(() {
      _menuOpen = false;
    });
    _menuMoving = false;
  }

  void _dragMenu(double dist) {
    setState(() {
      _menuOpen = true;
      _animValue = dist;
      _offsetValue = dist - 0.3;
    });
  }

  Future<void> _dragMenuEnd(double v) async {
    if (v > 700.0) {
      return _openMenu();
    } else if (v < -700.0) {
      return _closeMenu();
    } else if (_offsetValue >= 0.4) {
      return _openMenu();
    } else {
      return _closeMenu();
    }
  }

  NavigatorObserver _navigatorObserver = NavigatorObserver();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Material(
          color: const Color(0xFF483667),
          child: Offstage(
            offstage: !_menuOpen,
            child: MainMenu(
              transformValue: _animValue,
              navigatorObserver: _navigatorObserver,
            ),
          ),
        ),
        Transform(
          alignment: Alignment.centerRight,
          transform: Matrix4.identity()..scale(1.0 - _offsetValue * 0.3),
          child: FractionalTranslation(
            translation: Offset(_offsetValue, 0.0),
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: backgroundGradient,
                    borderRadius: BorderRadius.circular(25 * _animValue),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 17.0,
                        color: Color(0x8A37256D),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25 * _animValue),
                    child: Opacity(
                      opacity: 1 - (_offsetValue / 0.7).clamp(0.0, 1.0),
                      child: WillPopScope(
                        onWillPop: () async {
                          final nav = _navigatorObserver.navigator;
                          // 拦截返回按钮
                          // 可以后退则后退
                          if (nav.canPop()) {
                            nav.maybePop();
                            return false;
                          }
                          // 无法后退则检测是否连续按返回键，连续则推出app
                          if (_backPressedAt == null ||
                              DateTime.now().difference(_backPressedAt) >
                                  Duration(seconds: 1)) {
                            _backPressedAt = DateTime.now();
                            showToast('再次点击退出应用', context, Duration(seconds: 1));
                            return false;
                          }
                          return true;
                        },
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
                  ),
                ),
                _buildPageCover(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageCover(BuildContext context) {
    return Offstage(
      offstage: !(_offsetValue > 0.0),
      child: GestureDetector(
        child: Container(
          alignment: Alignment.centerLeft,
          color: Colors.transparent,
        ),
        onTap: () {
          AppNotification(NotificationType.closeMenu).dispatch(context);
        },
        onHorizontalDragStart: (detail) {
          final x = detail.globalPosition.dx;
          if (x > 0) {
            _isMenuDragging = true;
            _animDragDelta = x;
            _screenWidth = MediaQuery.of(context).size.width;
          }
        },
        onHorizontalDragEnd: (detail) {
          if (!_isMenuDragging) {
            return;
          }
          _isMenuDragging = false;
          AppNotification(NotificationType.dragMenuEnd,
                  value: detail.primaryVelocity)
              .dispatch(context);
        },
        onHorizontalDragCancel: () {
          if (!_isMenuDragging) {
            return;
          }
          _isMenuDragging = false;
          AppNotification(NotificationType.dragMenuEnd).dispatch(context);
        },
        onHorizontalDragUpdate: (detail) {
          if (_isMenuDragging) {
            final frac =
                (detail.globalPosition.dx - _animDragDelta) / _screenWidth +
                    1.0;
            if (frac < 0.3) {
              return;
            }
            AppNotification(NotificationType.dragMenu, value: frac)
                .dispatch(context);
          }
        },
      ),
    );
  }
}
