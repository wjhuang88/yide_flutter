import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:yide/components/button_group.dart';
import 'package:yide/models/date_tools.dart';
import 'package:yide/models/task_data.dart';
import 'package:yide/components/panel_switcher.dart';
import 'package:yide/components/datetime_panel/calendar_panel.dart';

const _backgroundColor = const Color(0xff0a3f74);

const _appTitleHeight = 45.0;

const _mainPanRadius = 45.0;

const _headerStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
const _sectionStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
const _sectionMargin = 10.0;
const _headerMargin = 25.0;

const _panelDecoration = const BoxDecoration(
  color: Colors.white,
  borderRadius: const BorderRadius.only(
    topLeft: const Radius.circular(_mainPanRadius),
    topRight: const Radius.circular(_mainPanRadius),
  ),
  boxShadow: <BoxShadow>[
    const BoxShadow(
      offset: const Offset(0.0, -3.0),
      blurRadius: 3.0,
      color: const Color(0x4CBDBDBD),
    ),
  ],
);

const _panelMargin = EdgeInsets.zero;

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

  DateTime _pickedTime;
  DateTime _alarmTime;

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
    _alarmTime = widget.dataPack.data.alarmTime;

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(_floatingButtomIcon),
        onPressed: _floatingButtomAction,
      ),
      body: Stack(
        children: <Widget>[
          PreferredSize(
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
          Positioned.fill(
            child: Hero(
              tag: 'panel_background',
              flightShuttleBuilder: (_, __, ___, ____, _____) {
                return SafeArea(
                  bottom: false,
                  child: Container(
                    decoration: _panelDecoration,
                    margin: _panelMargin + EdgeInsets.only(top: _appTitleHeight),
                  ),
                );
              },
              child: PanelSwitcher(
                initPage: 'main',
                backgroundPage: 'main',
                controller: _panelSwitcherController,
                pageMap: {
                  'main': (context, animValue) {
                    return DetailPanel(
                      boxOffset: 0,
                      backgroundOpacity: 0,
                      height: double.infinity,
                      child: _mainPanelBuilder(context),
                      backAction: _switchBack,
                    );
                  },
                  'tags': (context, animValue) {
                    var boxOffset = lerpDouble(-300, 0, animValue);
                    var bgOpacity = lerpDouble(0.0, 0.5, animValue);
                    return DetailPanel(
                      boxOffset: boxOffset,
                      backgroundOpacity: bgOpacity,
                      height: 400.0,
                      child: _tagsPanelBuilder(context),
                      backAction: _switchBack,
                    );
                  },
                  'date': (context, animValue) {
                    var boxOffset = lerpDouble(-300, 0, animValue);
                    var bgOpacity = lerpDouble(0.0, 0.5, animValue);
                    return DetailPanel(
                      boxOffset: boxOffset,
                      backgroundOpacity: bgOpacity,
                      height: 500.0,
                      child: _datePanelBuilder(context),
                      backAction: _switchBack,
                    );
                  },
                  'alarm': (context, animValue) {
                    var boxOffset = lerpDouble(-300, 0, animValue);
                    var bgOpacity = lerpDouble(0.0, 0.5, animValue);
                    return DetailPanel(
                      boxOffset: boxOffset,
                      backgroundOpacity: bgOpacity,
                      height: 370.0,
                      child: _alarmPanelBuilder(context),
                      backAction: _switchBack,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alarmPanelBuilder(BuildContext context) {
    const radius = const BorderRadius.all(Radius.circular(25));
    return Column(
      children: <Widget>[
        const SizedBox(height: _headerMargin,),
        const Text('时间', style: _headerStyle,),
        const SizedBox(height: _headerMargin,),

        Container(
          height: 150.0,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]),
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: CupertinoDatePicker(
              initialDateTime: _alarmTime ?? DateTime.now(),
              mode: CupertinoDatePickerMode.time,
              onDateTimeChanged: (date) {
                _pickedTime = date;
              },
            ),
          ),
        ),
        const SizedBox(height: _headerMargin,),

        FlatButton(
          shape: StadiumBorder(),
          child: Text('设定'),
          color: Colors.blue,
          textColor: Colors.white,
          onPressed: () {
            _alarmTime = _pickedTime ?? DateTime.now();
            _switchBack();
          },
        ),
      ],
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
          width: 340,
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
            icon: Icon(tag.icon, color: tag.iconColor,),
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

    final rowContainer = ({Widget child, double height = 40.0}) => Container(
      child: child,
      height: height,
      padding: EdgeInsets.only(left: 16.0),
      decoration: BoxDecoration(
        color: _tagData.backgroundColor,
        borderRadius: const BorderRadius.all(const Radius.circular(10.0))
      ),
    );

    final defaultRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20,),
        const SizedBox(width: 10,),
        const Text('点击添加', textAlign: TextAlign.left,),
      ],
    );

    final titledRow = ({String title, Widget child}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: _headerMargin,),
        Text(title, style: _sectionStyle, textAlign: TextAlign.left,),
        const SizedBox(height: _sectionMargin,),
        child,
      ],
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 0.0),
      children: <Widget>[
        const SizedBox(height: _headerMargin,),
        Text(widget.dataPack.data.content, style: _headerStyle, textAlign: TextAlign.left,),
        const Divider(height: _sectionMargin,),

        Row(
          children: <Widget>[
            titledRow(
              title: '类型',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 40.0,
                    child: FlatButton.icon(
                      icon: Icon(_tagData.icon, color: _tagData.iconColor,),
                      label: Text(_tagData.name),
                      color: _tagData.backgroundColor,
                      colorBrightness: Brightness.light,
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                      ),
                      onPressed: () => _switchTo('tags'),
                    ),
                  ),
                ],
              )
            ),
            const SizedBox(width: 10.0,),
            Expanded(
              child: titledRow(
                title: '日期',
                child: GestureDetector(
                  onTap: () => _switchTo('date'),
                  child: rowContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.calendar_today, color: Colors.grey, size: 18,),
                        const SizedBox(width: 10,),
                        Text('${_taskDate.month}月${_taskDate.day}日  ${getWeekNameLong(_taskDate.weekday)}', textAlign: TextAlign.left,),
                      ],
                    ),
                  ),
                )
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: titledRow(
                title: '提醒',
                child: GestureDetector(
                  onTap: () => _switchTo('alarm'),
                  child: rowContainer(
                    child: _alarmTime == null 
                      // 提醒时间为空则创建提示信息
                      ? defaultRow
                      // 提醒时间不为空则显示提醒时间
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.alarm, color: Colors.grey, size: 20,),
                          const SizedBox(width: 10,),
                          Text(DateFormat('jm').format(_alarmTime), textAlign: TextAlign.left,),
                        ],
                      ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0,),
            Expanded(
              child: titledRow(
                title: '重复',
                child: rowContainer(
                  child: defaultRow,
                ),
              ),
            ),
          ],
        ),

        titledRow(
          title: '备注',
          child: rowContainer(
            child: defaultRow,
          ),
        ),
      ],
    );
  }
}

class DetailPanel extends StatelessWidget {
  const DetailPanel({
    Key key,
    @required this.boxOffset,
    @required this.backgroundOpacity,
    @required this.height,
    this.child,
    this.backAction,
  }) : super(key: key);

  final double boxOffset;
  final Widget child;
  final double backgroundOpacity;
  final double height;
  final VoidCallback backAction;

  @override
  Widget build(BuildContext context) {

    Widget panel;
    if (height.isInfinite) {
      panel = Container(
        alignment: Alignment.topCenter,
        transform: Matrix4.translationValues(0.0, -boxOffset, 0.0),
        margin: _panelMargin,
        decoration: _panelDecoration,
        child: child,
      );
    } else {
      panel = Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: backAction ?? () {},
              child: Container(),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            transform: Matrix4.translationValues(0.0, -boxOffset, 0.0),
            height: height,
            margin: _panelMargin,
            decoration: _panelDecoration,
            child: child,
          ),
        ],
      );
    }
    assert(panel != null);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Offstage(
          offstage: backgroundOpacity < 0.01,
          child: Container(
            color: Colors.black.withOpacity(backgroundOpacity),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Container(
            margin: const EdgeInsets.only(top: _appTitleHeight),
            child: panel,
          ),
        ),
      ],
    );
  }
}

// class _FloatingLocation extends FloatingActionButtonLocation {
//   @override
//   Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
//     final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;
//     double fabY = math.min(_appTitleHeight + _mainHeight + 15, scaffoldGeometry.scaffoldSize.height - _panelBottomMargin - 30);
//     return Offset(fabX, fabY);
//   }
// }