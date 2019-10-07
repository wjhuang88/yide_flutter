import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yide_flutter/screens/list_screen/week_panel/week_panel.dart';

import 'week_panel/date_tools.dart';
import 'task_list/task_list.dart';
import 'task_list/task_list_data.dart';
import 'input_layer.dart';

const _appBarHeight = 70.0;
const _backgroundColor = const Color(0xff0a3f74);
const _brightness = Brightness.dark;
const _pageMargin = 20.0;

const _selectMonthStyle = const TextStyle(color: Colors.white, fontSize: 16);
const _selectYearStyle = const TextStyle(color: Colors.white, fontSize: 14);
const _iconColor = Colors.white;

const _calendarColor = Colors.white;
const _calendarStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 16, fontWeight: FontWeight.w600);
const _calendarBoxHeight = 70.0;
const _calendarBoxWidth = 70.0;
const _calendarBoxRadius = 15.0;
const _calendarBoxGap = 20.0;
const _calendarTextGap = 6.0;

const _mainPanColor = Colors.white;
const _mainPanDefaultMarginTop = 45;
const _mainPanRadius = 45.0;
const _mainPanTitleStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 20, letterSpacing: 5, fontWeight: FontWeight.w600);

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> with SingleTickerProviderStateMixin {

  DateTime selectedDateTime = DateTime.now();
  List<TaskData> taskListData = [];
  double _listOffset = 0.0;
  double _listMovedOffset = 0.0;
  bool _isHeadShow = true;

  AnimationController _controller;
  Animation<double> _animation;

  final _listOffsetEdge = - _calendarBoxHeight - _mainPanDefaultMarginTop + _calendarBoxHeight * 0.2;

  @override
  void initState() {
    super.initState();
    _getTaskListData().then((list){
      setState(() {
        taskListData = list;
      });
    });
    _controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _animation.addListener((){
      setState(() {
        if (_isHeadShow) {
          _listOffset = lerpDouble(_listMovedOffset, 0.0, _animation.value);
        } else {
          _listOffset = lerpDouble(_listMovedOffset, _listOffsetEdge, _animation.value);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(title: _buildDatePan()),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _backgroundColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, 'add');
        },
      ),
      body: Stack(
        children: <Widget>[
          WeekPanel(
            calendarColor: _calendarColor,
            calendarStyle: _calendarStyle,
            calendarBoxHeight: _calendarBoxHeight,
            calendarBoxWidth: _calendarBoxWidth,
            calendarBoxRadius: _calendarBoxRadius,
            calendarBoxGap: _calendarBoxGap,
            calendarTextGap: _calendarTextGap,
            pageMargin: _pageMargin,
            baseTime: selectedDateTime,
            onChange: (date) {
              setState(() {
                selectedDateTime = date;
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: _calendarBoxHeight + _mainPanDefaultMarginTop + _listOffset),
              decoration: BoxDecoration(
                color: _mainPanColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_mainPanRadius),
                  topRight: Radius.circular(_mainPanRadius),
                )
              ),
              child: _buildListPage(),
            ),
          ),
          InputLayer()
        ],
      ),
    );
  }

  Widget _buildAppBar({Widget title}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(_appBarHeight),
      child: AppBar(
        backgroundColor: _backgroundColor,
        brightness: _brightness,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz, color: _iconColor,),
            onPressed: () {},
          )
        ],
        title: title,
        titleSpacing: 0,
      ),
    );
  }

  Widget _buildDatePan() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(width: _pageMargin,),
        Text(getMonthName(selectedDateTime.month), style: _selectMonthStyle),
        SizedBox(width: 8,),
        Text(selectedDateTime.year.toString() + ' 年', style: _selectYearStyle,)
      ],
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
                height: 20,
                child: Image(
                  image: AssetImage('assets/images/horizontal-line.png'),
                ),
              ),
              Text('任务', textAlign: TextAlign.center, style: _mainPanTitleStyle,),
              SizedBox(height: 15,),
            ],
          ),
          onVerticalDragUpdate: (detail) {
            setState(() {
              _listMovedOffset = _listOffset = (_listOffset + detail.delta.dy).clamp(_listOffsetEdge, 0.0);
            });
          },
          onVerticalDragEnd: (detail) {
            var v = detail.velocity.pixelsPerSecond.dy;
            if (v > 100) {
              _isHeadShow = true;
              _controller.forward(from: 0);
              return;
            } else if (v < -100) {
              _isHeadShow = false;
              _controller.forward(from: 0);
              return;
            }
            if (_listOffset > (- _calendarBoxHeight - _mainPanDefaultMarginTop) / 2) {
              _isHeadShow = true;
              _controller.forward(from: 0);
            } else {
              _isHeadShow = false;
              _controller.forward(from: 0);
            }
          },
        ),
        Divider(height: 0,),
        Expanded(
          child: NotificationListener(
            child: TaskList(listData: taskListData,),
            onNotification: (ScrollNotification n) {
              if (_isHeadShow) {
                if (_scrollPixel != null && !n.metrics.outOfRange && n.metrics.pixels - _scrollPixel > 10) {
                  _listMovedOffset = 0.0;
                  _isHeadShow = false;
                  _controller.forward(from: 0);
                }
                _scrollPixel = n.metrics.pixels;
              } else if (n.metrics.pixels < 0) {
                _listMovedOffset = _listOffsetEdge;
                _isHeadShow = true;
                _controller.forward(from: 0);
              }
              return true;
            },
          ),
        )
      ],
    );
  }
}

Future<List<TaskData>> _getTaskListData() async {
  // TODO: 请求远程数据
  return [
    TaskData(
      id: '0',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    TaskData(
      id: '1',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    TaskData(
      id: '2',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    TaskData(
      id: '3',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    TaskData(
      id: '4',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    TaskData(
      id: '5',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    TaskData(
      id: '6',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
  ];
}