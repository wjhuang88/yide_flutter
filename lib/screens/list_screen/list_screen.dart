import 'dart:ui';

import 'package:flutter/material.dart';

import 'datetime_panel/week_panel.dart';
import 'datetime_panel/calendar_panel.dart';
import 'datetime_panel/date_tools.dart';
import 'task_list/task_list_data.dart';
import 'task_list/list_layer.dart';
import 'input_layer.dart';

const _appTitleHeight = 45.0;
const _backgroundColor = const Color(0xff0a3f74);
const _pageMargin = 20.0;

const _selectMonthStyle = const TextStyle(color: Colors.white, fontSize: 16);
const _selectYearStyle = const TextStyle(color: Colors.white, fontSize: 14);
const _iconColor = Colors.white;

const _calendarColor = Colors.white;
const _calendarStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 14, fontWeight: FontWeight.w600);
const _calendarBoxHeight = 60.0;
const _calendarBoxWidth = 60.0;
const _calendarBoxRadius = 15.0;
const _calendarBoxGap = 16.0;
const _calendarTextGap = 5.0;

const _mainPanColor = Colors.white;
const _mainPanDefaultMarginTop = 50.0;
const _mainPanRadius = 45.0;
const _mainPanTitleStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 16, letterSpacing: 5, fontWeight: FontWeight.w600);
const _mainPanFoldOffset = 400.0;
const _mainPanFoldHigherOffset = 350.0;

const _panelOffsetBase = 300.0;

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> with SingleTickerProviderStateMixin {

  DateTime selectedDateTime = DateTime.now();

  bool _inputIsShow = false;
  bool _showMonthDetail = false;
  bool _showMonthSimple = true;

  InputLayerController _inputLayerController;

  ListLayerController _listLayerController = ListLayerController();

  CalendarController _calendarController;

  WeekController _weekController = WeekController();

  AnimationController _panelOpacityController;
  Animation<double> _panelOpacityAnim;
  double _panelOpacity = 0.0;
  double _panelOffset = 0.0;

  int _calendarYear;
  int _calendarMonth;

  @override
  void initState() {
    super.initState();
    
    _calendarYear = selectedDateTime.year;
    _calendarMonth = selectedDateTime.month;

    _panelOpacityController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _panelOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _panelOpacityController,
      curve: Curves.easeOutSine
    ));
    _panelOpacityAnim.addListener(() {
      setState(() {
        _panelOpacity = _panelOpacityAnim.value;
        _panelOffset = _panelOffsetBase * _panelOpacityAnim.value;
      });
    });
    _panelOpacityAnim.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
        case AnimationStatus.reverse: {
          _showMonthDetail = true;
          _showMonthSimple = true;
          break;
        }
        case AnimationStatus.completed: {
          _showMonthDetail = true;
          _showMonthSimple = false;
          break;
        }
        case AnimationStatus.dismissed: {
          _showMonthDetail = false;
          _showMonthSimple = true;
          break;
        }
      }
    });

    _inputLayerController = InputLayerController(
      focusNode: FocusNode(),
      onCancel: () => setState(() => _inputIsShow = false),
    );

    _calendarController = CalendarController(
      onSelect: (date) => _closeCalendar(date),
      onMonthChange: (year, month) {
        if (_calendarController.isHigher) {
          _listLayerController.animationToFoldHigher();
        } else {
          _listLayerController.animationToFold();
        }
        setState(() {
          _calendarYear = year;
          _calendarMonth = month;
        });
      }
    );

    // 获取初始数据
    _getTaskListData().then((list){
      setState(() {
        _listLayerController.updateList(list);
      });
    });
  }

  void _openCalendar() {
    if (_calendarController.isHigher) {
      _listLayerController.animationToFoldHigher();
    } else {
      _listLayerController.animationToFold();
    }
    _panelOpacityController.forward(from: 0);
  }

  void _updateCalendar(DateTime forDate) {
    setState(() {
      selectedDateTime = forDate;
    });
    _calendarController.update(forDate);
  } 

  void _closeCalendar(DateTime backDate) {
    selectedDateTime = backDate;
    _weekController.update(backDate);
    _listLayerController.animationToNormal();
    _panelOpacityController.reverse(from: 1);
  }

  void _closeCalendarWithNoModify() {
    _listLayerController.animationToNormal();
    _panelOpacityController.reverse(from: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainPanColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Offstage(
        offstage: _inputIsShow,
        child: FloatingActionButton(
          backgroundColor: _backgroundColor,
          child: const Icon(Icons.add),
          // 添加内容按钮点击事件
          onPressed: () {
            _inputIsShow = true;
            _inputLayerController.open();
          },
        ),
      ),
      body: Container(
        color: _backgroundColor,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/images/bg.jpg'),
        //     fit: BoxFit.contain,
        //     alignment: Alignment.topCenter
        //   ),
        // ),
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Offstage(
                      offstage: !_showMonthSimple,
                      child: _buildTitleBar(1.0 - _panelOpacity),
                    ),
                    Offstage(
                      offstage: !_showMonthDetail,
                      child: _buildCalendarBar(_panelOpacity),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Offstage(
                      offstage: !_showMonthSimple,
                      child: Transform.translate(
                        offset: Offset(0.0, - _panelOffset),
                        child: _buildDatePanelSimple(1.0 - _panelOpacity),
                      ),
                    ),
                    Offstage(
                      offstage: !_showMonthDetail,
                      child: Transform.translate(
                        offset: Offset(0.0, _panelOffsetBase - _panelOffset),
                        child: _buildDatePanelDetail(_panelOpacity)
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ListLayer(
              panelColor: _mainPanColor,
              panelRadius: _mainPanRadius,
              panelTitleStyle: _mainPanTitleStyle,
              topOffsetMin: _appTitleHeight,
              topOffsetMax: _appTitleHeight + _calendarBoxHeight + _mainPanDefaultMarginTop,
              topOffsetFold: _mainPanFoldOffset,
              topOffsetFoldHigher: _mainPanFoldHigherOffset,
              taskListData: const [],
              controller: _listLayerController,
            ),
            InputLayer(
              controller: _inputLayerController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePanelSimple(double opacity) {
    return Opacity(
      opacity: opacity,
      child: WeekPanel(
        calendarColor: _calendarColor,
        calendarStyle: _calendarStyle,
        calendarBoxHeight: _calendarBoxHeight,
        calendarBoxWidth: _calendarBoxWidth,
        calendarBoxRadius: _calendarBoxRadius,
        calendarBoxGap: _calendarBoxGap,
        calendarTextGap: _calendarTextGap,
        pageMargin: _pageMargin,
        baseTime: selectedDateTime,
        controller: _weekController,
        onChange: (date) {
          _updateCalendar(date);
        },
      ),
    );
  }

  Widget _buildDatePanelDetail(double opacity) {
    return Opacity(
      opacity: opacity,
      child: CalendarPanel(
        baseTime: selectedDateTime,
        controller: _calendarController,
      ),
    );
  }

  Widget _buildBarTitle(int year, int month) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(getMonthName(month), style: _selectMonthStyle),
        const SizedBox(width: 8,),
        Text(year.toString() + ' 年', style: _selectYearStyle,),
      ],
    );
  }

  Widget _buildCalendarBar(double opacity) {
    return SafeArea(
      bottom: false,
      child: Opacity(
        opacity: opacity,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          height: _appTitleHeight,
          color: Colors.transparent,
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: _iconColor,),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _calendarController.goPrevMonth();
                  },
                ),
                _buildBarTitle(_calendarYear, _calendarMonth),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: _iconColor,),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _calendarController.goNextMonth();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(double opacity) {
    return SafeArea(
      bottom: false,
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.fromLTRB(_pageMargin, 0.0, 0.0, _pageMargin / 2),
          height: _appTitleHeight,
          color: Colors.transparent,
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildBarTitle(selectedDateTime.year, selectedDateTime.month),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: _iconColor,),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _openCalendar();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
      content: '我要做点什么事情，要做一件事！看看,look look, English!再来一个'
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
    TaskData(
      id: '7',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    TaskData(
      id: '8',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    TaskData(
      id: '9',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
  ];
}