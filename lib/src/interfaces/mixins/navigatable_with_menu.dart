import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:yide/src/components/slide_drag_detector.dart';
import 'package:yide/src/components/stage_with_menu.dart';
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/main_menu.dart';
import 'package:yide/src/config.dart' as Config;

// 主页面带菜单路由实现
mixin NavigatableWithMenu on Widget implements Navigatable {
  static _WithMenuDragController _controller = _WithMenuDragController();

  @override
  bool get withMene => true;

  void onTransitionValueChange(double value);
  FutureOr<void> onDragNext(BuildContext context, double offset);

  Future<void> openMenu() {
    return _controller.openMenu();
  }

  Future<void> closeMenu() {
    return _controller.closeMenu();
  }

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) {
        anim2.addStatusListener((status) {
          if (status == AnimationStatus.dismissed) {
            isScreenTransitionVertical = false;
          }
        });
        return this;
      },
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final anim2Curved = CurvedAnimation(
          parent: anim2,
          curve: const ElasticOutCurve(1.0),
          reverseCurve: const ElasticInCurve(1.0),
        );
        onTransitionValueChange(anim1Curved.value - anim2Curved.value);
        return AnimatedOpacity(
          duration: Duration.zero,
          opacity: (anim1Curved.value - anim2Curved.value).clamp(0.0, 1.0),
          child: _WithMenuDragBuilder(
            builder: (context, dragOffset, isPopping) {
              final value = anim1Curved.value - anim2Curved.value + dragOffset;
              onTransitionValueChange(value);
              return child;
            },
            onDragNext: (frac) => onDragNext(context, frac),
          ),
        );
      },
    );
  }
}

class _WithMenuDragBuilder extends StatefulWidget {
  final SlidePageBuilder builder;
  final FutureOr<void> Function(double value) onDragNext;

  const _WithMenuDragBuilder({Key key, @required this.builder, this.onDragNext})
      : super(key: key);

  @override
  _WithMenuDragBuilderState createState() => _WithMenuDragBuilderState();
}

class _WithMenuDragController {
  _WithMenuDragBuilderState _state;

  Future<void> openMenu() {
    return _state?._openMenu();
  }

  Future<void> closeMenu() {
    return _state?._closeMenu();
  }
}

class _WithMenuDragBuilderState extends State<_WithMenuDragBuilder> {
  bool _menuMoving = false;
  bool _pageMoving = false;

  StageWithMenuController _menuController = StageWithMenuController();
  SlideDragController _menuDragController = SlideDragController();

  double dragOffset = 0.0;

  Widget get mainMenuWidget => StageWithMenu(
        key: ValueKey('main_menu_container'),
        menu: MainMenu(
          menuConfig: Config.menuConfig,
          key: ValueKey(Config.menuConfig.hashCode),
          closeAction: _closeMenu,
        ),
        onSideTap: _closeMenu,
        child: widget.builder(context, dragOffset, _pageMoving),
        controller: _menuController,
      );

  @override
  void initState() {
    NavigatableWithMenu._controller._state = this;
    super.initState();
  }

  Future<void> _openMenu() async {
    if (_menuMoving) {
      return;
    }
    _menuMoving = true;
    await _menuDragController
        .moveRight()
        .timeout(Duration(milliseconds: 50))
        .catchError((e) {
      _menuMoving = false;
    });
    _menuMoving = false;
    return;
  }

  Future<void> _closeMenu() async {
    if (_menuMoving) {
      return;
    }
    _menuMoving = true;
    await _menuDragController
        .moveLeft()
        .timeout(Duration(milliseconds: 50))
        .catchError((e) {
      _menuMoving = false;
    });
    _menuMoving = false;
    return;
  }

  void _dragMenu(double dist) {
    _menuController.setAnimationValue(dist);
    menuAnimationOffset = dist;
  }

  @override
  Widget build(BuildContext context) {
    return SlideDragDetector(
      leftBarrier: 0.0,
      rightBarrier: 0.7,
      leftSecondBarrier: -0.7,
      isActive: true,
      transitionDuration: const Duration(milliseconds: 800),
      controller: _menuDragController,
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
        setState(() {
          dragOffset = offset;
        });
      },
      onStartDrag: () => _pageMoving = false,
      onLeftSecondMoveHalf: (frac) async {
        if (_pageMoving) return;
        _pageMoving = true;
        if (widget.onDragNext != null) {
          await widget.onDragNext(frac);
        }
        _menuDragController.moveLeftOutbound();
      },
      onLeftSecondDragEnd: (frac) async {
        if (_pageMoving) return;
        _pageMoving = true;
        if (widget.onDragNext != null) {
          await widget.onDragNext(frac);
        }
        _menuDragController.moveLeftOutbound();
      },
      child: mainMenuWidget,
    );
  }
}
