import 'dart:math' as Math;
import 'package:flutter/widgets.dart';

class FlippingTile extends StatefulWidget {
  final bool selected;
  final bool _extended;
  final bool _custom;
  final Widget extend;
  final Widget Function(BuildContext, Color color, Color textColor) builder;
  final String title;
  final VoidCallback onTap;

  const FlippingTile({Key key, this.selected = false, this.title, this.onTap})
      : _extended = false,
        extend = null,
        _custom = false,
        builder = null,
        super(key: key);
  const FlippingTile.extended(
      {Key key,
      this.selected = false,
      @required this.extend,
      this.title,
      this.onTap})
      : _extended = true,
        _custom = false,
        builder = null,
        super(key: key);
  const FlippingTile.custom(
      {Key key, this.selected = false, @required this.builder, this.onTap})
      : _extended = true,
        _custom = true,
        title = null,
        extend = null,
        super(key: key);

  @override
  _FlippingTileState createState() => _FlippingTileState();
}

class _FlippingTileState extends State<FlippingTile>
    with SingleTickerProviderStateMixin {
  bool _selected;
  bool _extended;
  bool _custom;

  AnimationController _animationController;
  Animation _fadeAnimation;
  Animation _transAnimation;

  double _fadeValue;
  double _transValue;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
    _extended = widget._extended;
    _custom = widget._custom;

    _transValue = _fadeValue = _selected ? 1.0 : 0.0;

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 150), value: _fadeValue);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic),
    );
    _transAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const ElasticOutCurve(0.7),
          reverseCurve: const ElasticInCurve(0.7)),
    );
    _fadeAnimation.addListener(() {
      setState(() {
        _fadeValue = _fadeAnimation.value;
      });
    });
    _transAnimation.addListener(() {
      setState(() {
        _transValue = _transAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlippingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget == oldWidget) {
      return;
    }
    if (widget._extended != oldWidget._extended) {
      _extended = widget._extended;
    }
    if (widget._custom != oldWidget._custom) {
      _custom = widget._custom;
    }
    if (widget.selected != oldWidget.selected) {
      _selected = widget.selected;
      oldWidget.selected
          ? _animationController.reverse(from: 1.0)
          : _animationController.forward(from: 0.0);
    }
  }

  Color _getComputedColor(double delta) {
    return Color.lerp(const Color(0x12FFFFFF), const Color(0xFFFAB807), delta);
  }

  Color _getComputedTextColor(double delta) {
    return Color.lerp(const Color(0xFFD7CAFF), const Color(0xFFFFFFFF), delta);
  }

  Widget _buildNormalTile() {
    return Container(
      height: 60.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _getComputedColor(_fadeValue),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Text(
        this.widget.title ?? '',
        style:
            TextStyle(color: _getComputedTextColor(_fadeValue), fontSize: 15.0),
      ),
    );
  }

  Widget _buildSelectedTile() {
    return Container(
      height: 60.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _getComputedColor(_fadeValue),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Text(
        this.widget.title ?? '',
        style:
            TextStyle(color: _getComputedTextColor(_fadeValue), fontSize: 15.0),
      ),
    );
  }

  Widget _buildExtendedTile() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      child: Column(
        children: <Widget>[
          Container(
            height: 60.0,
            color: _getComputedColor(_fadeValue),
            alignment: Alignment.center,
            child: Text(
              this.widget.title ?? '',
              style: TextStyle(
                  color: _getComputedTextColor(_fadeValue), fontSize: 15.0),
            ),
          ),
          FractionalTranslation(
            translation: Offset(0.0, _transValue - 1),
            child: Opacity(
              opacity: _fadeValue,
              child: Container(
                color: _getComputedColor(_fadeValue),
                child: widget.extend,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final computedScale = 1.0 - 0.2 * Math.sin(_transValue * Math.pi);
    Widget tile;

    if (_custom) {
      tile = widget.builder(context, _getComputedColor(_fadeValue),
          _getComputedTextColor(_fadeValue));
    } else {
      if (_selected) {
        if (_extended) {
          tile = _buildExtendedTile();
        } else {
          tile = _buildSelectedTile();
        }
      } else {
        tile = _buildNormalTile();
      }
    }
    
    return GestureDetector(
      child: Transform.scale(
        scale: computedScale,
        child: tile,
      ),
      onTap: widget.onTap ?? () {},
    );
  }
}
