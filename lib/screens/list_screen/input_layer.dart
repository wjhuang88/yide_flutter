import 'dart:ui';

import 'package:flutter/material.dart';

class InputLayerController {
  InputLayerController({FocusNode focusNode}) : _focusNode = focusNode ?? FocusNode();

  _InputLayerState _state;
  BuildContext _context;
  FocusNode _focusNode;
  void Function() _onCancel;
  
  void onCancel(void Function() cancelCallback) {
    _onCancel = cancelCallback;
  }

  void open() {
    _state._inputIsShow = true;
    _state._animController.forward(from: 0);
    FocusScope.of(_context).requestFocus(_focusNode);
  }

  void close() {
    _focusNode.unfocus();
    _state._animController.reverse(from: 1);
  }

  void dispose() {
    _state = null;
    _context = null;
    _focusNode = null;
    _onCancel = null;
  }
}

class InputLayer extends StatefulWidget {
  const InputLayer({
    Key key,
    this.controller,
    this.panelColor = Colors.white,
  }) : super(key: key);

  final Color panelColor;
  final InputLayerController controller;

  @override
  _InputLayerState createState() => _InputLayerState(controller);
}

class _InputLayerState extends State<InputLayer> with SingleTickerProviderStateMixin {
  _InputLayerState(this._controller);

  AnimationController _animController;
  Animation<double> _anim;

  InputLayerController _controller;

  double _inputBackgroundOpacity = 0.0;
  bool _inputIsShow = false;
  double _inputHeightFctor = 0.0;
  double _inputPanelOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    if (_controller == null) _controller = InputLayerController();
    _controller._state = this;

    // 输入面板动画初始化
    _animController = AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut
    ));
    // 输入面板动画参数监听
    _anim.addListener((){
      setState(() {
        var delta = _anim.value;
        _inputBackgroundOpacity = lerpDouble(0.0, 0.5, delta);
        _inputPanelOpacity = delta;
        _inputHeightFctor = delta;
      });
    });

    _anim.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _inputIsShow = false;
        });
        if (_controller._onCancel != null) {
          _controller._onCancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller._context = context;
    return Offstage(
      offstage: !_inputIsShow,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.black.withOpacity(_inputBackgroundOpacity),
          child: Opacity(
            opacity: _inputPanelOpacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _controller.close();
                    },
                    child: Container(),
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, 130 * (1.0 - _inputHeightFctor), 0.0),
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.panelColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)
                    ),
                  ),
                  child: TextField(
                    focusNode: _controller._focusNode,
                    maxLines: null,
                    maxLength: 140,
                    style: TextStyle(fontSize: 16,),
                    decoration: InputDecoration(
                      hintText: '输入内容',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: InputBorder.none,
                      //focusedBorder: OutlineInputBorder()
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  color: widget.panelColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton.icon(
                        icon: Icon(Icons.clear),
                        label: Text('取消'),
                        onPressed: () {},
                      ),
                      _buildVertDivider(),
                      FlatButton.icon(
                        icon: Icon(Icons.more_horiz),
                        label: Text('更多'),
                        onPressed: () {},
                      ),
                      _buildVertDivider(),
                      FlatButton.icon(
                        icon: Icon(Icons.check),
                        label: Text('确定'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildVertDivider() {
  return Center(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey)
        )
      ),
    ),
  );
}