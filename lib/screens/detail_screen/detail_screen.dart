import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:yide/components/button_group.dart';
import 'package:yide/models/date_tools.dart';
import 'package:yide/models/task_data.dart';
import 'package:yide/components/panel_switcher.dart';
import 'package:yide/components/datetime_panel/calendar_panel.dart';

const _backgroundColor = const Color(0xff0a3f74);

const _appTitleHeight = 45.0;
const _mainHeight = 600.0;

const _mainPanRadius = 45.0;

const _headerStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
const _headerMargin = 20.0;

const _panelBottomMargin = 70.0;

const _boxOffsetMin = 0.0;
const _boxOffsetMax = 5.0;

const _panelDecoration = const BoxDecoration(
  color: Colors.white,
  borderRadius: const BorderRadius.only(
    topLeft: const Radius.circular(_mainPanRadius),
    topRight: const Radius.circular(_mainPanRadius),
    bottomLeft: const Radius.circular(_mainPanRadius),
    bottomRight: const Radius.circular(_mainPanRadius),
  ),
  boxShadow: <BoxShadow>[
    const BoxShadow(
      offset: const Offset(0.0, 0.0),
      blurRadius: 3.0,
      spreadRadius: 1.0,
      color: Colors.grey,
    ),
  ],
);

const _panelMargin = const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, _panelBottomMargin);

class DetailScreen extends StatefulWidget {
  DetailScreen(
    this.dataPack,
    {Key key}
  ) : super(key: key);

  final TaskPack dataPack;

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {

  TaskTag _tagData;

  DateTime _taskDate;

  IconData _floatingButtomIcon = Icons.check;
  VoidCallback _floatingButtomAction = () {};

  List<TaskTag> _tagList = const [];

  PanelSwitcherController _panelSwitcherController;

  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _tagData = widget.dataPack.tag;
    _taskDate = widget.dataPack.data.taskTime;

    getTagList().then((list) {
      setState(() {
        _tagList = list;
      });
    });

    _panelSwitcherController = PanelSwitcherController();
    _calendarController = CalendarController(
      onSelect: (date) {
        _taskDate = date;
        _switchBack();
      }
    );
  }

  void _switchBack() {
    var isDatePage = _panelSwitcherController.currentPage == 'date';
    _panelSwitcherController.switchBack(() {
      _floatingButtomAction = () {};
      if (isDatePage) {
        _calendarController.resetMonth(_taskDate);
      }
      setState(() {
        _floatingButtomIcon = Icons.check;
      });
    });
  }

  void _switchTo(String page) {
    _floatingButtomAction = _switchBack;
    _panelSwitcherController.switchTo(page, () {
      setState(() {
        _floatingButtomIcon = Icons.keyboard_backspace;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_appTitleHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          brightness: Brightness.dark,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white, size: 28,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.white, size: 24,),
              onPressed: () {},
            ),
            SizedBox(width: 10.0,),
          ],
        ),
      ),
      floatingActionButtonLocation: _FloatingLocation(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(_floatingButtomIcon),
        onPressed: _floatingButtomAction,
      ),
      body: Hero(
        tag: 'panel_background',
        flightShuttleBuilder: (_, __, ___, ____, _____) => Container(
          decoration: _panelDecoration,
          margin: _panelMargin,
        ),
        child: PanelSwitcher(
          initPage: 'main',
          backgroundPage: 'main',
          controller: _panelSwitcherController,
          pageMap: {
            'main': (context, animValue) {
              var boxOffset = lerpDouble(_boxOffsetMin, _boxOffsetMax, animValue);
              return DetailPanel(
                boxOffset: boxOffset,
                child: _mainPanelBuilder(context),
              );
            },
            'tags': (context, animValue) {
              var boxOffset = lerpDouble(-300, 0, animValue);
              return DetailPanel(
                boxOffset: boxOffset,
                child: _tagsPanelBuilder(context),
              );
            },
            'date': (context, animValue) {
              var boxOffset = lerpDouble(-300, 0, animValue);
              return DetailPanel(
                boxOffset: boxOffset,
                child: _datePanelBuilder(context),
              );
            },
          },
        ),
      ),
    );
  }

  Widget _datePanelBuilder(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: _headerMargin,),
        const Text('日期', style: _headerStyle,),
        const SizedBox(height: _headerMargin,),

        ButtonGroup(
          color: Colors.blue,
          textColor: Colors.white,
          height: 30.0,
          width: 240.0,
          dataSet: {
            '今日': () {},
            '明天': () {},
            '下周': () {},
          },
        ),
        const SizedBox(height: _headerMargin,),

        CalendarPanel(
          baseTime: widget.dataPack.data.taskTime,
          controller: _calendarController,
          textColor: Colors.blueGrey[700],
          selectedColor: Colors.blue,
          selectedTextColor: Colors.white,
          fadedColor: Colors.grey,
          showBottom: false,
        )
      ],
    );
  }

  Widget _tagsPanelBuilder(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: _headerMargin,),
        const Text('标签', style: _headerStyle,),
        const SizedBox(height: _headerMargin + 15,),
      ]..addAll(_tagList.map(
        (tag) => Container(
          width: 250.0,
          height: 50.0,
          margin: EdgeInsets.all(10.0),
          child: FlatButton.icon(
            label: Text(tag.name),
            icon: tag.icon,
            color: tag.backgroundColor,
            shape: StadiumBorder(),
            onPressed: () {
              _tagData = tag;
              _panelSwitcherController.switchBack(() {
                _floatingButtomAction = () {};
                setState(() {
                  _floatingButtomIcon = Icons.check;
                });
              });
            },
          ),
        )
      )),
    );
  }

  Widget _mainPanelBuilder(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 0.0),
      children: <Widget>[
        Text(widget.dataPack.data.content, style: _headerStyle, textAlign: TextAlign.center,),

        const SizedBox(height: _headerMargin,),
        GestureDetector(
          onTap: () => _switchTo('date'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.calendar_today, color: Colors.grey, size: 18,),
              const SizedBox(width: 5,),
              Text('${_taskDate.month}月${_taskDate.day}日  ${getWeekNameLong(_taskDate.weekday)}', textAlign: TextAlign.center,),
            ],
          ),
        ),
        const SizedBox(height: _headerMargin,),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
              icon: _tagData.icon,
              label: Text(_tagData.name),
              color: _tagData.backgroundColor,
              colorBrightness: Brightness.light,
              shape: StadiumBorder(),
              onPressed: () => _switchTo('tags'),
            ),
          ],
        ),

        const SizedBox(height: _headerMargin,),
        const Text('提醒', style: _headerStyle, textAlign: TextAlign.center,),
        const SizedBox(height: _headerMargin,),
        GestureDetector(
          onTap: () => showCupertinoModalPopup(
            context: context,
            builder: (context) => Container(
              height: 150.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                onDateTimeChanged: (date) {},
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20,),
              const Text('点击添加', textAlign: TextAlign.center,),
            ],
          ),
        ),

        const SizedBox(height: _headerMargin,),
        const Text('重复', style: _headerStyle, textAlign: TextAlign.center,),
        const SizedBox(height: _headerMargin,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20,),
            const Text('点击添加', textAlign: TextAlign.center,),
          ],
        ),

        const SizedBox(height: _headerMargin,),
        const Text('备注', style: _headerStyle, textAlign: TextAlign.center,),
        const SizedBox(height: _headerMargin,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20,),
            const Text('点击添加', textAlign: TextAlign.center,),
          ],
        ),
      ],
    );
  }
}

class DetailPanel extends StatelessWidget {
  const DetailPanel({
    Key key,
    @required this.boxOffset,
    this.child,
  }) : super(key: key);

  final double boxOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      transform: Matrix4.translationValues(boxOffset, boxOffset, 0.0),
      height: _mainHeight,
      margin: _panelMargin,
      decoration: _panelDecoration,
      child: child,
    );
  }
}

class _FloatingLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;
    double fabY = min(_appTitleHeight + _mainHeight + 15, scaffoldGeometry.scaffoldSize.height - _panelBottomMargin - 30);
    return Offset(fabX, fabY);
  }
}