import 'dart:math' as Math;
import 'package:flutter/widgets.dart';

class TapAnimator extends StatefulWidget {
  final Widget Function(double animValue) builder;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onLongPress;
  final HitTestBehavior behavior;
  final Duration duration;

  const TapAnimator(
      {Key key,
      @required this.builder,
      this.onTap,
      this.onComplete,
      this.onLongPress,
      this.duration = const Duration(milliseconds: 100),
      this.behavior = HitTestBehavior.deferToChild})
      : assert(onTap != null || onComplete != null),
        super(key: key);

  @override
  _TapAnimatorState createState() => _TapAnimatorState();
}

class _TapAnimatorState extends State<TapAnimator>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  AnimationController _tapAnimationController;
  Animation _animation;
  Animation _tapAnimation;

  double _factor;

  @override
  void initState() {
    super.initState();
    _factor = 0.0;
    _animationController =
        AnimationController(vsync: this, duration: widget.duration, value: 0.0);
    _tapAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
        value: 0.0);
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic),
    );
    _tapAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _tapAnimationController,
        curve: HalfSineCurve(),
      ),
    );
    _tapAnimation.addListener(() {
      setState(() {
        _factor = _tapAnimation.value;
      });
    });
    _animation.addListener(() {
      setState(() {
        _factor = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tapAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (details) async {
        await _animationController.forward(from: _factor);
      },
      onTapCancel: () async {
        await _animationController.reverse(from: _factor);
      },
      onTap: () async {
        if (widget.onTap != null) {
          widget.onTap();
        }
        await _tapAnimationController.forward(from: _factor);
        await _tapAnimationController.reverse(from: _factor);
        if (widget.onComplete != null) {
          widget.onComplete();
        }
      },
      onLongPress: widget.onLongPress,
      child: widget.builder(_factor),
    );
  }
}

class HalfSineCurve extends Curve {
  @override
  double transformInternal(double t) {
    final result = Math.sin(t * Math.pi / 2);
    return result;
  }
}
