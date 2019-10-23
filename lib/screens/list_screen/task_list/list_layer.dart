import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:yide/components/sqlite_fetcher.dart';
import 'package:yide/models/task_data.dart';

import 'task_list.dart';

final logger = Logger(
  printer: PrettyPrinter(methodCount: 0, lineLength: 80, printTime: true),
);

class ListLayerController {
  _ListLayerState _state;

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

  void updateList(DateTime date) {
    _state?._update(date);
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
    double topOffsetFold,
    double topOffsetFoldHigher,
    this.controller,
    this.initDate,
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
  final ListLayerController controller;
  final DateTime initDate;

  @override
  _ListLayerState createState() => _ListLayerState(controller);
}

enum MoveDirection {
  up, down, fold, foldHigher
}

class _ListLayerState extends State<ListLayer> with SingleTickerProviderStateMixin {
  _ListLayerState(this._controller);

  ListLayerController _controller;

  double _listMovedOffset;
  double _listOffset;
  MoveDirection _direction = MoveDirection.down;

  AnimationController _animController;
  Animation<double> _animation;

  int _queryDateBegin;
  int _queryDateEnd;

  SqliteController _sqliteController;

  @override
  void initState() {
    super.initState();
    logger.d('Init list offset.');
    _listMovedOffset = _listOffset = widget.topOffsetMax;

    _sqliteController = SqliteController();

    if (_controller == null) _controller = ListLayerController();
    logger.d('Init ListLayerController instance.');
    _controller._state = this;

    logger.d('Init list drag animation.');
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
    _update(widget.initDate);
  }

  @override
  void dispose() {
    logger.d('ListLayer instance disposing.');
    _animController.dispose();
    _controller.dispose();
    super.dispose();
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

  void _update(DateTime date) {
    logger.d('Updating DB query datetime arguments, date: $date.');
    var begin = DateTime(date.year, date.month, date.day);
    var end = begin.add(Duration(days: 1));
    setState(() {
      _queryDateBegin = begin.millisecondsSinceEpoch;
      _queryDateEnd = end.millisecondsSinceEpoch;
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Building ListLayer.');

    final panelStyle = BoxDecoration(
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
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        bottom: false,
        child: Hero(
          tag: 'panel_background',
          transitionOnUserGestures: true,
          flightShuttleBuilder: (_, __, ___, ____, _____) {
            return Container(
              margin: EdgeInsets.only(top: _listOffset),
              decoration: panelStyle,
            );
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: _listOffset),
            decoration: panelStyle,
            child: _buildListPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildListPage() {
    logger.d('Building main list page.');
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
            _listMovedOffset = (_listOffset + detail.delta.dy).clamp(widget.topOffsetMin, widget.topOffsetMax);
            if (_listOffset != _listMovedOffset) {
              setState(() {
                _listOffset = _listMovedOffset;
              });
            }
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
            child: SqliteFetcher(
              key: ValueKey('main_list_sql_fetcher'),
              querySqlPath: 'assets/sql/query_task_by_date.sql',
              queryArguments: [_queryDateBegin, _queryDateEnd],
              controller: _sqliteController,
              builder: (context, taskList, controller, _) {
                logger.d('Building TaskList from DB.');
                return TaskList(
                  data: taskList == null ? [] : taskList.map((list) {
                    var taskTime = list['task_time'];
                    var alarmTime = list['alarm_time'];
                    var id = list['id'].toString();
                    var data = TaskData(
                      id: id, 
                      taskTime: taskTime != null && taskTime != 0 ? DateTime.fromMillisecondsSinceEpoch(taskTime) : null,
                      tagId: list['tag_id'].toString(),
                      isFinished: list['is_finished'] == 1,
                      content: list['content'],
                      remark: list['remark'],
                      alarmTime: alarmTime != null && alarmTime != 0 ? DateTime.fromMillisecondsSinceEpoch(alarmTime) : null,
                    );
                    var tag = tagMap[list['tag_id'].toString()];
                    return TaskPack(data, tag);
                  }).toList(),
                  onItemTap: (data) async {
                    data.sqliteController = controller;
                    await Navigator.of(context).pushNamed('detail', arguments: data);
                    logger.d('Back from detail screen.');
                  },
                );
              },
              loading: Center(
                child: SpinKitCircle(
                  color: Colors.blue,
                  size: 70.0,
                ),
              ),
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