import 'package:flutter/material.dart';

typedef PanelItemBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

class PanelSwitcherController {
  _PanelSwitcherState _state;

  Future<void> switchTo(String pageName) async {
    return _state?._to(pageName);
  }

  Future<void> switchBack() async {
    return _state?._reset();
  }

  String get currentPage => _state?._pageInStage;
}

class PanelSwitcher extends StatefulWidget {
  const PanelSwitcher({
    Key key,
    this.pageMap,
    this.controller,
    @required this.initPage,
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.duration = const Duration(milliseconds: 300),
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final Map<String, PanelItemBuilder> pageMap;
  final PanelSwitcherController controller;
  final String initPage;
  final Curve curve;
  final Curve reverseCurve;
  final Duration duration;
  final Color backgroundColor;

  @override
  _PanelSwitcherState createState() => _PanelSwitcherState(controller);
}

class _PanelSwitcherState extends State<PanelSwitcher>
    with SingleTickerProviderStateMixin {
  _PanelSwitcherState(this._controller);

  PanelSwitcherController _controller;

  AnimationController _animController;
  Animation<double> _anim;

  String _pageInStage;
  String _pageInBackground;

  List<PanelItemBuilder> _stages = List(2);
  int _topStageIndex = 1;
  PanelItemBuilder get _topStage => _stages[_topStageIndex];
  set _topStage(PanelItemBuilder value) => _stages[_topStageIndex] = value;
  PanelItemBuilder get _backgroundStage => _stages[1 - _topStageIndex];

  @override
  void initState() {
    super.initState();
    if (_controller == null) _controller = PanelSwitcherController();
    _controller._state = this;

    _pageInStage = widget.initPage;
    _topStage = widget.pageMap[_pageInStage];

    _animController =
        AnimationController(value: 0, duration: widget.duration, vsync: this);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
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

  void _flipStage() {
    _topStageIndex = 1 - _topStageIndex;
    final tempPage = _pageInBackground;
    _pageInBackground = _pageInStage;
    _pageInStage = tempPage;
  }

  Future<void> _to(String name) async {
    _flipStage();
    final builder = widget.pageMap[name];
    if (builder != null) {
      _topStage = builder;
      _pageInStage = name;
      return _animController.forward(from: 0);
    }
    throw FlutterError('Can\'t find a panel named: $name.');
  }

  Future<void> _reset() async {
    if (_backgroundStage == null) {
      return TickerFuture.complete();
    }
    _flipStage();
    return _animController.reverse(from: 1);
  }

  @override
  Widget build(BuildContext context) {
    final hideBackground = _anim.value == 1.0;
    return Container(
      color: widget.backgroundColor,
      child: _backgroundStage == null || hideBackground
          ? _topStage(context, Tween(begin: 1.0, end: 1.0).animate(_anim))
          : Stack(
              children: <Widget>[
                _backgroundStage(context, ReverseAnimation(_anim)),
                _topStage(context, _anim),
              ],
            ),
    );
  }
}
