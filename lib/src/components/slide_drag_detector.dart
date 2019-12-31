import 'package:flutter/widgets.dart';

class SlideDragDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onStartDrag;
  final ValueChanged<double> onUpdate;
  final ValueChanged<double> onLeftOutBoundUpdate;
  final ValueChanged<double> onRightDragEnd;
  final ValueChanged<double> onLeftDragEnd;
  final ValueChanged<double> onLeftSecondDragEnd;
  final ValueChanged<double> onLeftSecondDragBackEnd;
  final ValueChanged<double> onRightMoveComplete;
  final ValueChanged<double> onLeftMoveComplete;
  final ValueChanged<double> onLeftSecondMoveComplete;
  final ValueChanged<double> onLeftSecondMoveBackComplete;
  final ValueChanged<double> onRightMoveHalf;
  final ValueChanged<double> onLeftMoveHalf;
  final ValueChanged<double> onLeftSecondMoveHalf;
  final ValueChanged<double> onLeftSecondMoveBackHalf;
  final Duration transitionDuration;
  final Curve rightMoveCurve;
  final Curve leftMoveCurve;
  final double leftBarrier;
  final double rightBarrier;
  final double leftSecondBarrier;
  final SlideDragController controller;
  final bool isActive;
  final double initValue;

  const SlideDragDetector({
    Key key,
    @required this.child,
    this.onStartDrag,
    this.onUpdate,
    this.onLeftOutBoundUpdate,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.onRightDragEnd,
    this.onLeftDragEnd,
    this.rightMoveCurve = const ElasticOutCurve(0.9),
    this.leftMoveCurve = const ElasticInCurve(0.9),
    this.leftBarrier = 0.0,
    this.rightBarrier = 1.0,
    this.leftSecondBarrier = -1.0,
    this.onRightMoveComplete,
    this.onRightMoveHalf,
    this.onLeftMoveComplete,
    this.onLeftMoveHalf,
    this.controller,
    this.onLeftSecondDragEnd,
    this.onLeftSecondDragBackEnd,
    this.onLeftSecondMoveComplete,
    this.onLeftSecondMoveBackComplete,
    this.onLeftSecondMoveHalf,
    this.onLeftSecondMoveBackHalf,
    this.isActive,
    this.initValue,
  }) : super(key: key);

  @override
  _SlideDragDetectorState createState() => _SlideDragDetectorState();
}

class SlideDragController {
  _SlideDragDetectorState _state;

  double get value => _state?._fraction;

  Future<void> moveRight() async {
    return _state?._forward();
  }

  Future<void> moveLeft() async {
    return _state?._reverse();
  }

  Future<void> moveLeftOutbound() async {
    return _state?._leftOutBoundForward();
  }

  Future<void> moveLeftOutboundBack() async {
    return _state?._leftOutBoundReverse();
  }

  void moveStop() {
    return _state?._stop();
  }

  void reset() {
    _state?._reset();
  }

  void setOn() {
    _state?._active = true;
  }

  void setOff() {
    _state?._active = false;
  }

  bool get isActive => _state?._active ?? false;
}

class _SlideDragDetectorState extends State<SlideDragDetector>
    with SingleTickerProviderStateMixin {
  double _screenWidth = 0.0;
  double _animDragDelta = 0.0;
  bool _isDragging = false;

  double _fraction;
  bool _flip = false;
  bool _leftOutBoundFlip = false;

  AnimationController _animationController;
  Animation _animation;

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  double get _centerPoint => (widget.leftBarrier + widget.rightBarrier) / 2;
  double get _leftSecondCenter =>
      (widget.leftBarrier + widget.leftSecondBarrier) / 2;

  SlideDragController _controller;

  bool _activeValue;
  bool get _active => _activeValue;
  set _active(value) {
    setState(() {
      _activeValue = value;
    });
  }

  bool _normalRunning = false;
  bool _outBoundRunning = false;

  bool _isLeftOutBound = false;

  bool _isForwardOverHalf = false;
  bool _isReverseOverHalf = false;

  bool _isLeftOutBoundForwardOverHalf = false;
  bool _isLeftOutBoundReverseOverHalf = false;

  double _lastUpdateValue;
  double _lastLeftOutBoundUpdateValue;

  @override
  void initState() {
    _fraction = widget.initValue ?? 0.0;
    _activeValue = widget.isActive ?? true;
    _animationController = AnimationController(
        value: 0.0, duration: widget.transitionDuration, vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: widget.rightMoveCurve,
      reverseCurve: widget.leftMoveCurve,
      parent: _animationController,
    ));
    _animation.addListener(() {
      _fraction =
          _startFraction + (_endFraction - _startFraction) * _animation.value;
      if (_outBoundRunning) {
        _handleLeftOutBoundAnimation(_fraction);
        _handleUpdateAnimation(widget.leftBarrier);
      }
      if (_normalRunning) {
        _handleUpdateAnimation(_fraction);
        _handleLeftOutBoundAnimation(widget.leftBarrier);
      }
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

  void _stop() {
    if (!this.mounted) {
      return;
    }
    _animationController.stop();
  }

  Future<void> _forward() async {
    if (!this.mounted) {
      return;
    }
    _startFraction = _fraction;
    _endFraction = widget.rightBarrier;
    _flip = true;
    _isLeftOutBound = false;
    _normalRunning = true;
    final future = _animationController.forward(from: 0.0);
    await future;
    _normalRunning = false;
    return future;
  }

  Future<void> _reverse() async {
    if (!this.mounted) {
      return;
    }
    _startFraction = widget.leftBarrier;
    _endFraction = _fraction;
    _flip = false;
    _isLeftOutBound = false;
    _normalRunning = true;
    final future = _animationController.reverse(from: 1.0);
    await future;
    _normalRunning = false;
    return future;
  }

  Future<void> _leftOutBoundForward() async {
    if (!this.mounted) {
      return;
    }
    _startFraction = _fraction;
    _endFraction = widget.leftBarrier;
    _leftOutBoundFlip = false;
    _isLeftOutBound = true;
    _outBoundRunning = true;
    final future = _animationController.forward(from: 0.0);
    await future;
    _outBoundRunning = false;
    return future;
  }

  Future<void> _leftOutBoundReverse() async {
    if (!this.mounted) {
      return;
    }
    _startFraction = widget.leftSecondBarrier;
    _endFraction = _fraction;
    _leftOutBoundFlip = true;
    _isLeftOutBound = true;
    _outBoundRunning = true;
    final future = _animationController.reverse(from: 1.0);
    await future;
    _outBoundRunning = false;
    return future;
  }

  void _reset() {
    if (!this.mounted) {
      return;
    }
    setState(() {
      _fraction = widget.leftBarrier;
      _normalRunning = false;
      _outBoundRunning = false;
      _isLeftOutBound = false;
      _isForwardOverHalf = false;
      _isReverseOverHalf = false;
      _isLeftOutBoundForwardOverHalf = false;
      _isLeftOutBoundReverseOverHalf = false;
      _lastUpdateValue = null;
      _lastLeftOutBoundUpdateValue = null;
    });
  }

  void _invokeMethod(ValueChanged<double> method, double argument) {
    if (method != null) {
      method(argument);
    }
  }

  Future<void> _dragEndAction(double velocity, double offet) async {
    if (velocity > 700.0) {
      // 右划速度大于阈值触发处理器运行
      _invokeMethod(widget.onRightDragEnd, offet);
      await _forward();
      _invokeMethod(widget.onRightMoveComplete, offet);
    } else if (velocity < -700) {
      // 左划速度大于阈值触发处理器运行
      _invokeMethod(widget.onLeftDragEnd, offet);
      await _reverse();
      _invokeMethod(widget.onLeftMoveComplete, offet);
    } else if (offet >= _centerPoint) {
      // 终止点超过中点
      _invokeMethod(widget.onRightDragEnd, offet);
      await _forward();
      _invokeMethod(widget.onRightMoveComplete, offet);
    } else {
      // 终止点不超过中点
      _invokeMethod(widget.onLeftDragEnd, offet);
      await _reverse();
      _invokeMethod(widget.onLeftMoveComplete, offet);
    }
  }

  Future<void> _dragCancelAction(double offet) async {
    if (offet >= _centerPoint) {
      // 终止点超过中点
      await _forward();
    } else {
      // 终止点不超过中点
      await _reverse();
    }
  }

  Future<void> _dragEndLeftOutBoundAction(double velocity, double offet) async {
    if (velocity > 700.0) {
      // 右划速度大于阈值触发处理器运行
      _invokeMethod(widget.onLeftSecondDragBackEnd, offet);
      await _leftOutBoundForward();
      _invokeMethod(widget.onLeftSecondMoveBackComplete, offet);
    } else if (velocity < -700) {
      // 左划速度大于阈值触发处理器运行
      _invokeMethod(widget.onLeftSecondDragEnd, offet);
      await _leftOutBoundReverse();
      _invokeMethod(widget.onLeftSecondMoveComplete, offet);
    } else if (offet >= _leftSecondCenter) {
      // 终止点超过中点
      _invokeMethod(widget.onLeftSecondDragBackEnd, offet);
      await _leftOutBoundForward();
      _invokeMethod(widget.onLeftSecondMoveBackComplete, offet);
    } else {
      // 终止点不超过中点
      _invokeMethod(widget.onLeftSecondDragEnd, offet);
      await _leftOutBoundReverse();
      _invokeMethod(widget.onLeftSecondMoveComplete, offet);
    }
  }

  Future<void> _dragCancelLeftOutBoundAction(double offet) async {
    if (offet >= _leftSecondCenter) {
      // 终止点超过中点
      await _leftOutBoundForward();
    } else {
      // 终止点不超过中点
      await _leftOutBoundReverse();
    }
  }

  void _handleUpdate(value) {
    final condition1 = widget.leftBarrier < widget.rightBarrier &&
        value >= widget.leftBarrier &&
        value <= widget.rightBarrier;
    final condition2 = widget.leftBarrier > widget.rightBarrier &&
        value <= widget.leftBarrier &&
        value >= widget.rightBarrier;
    if (condition1 || condition2) {
      _handleUpdateAnimation(value);
    }
  }

  void _handleUpdateAnimation(value) {
    if (widget.onUpdate != null && _lastUpdateValue != value) {
      _lastUpdateValue = value;
      widget.onUpdate(value);
    }
  }

  void _handleLeftOutBoundUpdate(value) {
    final condition1 = widget.leftSecondBarrier < widget.leftBarrier &&
        value >= widget.leftSecondBarrier &&
        value <= widget.leftBarrier;
    final condition2 = widget.leftSecondBarrier > widget.leftBarrier &&
        value <= widget.leftSecondBarrier &&
        value >= widget.leftBarrier;
    if (condition1 || condition2) {
      _handleLeftOutBoundAnimation(value);
    }
  }

  void _handleLeftOutBoundAnimation(value) {
    if (widget.onLeftOutBoundUpdate != null &&
        _lastLeftOutBoundUpdateValue != value) {
      _lastLeftOutBoundUpdateValue = value;
      widget.onLeftOutBoundUpdate(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _active
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: widget.child,
            onHorizontalDragStart: (detail) {
              final x = detail.globalPosition.dx;
              if (x > 0) {
                _isDragging = true;
                _animDragDelta = x;
                _screenWidth = MediaQuery.of(context).size.width;
                _isForwardOverHalf = false;
                _isReverseOverHalf = false;
                _isLeftOutBoundForwardOverHalf = false;
                _isLeftOutBoundReverseOverHalf = false;
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
              if (_isLeftOutBound) {
                await _dragEndLeftOutBoundAction(
                    detail.primaryVelocity, _fraction);
              } else {
                await _dragEndAction(detail.primaryVelocity, _fraction);
              }
            },
            onHorizontalDragCancel: () async {
              if (!_isDragging) {
                return;
              }
              _isDragging = false;
              if (_isLeftOutBound) {
                await _dragCancelLeftOutBoundAction(_fraction);
              } else {
                await _dragCancelAction(_fraction);
              }
            },
            onHorizontalDragUpdate: (detail) {
              if (_isDragging) {
                final left = widget.leftBarrier;
                final right = widget.rightBarrier;
                final secondLeft = widget.leftSecondBarrier;
                var frac =
                    (detail.globalPosition.dx - _animDragDelta) / _screenWidth;
                if (left == secondLeft && _fraction <= left && frac < 0.0) {
                  _fraction = left;
                  _isLeftOutBound = false;
                  _handleUpdate(_fraction);
                  return;
                }
                if (_fraction >= right && frac > 0.0) {
                  _fraction = right;
                  _isLeftOutBound = false;
                  _handleUpdate(_fraction);
                  return;
                }
                if (_fraction <= secondLeft && frac < 0.0) {
                  _fraction = secondLeft;
                  _isLeftOutBound = true;
                  _handleLeftOutBoundUpdate(_fraction);
                  return;
                }
                if (_fraction <= left) {
                  _isLeftOutBound = true;
                } else {
                  _isLeftOutBound = false;
                }
                if (_isLeftOutBound) {
                  _handleUpdate(left);
                  if (_fraction <= secondLeft) {
                    _leftOutBoundFlip = true;
                  } else if (_fraction >= left) {
                    _leftOutBoundFlip = false;
                  }
                  if (_leftOutBoundFlip) {
                    frac = frac + secondLeft;
                  }
                  _fraction = frac;
                  _handleLeftOutBoundUpdate(_fraction);
                  if (!_leftOutBoundFlip &&
                      !_isLeftOutBoundForwardOverHalf &&
                      _fraction <= _leftSecondCenter) {
                    _invokeMethod(widget.onLeftSecondMoveHalf, _fraction);
                    _isLeftOutBoundForwardOverHalf = true;
                  }
                  if (_leftOutBoundFlip &&
                      !_isLeftOutBoundReverseOverHalf &&
                      _fraction >= _leftSecondCenter) {
                    _invokeMethod(widget.onLeftSecondMoveBackHalf, _fraction);
                    _isLeftOutBoundReverseOverHalf = true;
                  }
                } else {
                  if (_fraction >= right) {
                    _flip = true;
                  } else if (_fraction <= left) {
                    _flip = false;
                  }
                  if (_flip) {
                    frac = right + frac;
                  }
                  _fraction = frac;
                  _handleUpdate(_fraction);
                  if (!_flip &&
                      !_isForwardOverHalf &&
                      _fraction >= _centerPoint) {
                    _invokeMethod(widget.onRightMoveHalf, _fraction);
                    _isForwardOverHalf = true;
                  }
                  if (_flip &&
                      !_isReverseOverHalf &&
                      _fraction <= _centerPoint) {
                    _invokeMethod(widget.onLeftMoveHalf, _fraction);
                    _isReverseOverHalf = true;
                  }
                }
              }
            },
          )
        : widget.child;
  }
}
