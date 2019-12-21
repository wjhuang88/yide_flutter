import 'dart:math' as Math;
import 'package:flutter/widgets.dart';
import 'package:yide/src/components/slide_drag_detector.dart';
import 'package:yide/src/config.dart' as Config;
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/common_tools.dart';

abstract class Navigatable {
  Route get route;
  bool get withMene;
}

mixin SlideNavigatable on Widget implements Navigatable {
  @override
  bool get withMene => false;

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = Tween<double>(begin: 0.0, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: anim1,
                curve: const ElasticOutCurve(1.0),
                reverseCurve: Curves.easeInExpo,
              ),
            )
            .value;
        return _DragBuilder(
          builder: (context, slideValue, isPopped) {
            final finalSlideValue = (slideValue > 0.0 ? 0.0 : slideValue) * 0.5;
            final animValue = anim1Curved + finalSlideValue;
            final opacity = animValue.clamp(0.0, 1.0);
            final angle = (1 - animValue) * Math.pi / 6;
            final radius = Radius.circular(100 * (1 - animValue));
            return Stack(
              children: <Widget>[
                Offstage(
                  offstage: isPopped,
                  child: AnimatedOpacity(
                    duration: Duration.zero,
                    opacity: opacity,
                    child: Container(
                      color: const Color(0xFF483667),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: Duration.zero,
                  opacity: anim1Curved.clamp(0.0, 1.0),
                  child: Transform(
                    alignment: const Alignment(-0.6, 0.0),
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(angle)
                      ..translate(-150 * (1 - animValue))
                      ..scale(animValue, 0.7 + animValue * 0.3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topRight: radius, bottomRight: radius),
                      child: child,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DragBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, double slideValue, bool isPopped)
      builder;

  const _DragBuilder({Key key, @required this.builder}) : super(key: key);

  @override
  _DragBuilderState createState() => _DragBuilderState();
}

class _DragBuilderState extends State<_DragBuilder> {
  double _slideValue = 0.0;
  bool _isPoping = true;
  @override
  Widget build(BuildContext context) {
    return SlideDragDetector(
      leftBarrier: -1.0,
      rightBarrier: 0.0,
      transitionDuration: const Duration(milliseconds: 800),
      onUpdate: (value) {
        setState(() {
          _slideValue = value;
        });
      },
      onStartDrag: () => _isPoping = false,
      onLeftDragEnd: (f) {
        if (_isPoping) return;
        _isPoping = true;
        PopRouteNotification(isSide: true).dispatch(context);
        haptic();
      },
      onLeftMoveHalf: (f) {
        if (_isPoping) return;
        _isPoping = true;
        PopRouteNotification(isSide: true).dispatch(context);
        haptic();
      },
      child: WillPopScope(
        onWillPop: () async {
          _isPoping = true;
          lastPageType = null;
          return true;
        },
        child: widget.builder(context, _slideValue, _isPoping),
      ),
    );
  }
}
