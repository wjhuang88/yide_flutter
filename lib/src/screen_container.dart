import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:yide/src/components/slide_drag_detector.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/screens/multiple_day_list_screen.dart';
import 'package:yide/src/tools/common_tools.dart';

import 'config.dart' as Config;
import 'globle_variable.dart';
import 'main_menu.dart';
import 'screens/splash_screen.dart';
import 'tools/sqlite_manager.dart';

class ScreenContainer extends StatefulWidget implements Navigatable {
  const ScreenContainer({
    Key key,
    this.controller,
  }) : super(key: key);

  final ScreenContainerController controller;

  @override
  _ScreenContainerState createState() => _ScreenContainerState(controller);

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim2Curved = CurvedAnimation(
          parent: anim2,
          curve: const ElasticOutCurve(1.0),
          reverseCurve: const ElasticInCurve(1.0),
        ).value;
        final angle = -anim2Curved * Math.pi / 6;
        return Container(
          color: const Color(0xFF483667),
          child: Opacity(
            opacity: (1 - anim2Curved).clamp(0.0, 1.0),
            child: Transform(
              alignment: const Alignment(1.0, 0.0),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(angle)
                ..translate(150 * anim2Curved)
                ..scale(1 - anim2Curved * 0.5, 0.7 + (1 - anim2Curved) * 0.3),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  bool get withMene => false;
}

class ScreenContainerController {
  _ScreenContainerState _state;

  Future<void> openMenu() async {
    return _state?._openMenu();
  }

  Future<void> closeMenu() async {
    return _state?._closeMenu();
  }

  void menuOn() {
    _state?._slideDragController?.setOn();
  }

  void menuOff() {
    _state?._slideDragController?.setOff();
  }
}

class _ScreenContainerState extends State<ScreenContainer> {
  _ScreenContainerState(this._controller);
  ScreenContainerController _controller;

  SlideDragController _slideDragController;

  double _offsetValue;
  double _animValue;

  bool _menuMoving = false;
  bool _menuOpened = false;

  bool _pageMoving = false;

  DateTime _backPressedAt;

  NavigatorObserver _navigatorObserver;

  var menuData = Config.menuConfig;
  Widget _mainMenuWidget = MainMenu(
      menuConfig: Config.menuConfig, key: ValueKey(Config.menuConfig.hashCode));

  @override
  void initState() {
    super.initState();
    _offsetValue = 0.0;
    _animValue = 0.0;

    _slideDragController = SlideDragController();
    _navigatorObserver = NavigatorObserver();

    _controller ??= ScreenContainerController();
    _controller._state = this;
  }

  @override
  void dispose() {
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
    await _slideDragController.moveRight();
    _menuMoving = false;
    return;
  }

  Future<void> _closeMenu() async {
    if (_menuMoving) {
      return;
    }
    _menuMoving = true;
    await _slideDragController.moveLeft();
    _menuMoving = false;
    return;
  }

  void _dragMenu(double dist) {
    setState(() {
      _animValue = dist;
      _offsetValue = dist;
      if (dist < 0.05) {
        _menuOpened = false;
      } else {
        _menuOpened = true;
      }
    });
  }

  WillPopScope _popScopeValue;
  Widget get _popScope {
    if (_popScopeValue == null) {
      _popScopeValue = _buildPopScope(context, (context) => SplashScreen());
    }
    return _popScopeValue;
  }

  WillPopScope _buildPopScope(BuildContext context,
      Navigatable Function(BuildContext context) initialPage) {
    final scope = WillPopScope(
      key: const ValueKey('main_page_willPopScope'),
      onWillPop: () async {
        final nav = Config.mainNavigatorKey.currentState;
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
    );
    return scope;
  }

  @override
  void didUpdateWidget(ScreenContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_mainMenuWidget.key as ValueKey).value as int !=
        Config.menuConfig.hashCode) {
      _mainMenuWidget = MainMenu(
          menuConfig: Config.menuConfig,
          key: ValueKey(Config.menuConfig.hashCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideDragDetector(
      leftBarrier: 0.0,
      rightBarrier: 0.7,
      leftSecondBarrier: -0.7,
      isActive: false,
      transitionDuration: const Duration(milliseconds: 1000),
      controller: _slideDragController,
      onUpdate: (frac) {
        _dragMenu(frac);
      },
      onRightDragEnd: (frac) {
        _menuMoving = true;
        _menuOpened = true;
      },
      onRightMoveComplete: (frac) {
        _menuMoving = false;
      },
      onLeftDragEnd: (frac) {
        _menuMoving = true;
      },
      onLeftMoveComplete: (frac) {
        _menuMoving = false;
        _menuOpened = false;
      },
      onLeftOutBoundUpdate: (frac) {
        frac = frac * 0.5;
        final offset = frac - frac * frac * frac;
        setState(() {
          singleDayController?.updateTransitionExt(offset);
        });
      },
      onStartDrag: () => _pageMoving = false,
      onLeftSecondMoveHalf: (frac) {
        if (_pageMoving) return;
        PushRouteNotification(MultipleDayListScreen(), callback: (d) {
          _slideDragController.moveLeftOutbound();
        }).dispatch(context);
        haptic();
        _pageMoving = true;
      },
      onLeftSecondDragEnd: (frac) {
        if (_pageMoving) return;
        PushRouteNotification(MultipleDayListScreen(), callback: (d) {
          _slideDragController.moveLeftOutbound();
        }).dispatch(context);
        haptic();
        _pageMoving = true;
      },
      child: _buildMenuContainer(context),
    );
  }

  Widget _buildMenuContainer(BuildContext context) {
    double scale = _offsetValue < 0.0 ? 1.0 : 1.0 - _offsetValue * 0.3;
    double translate = _offsetValue;
    final transform = Matrix4.identity();
    transform.scale(scale);
    double menuTransformValue = _animValue / 0.7;
    final menuAngle = (1 - menuTransformValue) * Math.pi / 4;
    final pagePart = Transform(
      alignment: Alignment.centerRight,
      transform: transform,
      child: FractionalTranslation(
        translation: Offset(translate, 0.0),
        child: Stack(
          children: <Widget>[
            _buildPageContainer(context),
            _buildPageCover(context),
          ],
        ),
      ),
    );
    if (_menuOpened) {
      return Stack(
        children: <Widget>[
          SafeArea(
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..scale(0.5 + menuTransformValue * 0.5,
                    0.9 + menuTransformValue * 0.1)
                ..rotateY(menuAngle),
              alignment: const FractionalOffset(0.0, 0.5),
              child: FractionalTranslation(
                translation: Offset((menuTransformValue - 1) * 0.2, 0.0),
                child: Opacity(
                  opacity: menuTransformValue.clamp(0.0, 1.0),
                  child: _mainMenuWidget,
                ),
              ),
            ),
          ),
          pagePart,
        ],
      );
    } else {
      return pagePart;
    }
  }

  Widget _buildPageContainer(BuildContext context) {
    final opacity = 1 - (_offsetValue / 0.7).clamp(0.0, 1.0);
    Widget inner;
    if (opacity > 0.95) {
      inner = _popScope;
    } else {
      inner = Opacity(
        opacity: opacity,
        child: _popScope,
      );
    }
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: Config.backgroundGradient,
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
        child: inner,
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
