import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yide/components/sqlite_fetcher.dart';

class InputLayerController {
  InputLayerController({FocusNode focusNode, VoidCallback onCancel, VoidCallback onConfirm})
    : _focusNode = focusNode ?? FocusNode(),
      _onCancel = onCancel,
      _onConfirm = onConfirm;

  _InputLayerState _state;
  BuildContext _context;
  FocusNode _focusNode;
  VoidCallback _onCancel;
  VoidCallback _onConfirm;

  void open() {
    _state?._inputIsShow = true;
    _state?._animController?.forward(from: 0);
    FocusScope.of(_context).requestFocus(_focusNode);
  }

  void close() {
    _focusNode.unfocus();
    _state?._animController?.reverse(from: 1);
    _state?._contentController?.clear();
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
    this.sqliteController,
    this.panelColor = Colors.white,
  }) : super(key: key);

  final Color panelColor;
  final InputLayerController controller;
  final SqliteController sqliteController;

  @override
  _InputLayerState createState() => _InputLayerState(controller, sqliteController);
}

class _InputLayerState extends State<InputLayer> with SingleTickerProviderStateMixin {
  _InputLayerState(this._controller, this._dbController);

  AnimationController _animController;
  Animation<double> _anim;

  InputLayerController _controller;
  SqliteController _dbController;

  double _inputBackgroundOpacity = 0.0;
  bool _inputIsShow = false;
  double _inputHeightFctor = 0.0;
  double _inputPanelOpacity = 0.0;

  TextEditingController _contentController;

  VoidCallback _completeAction;

  @override
  void initState() {
    super.initState();
    if (_controller == null) _controller = InputLayerController();
    _controller._state = this;

    _contentController = TextEditingController();

    // 输入面板动画初始化
    _animController = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutSine
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
        if (_completeAction != null) {
          _completeAction();
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
                      _completeAction = _controller._onCancel;
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
                    controller: _contentController,
                    focusNode: _controller._focusNode,
                    maxLines: null,
                    maxLength: 140,
                    style: TextStyle(fontSize: 16,),
                    decoration: InputDecoration(
                      hintText: '输入内容',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: InputBorder.none,
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
                        onPressed: () {
                          _completeAction = _controller._onCancel;
                          _controller.close();
                        },
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
                        onPressed: () async {
                          await _dbController?.insert(
                            'assets/sql/insert_task.sql',
                            [
                              DateTime.now().millisecondsSinceEpoch, // `create_time`
                              1, // `tag_id`
                              DateTime.now().millisecondsSinceEpoch, // `task_time`
                              _contentController.text, // `content`
                              false, // `is_finished`
                              '', // `remark`
                              0, // `alarm_time`
                            ],
                          );
                          _completeAction = _controller._onConfirm;
                          _controller.close();
                        },
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