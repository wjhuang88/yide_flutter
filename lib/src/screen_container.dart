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
}

class ScreenContainerController {
  _ScreenContainerState _state;

  Future<void> openMenu() async {
    if (_state?._slideDragController?.isActive ?? false) {
      return _state?._openMenu();
    }
  }

  Future<void> closeMenu() async {
    if (_state?._slideDragController?.isActive ?? false) {
      return _state?._closeMenu();
    }
  }

  void resetMenu() {
    _state?._slideDragController?.reset();
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
  StageWithMenuController _menuController;

  bool _menuMoving = false;

  bool _pageMoving = false;

  DateTime _backPressedAt;

  NavigatorObserver _navigatorObserver;

  @override
  void initState() {
    super.initState();
    _slideDragController = SlideDragController();
    _menuController = StageWithMenuController();
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
    _menuController.setAnimationValue(dist);
    menuAnimationOffset = dist;
  }

  WillPopScope _buildPopScope(BuildContext context,
      Navigatable Function(BuildContext context) initialPage) {
    final scope = WillPopScope(
      key: const ValueKey('main_page_willPopScope'),
      onWillPop: () async {
        final nav = Config.mainNavigatorKey.currentState;
        lastPageType = null;
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

  Widget _menuContainerStorage;
  Widget get _menuContainer {
    if (_menuContainerStorage == null) {
      _menuContainerStorage = StageWithMenu(
        key: ValueKey('main_menu_container'),
        menu: MainMenu(
          menuConfig: Config.menuConfig,
          key: ValueKey(Config.menuConfig.hashCode),
        ),
        onSideTap: _closeMenu,
        child: _buildPopScope(context, (context) => SplashScreen()),
        controller: _menuController,
      );
    }
    return _menuContainerStorage;
  }

  @override
  Widget build(BuildContext context) {
    final mainWidget = SlideDragDetector(
      leftBarrier: 0.0,
      rightBarrier: 0.7,
      leftSecondBarrier: -0.7,
      isActive: false,
      transitionDuration: const Duration(milliseconds: 800),
      controller: _slideDragController,
      onUpdate: (frac) {
        _dragMenu(frac);
      },
      onRightDragEnd: (frac) {
        _menuMoving = true;
      },
      onRightMoveComplete: (frac) {
        _menuMoving = false;
      },
      onLeftDragEnd: (frac) {
        _menuMoving = true;
      },
      onLeftMoveComplete: (frac) {
        _menuMoving = false;
      },
      onLeftOutBoundUpdate: (frac) {
        frac = frac * 0.5;
        final offset = frac - frac * frac * frac;
        singleDayController?.updateTransitionExt(offset);
      },
      onStartDrag: () => _pageMoving = false,
      onLeftSecondMoveHalf: (frac) {
        if (_pageMoving) return;
        PushRouteNotification(MultipleDayListScreen(), callback: (d) {
          _slideDragController.moveLeftOutbound();
          singleDayController?.updateListData();
        }).dispatch(context);
        haptic();
        _pageMoving = true;
      },
      onLeftSecondDragEnd: (frac) {
        if (_pageMoving) return;
        PushRouteNotification(MultipleDayListScreen(), callback: (d) {
          _slideDragController.moveLeftOutbound();
          singleDayController?.updateListData();
        }).dispatch(context);
        haptic();
        _pageMoving = true;
      },
      child: _menuContainer,
    );
    return mainWidget;
  }
}

class StageWithMenu extends StatefulWidget {
  final Widget menu;
  final Widget child;
  final VoidCallback onSideTap;
  final StageWithMenuController controller;

  const StageWithMenu({
    Key key,
    @required this.menu,
    this.onSideTap,
    @required this.child,
    this.controller,
  }) : super(key: key);
  @override
  _StageWithMenuState createState() => _StageWithMenuState();
}

class StageWithMenuController {
  _StageWithMenuState _state;

  void setAnimationValue(double value) => _state?._animValue = value;
}

class _StageWithMenuState extends State<StageWithMenu> {
  double _animValueStorage;
  double get _animValue => _animValueStorage;
  set _animValue(double value) => setState(() => _animValueStorage = value);

  StageWithMenuController controller;

  @override
  void initState() {
    _animValueStorage = menuAnimationOffset ?? 0.0;
    controller = widget.controller ?? StageWithMenuController();
    controller._state = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double scale = _animValue < 0.0 ? 1.0 : 1.0 - _animValue * 0.3;
    final transform = Matrix4.identity();
    transform.scale(scale);
    double menuTransformValue = _animValue / 0.7;
    final menuAngle = (1 - menuTransformValue) * Math.pi / 4;
    final _pagePart = Transform(
      alignment: Alignment.centerRight,
      transform: transform,
      child: FractionalTranslation(
        translation: Offset(_animValue, 0.0),
        child: Stack(
          children: <Widget>[
            _buildPageContainer(context),
            _pageCover,
          ],
        ),
      ),
    );
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
              child: AnimatedOpacity(
                duration: Duration.zero,
                opacity: menuTransformValue.clamp(0.0, 1.0),
                child: widget.menu,
              ),
            ),
          ),
        ),
        _pagePart,
      ],
    );
  }

  Widget _buildPageContainer(BuildContext context) {
    final opacity = 1 - (_animValue / 0.7).clamp(0.0, 1.0);
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
        child: AnimatedOpacity(
          duration: Duration.zero,
          opacity: opacity,
          child: widget.child,
        ),
      ),
    );
  }

  Widget _pageCoverInnerStorage;
  Widget get _pageCover {
    if (_pageCoverInnerStorage == null) {
      _pageCoverInnerStorage = GestureDetector(
        child: Container(
          alignment: Alignment.centerLeft,
          color: const Color(0x00000000),
        ),
        onTap: widget.onSideTap,
      );
    }
    return Offstage(
      offstage: !(_animValue > 0.0),
      child: _pageCoverInnerStorage,
    );
  }
}
