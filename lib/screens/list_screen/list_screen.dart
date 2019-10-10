import 'dart:ui';

import 'package:flutter/material.dart';

import 'week_panel/week_panel.dart';
import 'week_panel/date_tools.dart';
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

const _showMonthDetail = false;

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> with TickerProviderStateMixin {

  DateTime selectedDateTime = DateTime.now();

  bool _inputIsShow = false;

  InputLayerController _inputLayerController = InputLayerController(
    focusNode: FocusNode(),
  );

  ListLayerController _listLayerController = ListLayerController();

  @override
  void initState() {
    super.initState();

    _inputLayerController.onCancel((){
      setState(() {
        _inputIsShow = false;
      });
    });

    // 获取初始数据
    _getTaskListData().then((list){
      setState(() {
        _listLayerController.updateList(list);
      });
    });
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
                _buildTitleBar(),
                _showMonthDetail ? _buildDatePanelDetail(1.0) : _buildDatePanelSimple(1.0),
              ],
            ),
            ListLayer(
              panelColor: _mainPanColor,
              panelRadius: _mainPanRadius,
              panelTitleStyle: _mainPanTitleStyle,
              topOffsetMin: _appTitleHeight,
              topOffsetMax: _appTitleHeight + _calendarBoxHeight + _mainPanDefaultMarginTop,
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
        onChange: (date) {
          setState(() {
            selectedDateTime = date;
          });
        },
      ),
    );
  }

  Widget _buildDatePanelDetail(double opacity) {
    return Container();
  }

  Widget _buildTitleBar({Widget title}) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(_pageMargin, 0.0, 0.0, _pageMargin / 2),
        height: _appTitleHeight,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(getMonthName(selectedDateTime.month), style: _selectMonthStyle),
                  const SizedBox(width: 8,),
                  Text(selectedDateTime.year.toString() + ' 年', style: _selectYearStyle,),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: _iconColor,),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _listLayerController.animationToFold();
                },
              ),
            ],
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