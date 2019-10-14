import 'dart:ui';

import 'package:flutter/material.dart';

import 'task_list.dart';
import 'task_list_data.dart';

class ListLayerController {
  _ListLayerState _state;

  void updateList(List<TaskData> newData) {
    _state?._flush(newData);
  }

  void animationToCover() {
    _state?._upFrom(_state._listMovedOffset);
  }

  void animationToNormal() {
    _state?._downFrom(_state._listMovedOffset);
  }

  void animationToFold() {
    _state?._foldFrom(_state._listMovedOffset);
  }

  void animationToFoldHigher() {
    _state?._foldHigherFrom(_state._listMovedOffset);
  }

  void dispose() {
    _state = null;
  }
}

class ListLayer extends StatefulWidget {
  const ListLayer({
    Key key,
    this.panelColor = Colors.white,
    this.panelRadius = 45.0,
    this.panelTitleStyle,
    this.topOffsetMax = 300,
    this.topOffsetMin = 0,
    this.taskListData = const <TaskData>[],
    double topOffsetFold,
    double topOffsetFoldHigher,
    this.controller
  }) : topOffsetFold = topOffsetFold ?? topOffsetMax * 2,
      topOffsetFoldHigher = topOffsetFoldHigher ?? topOffsetMax * 2,
      super(key: key);

  final Color panelColor;
  final double panelRadius;
  final TextStyle panelTitleStyle;
  final double topOffsetMax;
  final double topOffsetMin;
  final double topOffsetFold;
  final double topOffsetFoldHigher;
  final List<TaskData> taskListData;
  final ListLayerController controller;

  @override
  _ListLayerState createState() => _ListLayerState(taskListData, controller);
}

enum MoveDirection {
  up, down, fold, foldHigher
}

class _ListLayerState extends State<ListLayer> with SingleTickerProviderStateMixin {
  _ListLayerState(this._taskListData, this._controller);

  ListLayerController _controller;

  List<TaskData> _taskListData;

  double _listMovedOffset;
  double _listOffset;
  MoveDirection _direction = MoveDirection.down;

  AnimationController _animController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _listMovedOffset = _listOffset = widget.topOffsetMax;

    if (_controller == null) _controller = ListLayerController();
    _controller._state = this;

    // 列表拖拽动画初始化
    _animController = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutSine
    ));
    // 列表拖拽动画参数监听
    _animation.addListener((){
      setState(() {
        double offsetTarget;
        switch (_direction) {
          case MoveDirection.up: {
            offsetTarget = widget.topOffsetMin;
            break;
          }
          case MoveDirection.down: {
            offsetTarget = widget.topOffsetMax;
            break;
          }
          case MoveDirection.fold: {
            offsetTarget = widget.topOffsetFold;
            break;
          }
          case MoveDirection.foldHigher: {
            offsetTarget = widget.topOffsetFoldHigher;
          }
        }
        _listOffset = lerpDouble(_listMovedOffset, offsetTarget, _animation.value);
      });
    });

    _animation.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;

      // if status == AnimationStatus.completed
      switch(_direction) {
        case MoveDirection.up: {
          _listMovedOffset = widget.topOffsetMin;
          break;
        }
        case MoveDirection.down: {
          _listMovedOffset = widget.topOffsetMax;
          break;
        }
        case MoveDirection.fold: {
          _listMovedOffset = widget.topOffsetFold;
          break;
        }
        case MoveDirection.foldHigher: {
          _listMovedOffset = widget.topOffsetFoldHigher;
          break;
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

  void _flush(List<TaskData> data) {
    setState(() {
      _taskListData = data;
    });
  }

  void _upFrom(double origin) {
    _listMovedOffset = origin;
    _direction = MoveDirection.up;
    _animController.forward(from: 0);
  }

  void _downFrom(double origin) {
    _listMovedOffset = origin;
    _direction = MoveDirection.down;
    _animController.forward(from: 0);
  }

  void _foldFrom(double origin) {
    _listMovedOffset = origin;
    _direction = MoveDirection.fold;
    _animController.forward(from: 0);
  }

  void _foldHigherFrom(double origin) {
    _listMovedOffset = origin;
    _direction = MoveDirection.foldHigher;
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: _listOffset),
          decoration: BoxDecoration(
            color: widget.panelColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.panelRadius),
              topRight: Radius.circular(widget.panelRadius),
            ),
            boxShadow: <BoxShadow>[
              const BoxShadow(
                offset: const Offset(0.0, -3.0),
                blurRadius: 3.0,
                color: const Color(0x4CBDBDBD),
              ),
            ],
          ),
          child: _buildListPage(),
        ),
      ),
    );
  }

  Widget _buildListPage() {
    double _scrollPixel;
    return Column(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 16,
                child: const Image(
                  image: AssetImage('assets/images/horizontal-line.png'),
                ),
              ),
              Text('任务', textAlign: TextAlign.center, style: widget.panelTitleStyle,),
              const SizedBox(height: 10,),
            ],
          ),
          onVerticalDragUpdate: (detail) {
            if(_direction == MoveDirection.fold || _direction == MoveDirection.foldHigher) return;

            // if _direction != MoveDirection.fold
            setState(() {
              _listMovedOffset = _listOffset = (_listOffset + detail.delta.dy).clamp(widget.topOffsetMin, widget.topOffsetMax);
            });
          },
          onVerticalDragEnd: (detail) {
            if(_direction == MoveDirection.fold || _direction == MoveDirection.foldHigher) return;
            
            // if _direction != MoveDirection.fold
            var v = detail.velocity.pixelsPerSecond.dy;
            if (v > 100) {
              _downFrom(_listMovedOffset);
              return;
            } else if (v < -100) {
              _upFrom(_listMovedOffset);
              return;
            }
            if (_listOffset < (widget.topOffsetMin + widget.topOffsetMax) / 2) {
              _upFrom(_listMovedOffset);
            } else {
              _downFrom(_listMovedOffset);
            }
          },
        ),
        //const Divider(height: 0,),
        Expanded(
          child: NotificationListener(
            child: TaskList(
              listData: _taskListData,
              onItemTap: (data) {
                Navigator.of(context).pushNamed('detail', arguments: data);
              },
            ),
            onNotification: (ScrollNotification n) {
              if (n.metrics.pixels <= n.metrics.minScrollExtent) {
                if (_direction == MoveDirection.up) {
                  _downFrom(widget.topOffsetMin);
                }
              } else if (n.metrics.pixels >= n.metrics.maxScrollExtent) {
                if (_direction == MoveDirection.down) {
                  _upFrom(widget.topOffsetMax);
                }
              } else {
                if (_direction == MoveDirection.down && n.metrics.pixels - (_scrollPixel ?? n.metrics.pixels) > 10) {
                  _upFrom(widget.topOffsetMax);
                }
                _scrollPixel = n.metrics.pixels;
              }
              return true;
            },
          ),
        )
      ],
    );
  }
}