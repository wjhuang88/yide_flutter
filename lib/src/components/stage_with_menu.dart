import 'dart:math' as Math;

import 'package:flutter/widgets.dart';
import 'package:yide/src/globle_variable.dart';
import 'package:yide/src/config.dart' as Config;

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

  bool get isMenuOpen => _state?._animValue != 0.0;
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
    final _menuPart = SafeArea(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..scale(
              0.5 + menuTransformValue * 0.5, 0.9 + menuTransformValue * 0.1)
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
    );
    return Stack(
      children: <Widget>[
        Offstage(
          offstage: menuTransformValue == 0.0,
          child: _menuPart,
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