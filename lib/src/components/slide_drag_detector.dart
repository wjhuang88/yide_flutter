import 'package:flutter/widgets.dart';

class SlideDragDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onStartDrag;
  final ValueChanged<double> onUpdate;
  final ValueChanged<double> onForward;
  final ValueChanged<double> onReverse;
  final ValueChanged<double> onForwardComplete;
  final ValueChanged<double> onReverseComplete;
  final ValueChanged<double> onForwardHalf;
  final ValueChanged<double> onReverseHalf;
  final Duration transitionDuration;
  final Curve curve;
  final Curve reversCurve;
  final double startBarrier;
  final double endBarrier;
  final SlideDragController controller;

  const SlideDragDetector({
    Key key,
    @required this.child,
    this.onStartDrag,
    this.onUpdate,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.onForward,
    this.onReverse,
    this.curve = const ElasticOutCurve(0.9),
    this.reversCurve = const ElasticInCurve(0.9),
    this.startBarrier = 0.0,
    this.endBarrier = 1.0,
    this.onForwardComplete,
    this.onForwardHalf,
    this.onReverseComplete,
    this.onReverseHalf,
    this.controller,
  }) : super(key: key);

  @override
  _SlideDragDetectorState createState() => _SlideDragDetectorState();
}

class SlideDragController {
  _SlideDragDetectorState _state;

  Future<void> forward() async {
    return _state?._forward();
  }

  Future<void> reverse() async {
    return _state?._reverse();
  }

  void setOn() {
    _state?._active = true;
  }

  void setOff() {
    _state?._active = false;
  }
}

class _SlideDragDetectorState extends State<SlideDragDetector>
    with SingleTickerProviderStateMixin {
  double _screenWidth = 0.0;
  double _animDragDelta = 0.0;
  bool _isDragging = false;

  double _fraction = 0.0;
  bool _flip = false;

  AnimationController _animationController;
  Animation _animation;

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  double get _centerPoint => (widget.startBarrier + widget.endBarrier) / 2;

  SlideDragController _controller;

  bool _activeValue = true;
  bool get _active => _activeValue;
  set _active(value) {
    setState(() {
      _activeValue = value;
    });
  }

  bool _isForwardOverHalf = false;
  bool _isReverseOverHalf = false;

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0, duration: widget.transitionDuration, vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: widget.curve,
      reverseCurve: widget.reversCurve,
      parent: _animationController,
    ));
    _animation.addListener(() {
      _fraction =
          _startFraction + (_endFraction - _startFraction) * _animation.value;
      (widget.onUpdate ?? (frac) {})(_fraction);
    });

    _controller = widget.controller ?? SlideDragController();
    _controller._state = this;

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _forward() async {
    _startFraction = _fraction;
    _endFraction = widget.endBarrier;
    _flip = true;
    await _animationController.forward(from: 0.0);
  }

  Future<void> _reverse() async {
    _startFraction = widget.startBarrier;
    _endFraction = _fraction;
    _flip = false;
    await _animationController.reverse(from: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return _active
        ? GestureDetector(
            child: widget.child,
            onHorizontalDragStart: (detail) {
              final x = detail.globalPosition.dx;
              if (x > 0) {
                _isDragging = true;
                _animDragDelta = x;
                _screenWidth = MediaQuery.of(context).size.width;
                _isForwardOverHalf = false;
                _isReverseOverHalf = false;
                _animationController.stop(canceled: false);
                if (widget.onStartDrag != null) {
                  widget.onStartDrag();
                }
              }
            },
            onHorizontalDragEnd: (detail) async {
              if (!_isDragging) {
                return;
              }
              _isDragging = false;
              if (detail.primaryVelocity > 700.0) {
                (widget.onForward ?? (frac) {})(_fraction);
                await _forward();
                (widget.onForwardComplete ?? (frac) {})(_fraction);
              } else if (detail.primaryVelocity < -700) {
                (widget.onReverse ?? (frac) {})(_fraction);
                await _reverse();
                (widget.onReverseComplete ?? (frac) {})(_fraction);
              } else if (_fraction >= _centerPoint) {
                (widget.onForward ?? (frac) {})(_fraction);
                await _forward();
                (widget.onForwardComplete ?? (frac) {})(_fraction);
              } else {
                (widget.onReverse ?? (frac) {})(_fraction);
                await _reverse();
                (widget.onReverseComplete ?? (frac) {})(_fraction);
              }
            },
            onHorizontalDragCancel: () async {
              if (!_isDragging) {
                return;
              }
              _isDragging = false;
              if (_fraction >= _centerPoint) {
                (widget.onForward ?? (frac) {})(_fraction);
                await _forward();
                (widget.onForwardComplete ?? (frac) {})(_fraction);
              } else {
                (widget.onReverse ?? (frac) {})(_fraction);
                await _reverse();
                (widget.onReverseComplete ?? (frac) {})(_fraction);
              }
            },
            onHorizontalDragUpdate: (detail) {
              final start = widget.startBarrier;
              final end = widget.endBarrier;
              if (_isDragging) {
                var frac =
                    (detail.globalPosition.dx - _animDragDelta) / _screenWidth;
                if ((_fraction <= start && frac < 0.0) ||
                    (_fraction >= end && frac > 0.0)) {
                  return;
                }
                if (_fraction >= end) {
                  _flip = true;
                } else if (_fraction <= start) {
                  _flip = false;
                }
                if (_flip) {
                  frac = end + frac;
                }
                _fraction = frac;
                (widget.onUpdate ?? (frac) {})(_fraction);
                if (!_flip &&
                    !_isForwardOverHalf &&
                    _fraction >= _centerPoint) {
                  (widget.onForwardHalf ?? (frac) {})(_fraction);
                  _isForwardOverHalf = true;
                }
                if (_flip && !_isReverseOverHalf && _fraction <= _centerPoint) {
                  (widget.onReverseHalf ?? (frac) {})(_fraction);
                  _isReverseOverHalf = true;
                }
              }
            },
          )
        : widget.child;
  }
}
