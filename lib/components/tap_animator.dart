import 'package:flutter/widgets.dart';

class TapAnimator extends StatefulWidget {
  final Widget Function(double animValue) builder;
  final VoidCallback onTap;
  final HitTestBehavior behavior;

  const TapAnimator(
      {Key key,
      @required this.builder,
      @required this.onTap,
      this.behavior = HitTestBehavior.deferToChild})
      : super(key: key);

  @override
  _TapAnimatorState createState() => _TapAnimatorState();
}

class _TapAnimatorState extends State<TapAnimator>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  double _factor;

  @override
  void initState() {
    super.initState();
    _factor = 0.0;
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 100), value: 0.0);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic));
    _animation.addListener(() {
      setState(() {
        _factor = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (details) {
        _animationController.forward();
      },
      onTapUp: (details) {
        //_animationController.reverse();
        _animationController.fling(velocity: -1.0);
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      onTap: () {
        if (_animationController.value < 0.3) {
          _animationController.fling(velocity: 5.0).then((v) {
            _animationController.fling(velocity: -5.0);
          });
        }
        widget.onTap();
      },
      child: widget.builder(_factor),
    );
  }
}
