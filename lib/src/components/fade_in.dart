import 'package:flutter/widgets.dart';

class FadeInController {
  late _FadeInState _state;
  void fadeIn({double from = 0.0}) {
    _state.fadeIn(from: from);
  }
}

class FadeIn extends StatefulWidget {
  final Curve curve;
  final Duration duration;
  final Widget child;
  final FadeInController controller;
  final bool autoFadeIn;

  const FadeIn({
    required Key key,
    this.curve = Curves.easeOutCubic,
    required this.duration,
    required this.child,
    required this.controller,
    this.autoFadeIn = false,
  }) : super(key: key);

  @override
  _FadeInState createState() => _FadeInState(controller);
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  _FadeInState(this._controller);
  late AnimationController _animationController;
  late Animation<double> _animation;

  FadeInController _controller;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: widget.duration, value: 0.0);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));
    if (widget.autoFadeIn) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.value = 1.0;
    }

    _controller._state = this;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void fadeIn({double from = 0.0}) {
    _animationController.forward(from: from);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
