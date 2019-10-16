import 'package:flutter/material.dart';

typedef PanelItemBuilder = Widget Function(BuildContext context, double animValue, );

class PanelSwitcherController {
  _PanelSwitcherState _state;

  void switchTo(String pageName, VoidCallback callback) {
    _state?._to(pageName, callback);
  }

  void switchBack(VoidCallback callback) {
    _state?._reset(callback);
  }
}

class PanelSwitcher extends StatefulWidget {
  const PanelSwitcher({Key key, this.pageMap, this.controller, @required this.initPage, @required this.backgroundPage}) : super(key: key);

  final Map<String, PanelItemBuilder> pageMap;
  final PanelSwitcherController controller;
  final String initPage;
  final String backgroundPage;

  @override
  _PanelSwitcherState createState() => _PanelSwitcherState(controller);
}

class _PanelSwitcherState extends State<PanelSwitcher> with SingleTickerProviderStateMixin {
  _PanelSwitcherState(this._controller);

  PanelSwitcherController _controller;
  String _pageName;
  String _keepPage;
  String _lastPage;
  String _movingPage;

  VoidCallback _toCallback;
  VoidCallback _backCallback;

  AnimationController _animController;
  Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    if (_controller == null) _controller = PanelSwitcherController();
    _controller._state = this;

    _lastPage = _pageName = widget.initPage;
    _keepPage = widget.backgroundPage;

    _animController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutSine,
    ));
    _anim.addListener(() {
      setState(() {
        
      });
    });
    _anim.addStatusListener((status) {
      switch(status) {
        case AnimationStatus.forward:
        case AnimationStatus.reverse: {
          
          break;
        }
        case AnimationStatus.completed: {
          _movingPage = null;
          if (_toCallback != null) _toCallback();
          break;
        }
        case AnimationStatus.dismissed: {
          _movingPage = null;
          if (_backCallback != null) _backCallback();
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _to(String name, VoidCallback callback) {
    _movingPage = _lastPage = _pageName;
    _pageName = name;
    _animController.forward(from: 0.01);
    _toCallback = callback;
  }

  void _reset(VoidCallback callback) {
    _movingPage = _pageName;
    _pageName = _lastPage;
    _animController.reverse(from: 0.99);
    _backCallback = callback;
  }

  @override
  Widget build(BuildContext context) {
    var children = widget.pageMap.map((name, builder) {
      return MapEntry(name, Offstage(
        child: builder(context, _anim.value),
        offstage: !(name == _pageName || name == _keepPage || name == _movingPage),
      ));
    }).values.toList();
    return Stack(
      children: children,
    );
  }
}