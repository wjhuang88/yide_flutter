import 'package:flutter/cupertino.dart';
import 'package:yide/src/components/slide_drag_detector.dart';
import 'package:yide/src/tools/common_tools.dart';

import 'config.dart';
import 'main_menu.dart';
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

  NavigatorState get nav => navigateKey.currentState;

  Future<void> openMenu() async {
    return _state?._openMenu();
  }

  Future<void> closeMenu() async {
    return _state?._closeMenu();
  }

  Future<T> pushRoute<T>(Route route) {
    return nav?.push<T>(route);
  }

  Future<T> replaceRoute<T>(Route route) {
    return nav?.pushReplacement(route);
  }

  Future<bool> popRoute<T>(T result) {
    return nav?.maybePop(result);
  }

  void menuOn() {
    _state?._slideDragController?.setOn();
  }

  void menuOff() {
    _state?._slideDragController?.setOff();
  }
}

class _ScreenContainerState extends State<ScreenContainer>
    with SingleTickerProviderStateMixin {
  _ScreenContainerState(this._controller);
  ScreenContainerController _controller;

  AnimationController _animationController;
  Animation _animation;

  SlideDragController _slideDragController;

  double _offsetValue;
  double _animValue;
  double _animStartValue;
  double _animEndValue;

  bool _menuMoving = false;

  DateTime _backPressedAt;

  NavigatorObserver _navigatorObserver;

  @override
  void initState() {
    super.initState();
    _offsetValue = 0.0;
    _animValue = 0.0;
    _animStartValue = 0.0;
    _animEndValue = 1.0;

    _slideDragController = SlideDragController();
    _navigatorObserver = NavigatorObserver();

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
        _animValue = value;
        _offsetValue = value * 0.7;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navigatorObserver.navigator?.dispose();
    _navigatorObserver = null;
    SqliteManager.instance.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    if (_menuMoving) {
      return;
    }
    _menuMoving = true;
    await _slideDragController.forward();
    _menuMoving = false;
    return;
  }

  Future<void> _closeMenu() async {
    if (_menuMoving) {
      return;
    }
    _menuMoving = true;
    await _slideDragController.reverse();
    _menuMoving = false;
    return;
  }

  void _dragMenu(double dist) {
    setState(() {
      _animValue = dist;
      _offsetValue = dist;
    });
  }

  WillPopScope _popScopeValue;
  WillPopScope get _popScope {
    if (_popScopeValue == null) {
      _popScopeValue = _buildPopScope(context);
    }
    return _popScopeValue;
  }

  WillPopScope _buildPopScope(BuildContext context) {
    final nav = _buildNavigator(_navigatorObserver);
    final scope = WillPopScope(
      key: const ValueKey('main_page_willPopScope'),
      onWillPop: () async {
        final nav = _navigatorObserver.navigator;
        // 拦截返回按钮
        // 可以后退则后退
        if (nav.canPop()) {
          await nav.maybePop();
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
      child: nav,
    );
    return scope;
  }

  Navigator _buildNavigator(NavigatorObserver observer) {
    return Navigator(
      key: navigateKey,
      initialRoute: '/',
      observers: [observer],
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
    );
  }

  @override
  void didUpdateWidget(ScreenContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SlideDragDetector(
      startBarrier: 0.0,
      endBarrier: 0.7,
      controller: _slideDragController,
      onUpdate: (frac) {
        _dragMenu(frac);
      },
      onForward: (frac) {
        _menuMoving = true;
      },
      onForwardComplete: (frac) {
        _menuMoving = false;
      },
      onReverse: (frac) {
        _menuMoving = true;
      },
      onReverseComplete: (frac) {
        _menuMoving = false;
      },
      child: Stack(
        children: <Widget>[
          Container(
            color: const Color(0xFF483667),
            child: MainMenu(
              transformValue: _animValue / 0.7,
              navigatorObserver: _navigatorObserver,
            ),
          ),
          Transform(
            alignment: Alignment.centerRight,
            transform: Matrix4.identity()..scale(1.0 - (_offsetValue < 0.0 ? _offsetValue * 2 : _offsetValue) * 0.3),
            child: FractionalTranslation(
              translation: Offset(_offsetValue < 0.0 ? 0.0 : _offsetValue, 0.0),
              child: Stack(
                children: <Widget>[
                  _buildPageContainer(context),
                  _buildPageCover(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildPageContainer(BuildContext context) {
    return Container(
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
          child: _popScope,
        ),
      ),
    );
  }

  Widget _buildPageCover(BuildContext context) {
    return Offstage(
      offstage: !(_offsetValue > 0.0),
      child: GestureDetector(
        child: Container(
          alignment: Alignment.centerLeft,
          color: const Color(0x00000000),
        ),
        onTap: () {
          _closeMenu();
        },
      ),
    );
  }
}
