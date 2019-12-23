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
  FutureOr<void> onDragPrevious(BuildContext context, double offset);

  bool get hasNext => false;
  FutureOr<void> onDragNext(BuildContext context, double offset) {}

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
        return AnimatedOpacity(
          duration: Duration.zero,
          opacity: (anim1Curved.value - anim2Curved.value).clamp(0.0, 1.0),
          child: _WithOutMenuDragBuilder(
            builder: (context, dragOffset, isPopping) {
              onTransitionValueChange(
                  1 - anim1Curved.value - anim2Curved.value + dragOffset);
              return child;
            },
            hasNext: hasNext,
            onDragPrevious: (frac) => onDragPrevious(context, frac),
            onDragNext: (frac) => onDragNext(context, frac),
          ),
        );
      },
    );
  }
}

class _WithOutMenuDragBuilder extends StatefulWidget {
  final SlidePageBuilder builder;
  final FutureOr<void> Function(double value) onDragPrevious;
  final FutureOr<void> Function(double value) onDragNext;

  final hasNext;

  const _WithOutMenuDragBuilder(
      {Key key,
      @required this.builder,
      this.onDragPrevious,
      this.onDragNext,
      this.hasNext})
      : super(key: key);

  @override
  _WithOutMenuDragBuilderState createState() => _WithOutMenuDragBuilderState();
}

class _WithOutMenuDragBuilderState extends State<_WithOutMenuDragBuilder> {
  bool _isPoping = false;
  bool _isPushing = false;

  double _dragOffset = 0.0;

  SlideDragController _dragController = SlideDragController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlideDragDetector(
      leftBarrier: 0.0,
      leftSecondBarrier: widget.hasNext ? -1.0 : 0.0,
      rightBarrier: 1.0,
      controller: _dragController,
      onUpdate: (frac) {
        setState(() {
          frac = frac * 0.5;
          _dragOffset = frac - frac * frac * frac;
        });
      },
      onStartDrag: () {
        _isPoping = false;
        _isPushing = false;
      },
      onRightDragEnd: (f) async {
        if (_isPoping) return;
        _isPoping = true;
        if (widget.onDragPrevious != null) {
          await widget.onDragPrevious(f);
        }
      },
      onRightMoveHalf: (f) async {
        if (_isPoping) return;
        _isPoping = true;
        if (widget.onDragPrevious != null) {
          await widget.onDragPrevious(f);
        }
      },
      onLeftOutBoundUpdate: (frac) {
        frac = frac * 0.5;
        final offset = frac - frac * frac * frac;
        setState(() {
          _dragOffset = offset;
        });
      },
      onLeftSecondMoveHalf: (frac) async {
        if (_isPushing) return;
        _isPushing = true;
        if (widget.onDragNext != null) {
          await widget.onDragNext(frac);
        }
        _dragController.moveLeftOutbound();
      },
      onLeftSecondDragEnd: (frac) async {
        if (_isPushing) return;
        _isPushing = true;
        if (widget.onDragNext != null) {
          await widget.onDragNext(frac);
        }
        _dragController.moveLeftOutbound();
      },
      child: widget.builder(context, _dragOffset, _isPoping || _isPushing),
    );
  }
}
