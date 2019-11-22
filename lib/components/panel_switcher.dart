import 'package:flutter/material.dart';

typedef PanelItemBuilder = Widget Function(
  BuildContext context,
  double animValue,
);

class PanelSwitcherController {
  _PanelSwitcherState _state;

  Future<void> switchTo(String pageName) async {
    return _state?._to(pageName);
  }

  Future<void> switchBack() async {
    return _state?._reset();
  }

  String get currentPage => _state?._pageName;
}

class PanelSwitcher extends StatefulWidget {
  const PanelSwitcher(
      {Key key,
      this.pageMap,
      this.controller,
      @required this.initPage,
      @required this.backgroundPage,
      this.curve = Curves.easeOutCubic})
      : super(key: key);

  final Map<String, PanelItemBuilder> pageMap;
  final PanelSwitcherController controller;
  final String initPage;
  final String backgroundPage;
  final Curve curve;

  @override
  _PanelSwitcherState createState() => _PanelSwitcherState(controller);
}

class _PanelSwitcherState extends State<PanelSwitcher>
    with SingleTickerProviderStateMixin {
  _PanelSwitcherState(this._controller);

  PanelSwitcherController _controller;
  String _pageName;
  String _keepPage;
  String _lastPage;
  String _movingPage;

  AnimationController _animController;
  Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    if (_controller == null) _controller = PanelSwitcherController();
    _controller._state = this;

    _lastPage = _pageName = widget.initPage;
    _keepPage = widget.backgroundPage;

    _animController = AnimationController(
        value: 0, duration: Duration(milliseconds: 300), vsync: this);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: widget.curve,
    ));
    _anim.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _to(String name) async {
    _movingPage = _lastPage = _pageName;
    _pageName = name;
    return _animController.forward(from: 0.01).then((v) => _movingPage = null);
  }

  Future<void> _reset() async {
    _movingPage = _pageName;
    _pageName = _lastPage;
    return _animController.reverse(from: 0.99).then((v) => _movingPage = null);
  }

  @override
  Widget build(BuildContext context) {
    var children = widget.pageMap
        .map((name, builder) {
          bool show =
              (name == _pageName || name == _keepPage || name == _movingPage);
          return MapEntry(
              name,
              Offstage(
                child: Opacity(
                  opacity: name == _keepPage || name == _pageName
                      ? 1
                      : name == _movingPage ? _anim.value : 0,
                  child: builder(context, _anim.value),
                ),
                offstage: !show,
              ));
        })
        .values
        .toList();
    return Stack(
      children: children,
    );
  }
}
