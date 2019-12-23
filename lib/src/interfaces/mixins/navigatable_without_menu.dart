import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:yide/src/components/slide_drag_detector.dart';
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/interfaces/navigatable.dart';

// 主页面带菜单路由实现
mixin NavigatableWithOutMenu on Widget implements Navigatable {
  @override
  bool get withMene => false;

  void onTransitionValueChange(double value);
  FutureOr<void> onDragNext(BuildContext context, double offset);

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
          curve: const ElasticOutCurve(1.0),
          reverseCurve: const ElasticInCurve(1.0),
        );
        final anim2Curved = CurvedAnimation(
          parent: anim2,
          curve: const ElasticOutCurve(1.0),
          reverseCurve: const ElasticInCurve(1.0),
        );
        onTransitionValueChange(1 - anim1Curved.value - anim2Curved.value);
        return _WithOutMenuDragBuilder(
          builder: (context, dragOffset, isPopping) {
            onTransitionValueChange(
                1 - anim1Curved.value - anim2Curved.value + dragOffset);
            return FadeTransition(
              opacity: anim1Curved,
              child: child,
            );
          },
          onDragNext: (frac) => onDragNext(context, frac),
        );
      },
    );
  }
}

class _WithOutMenuDragBuilder extends StatefulWidget {
  final SlidePageBuilder builder;
  final FutureOr<void> Function(double value) onDragNext;

  const _WithOutMenuDragBuilder(
      {Key key, @required this.builder, this.onDragNext})
      : super(key: key);

  @override
  _WithOutMenuDragBuilderState createState() => _WithOutMenuDragBuilderState();
}

class _WithOutMenuDragBuilderState extends State<_WithOutMenuDragBuilder> {
  bool _isPoping = false;

  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlideDragDetector(
      leftBarrier: 0.0,
      leftSecondBarrier: 0.0,
      rightBarrier: 1.0,
      onUpdate: (frac) {
        setState(() {
          frac = frac * 0.5;
          _dragOffset = frac - frac * frac * frac;
        });
      },
      onStartDrag: () => _isPoping = false,
      onRightDragEnd: (f) async {
        if (_isPoping) return;
        _isPoping = true;
        if (widget.onDragNext != null) {
          await widget.onDragNext(f);
        }
      },
      onRightMoveHalf: (f) async {
        if (_isPoping) return;
        _isPoping = true;
        if (widget.onDragNext != null) {
          await widget.onDragNext(f);
        }
      },
      child: widget.builder(context, _dragOffset, _isPoping),
    );
  }
}
