import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:yide/models/date_tools.dart';
import 'package:yide/components/sqlite_fetcher.dart';
import 'package:yide/components/datetime_panel/week_panel.dart';
import 'package:yide/components/datetime_panel/calendar_panel.dart';

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
const _calendarBoxRadius = 18.0;
const _calendarBoxGap = 16.0;
const _calendarTextGap = 5.0;
const _canlendarPagePadding = 30.0;

const _mainPanColor = Colors.white;
const _mainPanDefaultMarginTop = 50.0;
const _mainPanRadius = 45.0;
const _mainPanTitleStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 16, letterSpacing: 5, fontWeight: FontWeight.w600);

const _panelOffsetBase = 300.0;

final logger = Logger(
  printer: PrettyPrinter(methodCount: 0, lineLength: 80, printTime: true),
);

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

  @override
  void initState() {
    super.initState();

    logger.d('Init calendar opacity animation.');
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

    logger.d('Init InputLayerController.');
    _inputLayerController = InputLayerController(
      focusNode: FocusNode(),
      onCancel: () => setState(() => _inputIsShow = false),
      onConfirm: () {
        _listLayerController.updateList(selectedDateTime);
        setState(() => _inputIsShow = false);
      },
    );

    logger.d('Init CalendarController.');
    _calendarController = CalendarController(
      onSelect: (date) => _closeCalendar(date),
      onMonthChange: (year, month) {
        if (_calendarController.isHigher) {
          _listLayerController.animationToFoldHigher();
        } else {
          _listLayerController.animationToFold();
        }
      }
    );
  }

  void _openCalendar() {
    logger.d('Calendar detail is opening.');
    if (_calendarController.isHigher) {
      _listLayerController.animationToFoldHigher();
    } else {
      _listLayerController.animationToFold();
    }
    _panelOpacityController.forward(from: 0);
  }

  void _updateCalendar(DateTime forDate) {
    logger.d('Updating Calendar data.');
    setState(() {
      selectedDateTime = forDate;
    });
    _calendarController.update(forDate);
    _listLayerController.updateList(forDate);
  } 

  void _closeCalendar(DateTime backDate) {
    logger.d('Closing Calendar with data update.');
    selectedDateTime = backDate;
    _weekController.update(backDate);
    _listLayerController.animationToNormal();
    _panelOpacityController.reverse(from: 1);
    _listLayerController.updateList(backDate);
  }

  void _closeCalendarWithNoModify() {
    logger.d('Closing Calendar without data update.');
    _listLayerController.animationToNormal();
    _panelOpacityController.reverse(from: 1);
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Building ListScreen.');
    
    var blockSizeHigher = (MediaQuery.of(context).size.width - _canlendarPagePadding * 2) / 7 * 6 + 75 + _appTitleHeight;
    var blockSize = (MediaQuery.of(context).size.width - _canlendarPagePadding * 2) / 7 * 7 + 75 + _appTitleHeight;

    return Scaffold(
      backgroundColor: _mainPanColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Offstage(
        offstage: _inputIsShow,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
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
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Offstage(
                  offstage: !_showMonthSimple,
                  child: _buildTitleBar(1.0 - _panelOpacity),
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
                  ],
                ),
              ],
            ),
            Offstage(
              offstage: !_showMonthDetail,
              child: Transform.translate(
                offset: Offset(0.0, _panelOffsetBase - _panelOffset),
                child: _buildDatePanelDetail(_panelOpacity)
              ),
            ),
            ListLayer(
              panelColor: _mainPanColor,
              panelRadius: _mainPanRadius,
              panelTitleStyle: _mainPanTitleStyle,
              topOffsetMin: _appTitleHeight,
              topOffsetMax: _appTitleHeight + _calendarBoxHeight + _mainPanDefaultMarginTop,
              topOffsetFold: blockSize,
              topOffsetFoldHigher: blockSizeHigher,
              controller: _listLayerController,
              initDate: selectedDateTime,
            ),
            InputLayer(
              controller: _inputLayerController,
              sqliteController: SqliteController.instance,
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

  Widget _buildTitleBar(double opacity) {
    return SafeArea(
      bottom: false,
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.fromLTRB(_pageMargin, 0.0, 0.0, _pageMargin / 2),
          height: _appTitleHeight * opacity,
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