import 'package:flutter/material.dart';

import 'date_tools.dart';

const _appBarHeight = 70.0;
const _backgroundColor = const Color(0xff0a3f74);
const _brightness = Brightness.dark;
const _pageMargin = 20.0;

const _selectMonthStyle = const TextStyle(color: Colors.white, fontSize: 16);
const _iconColor = Colors.white;

const _calendarColor = Colors.white;
const _calendarStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 16, fontWeight: FontWeight.w600);
const _calendarBoxHeight = 80.0;
const _calendarBoxWidth = 70.0;
const _calendarBoxRadius = 15.0;
const _calendarBoxGap = 15.0;
const _calendarTextGap = 10.0;

const _mainPanColor = Colors.white;
const _mainPanDefaultMarginTop = 45;
const _mainPanRadius = 45.0;
const _mainPanTitleStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 20, letterSpacing: 5, fontWeight: FontWeight.w600);

class ListScreenV2 extends StatefulWidget {
  @override
  _ListScreenV2State createState() => _ListScreenV2State();
}

class _ListScreenV2State extends State<ListScreenV2> with SingleTickerProviderStateMixin {

  AnimationController controller;
  int monthValue = DateTime.now().month;
  Map<int, int> weekData = {7: 22, 1: 23, 2: 24, 3: 25, 4: 26, 5: 27, 6: 28};

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context, title: _buildDatePan(context)),
      body: Stack(
        children: <Widget>[
          _buildWeekPan(context),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: _calendarBoxHeight + _mainPanDefaultMarginTop),
              decoration: BoxDecoration(
                color: _mainPanColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_mainPanRadius),
                  topRight: Radius.circular(_mainPanRadius),
                )
              ),
              child: _buildListPage(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, {Widget title}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(_appBarHeight),
      child: AppBar(
        backgroundColor: _backgroundColor,
        brightness: _brightness,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today, color: _iconColor,),
            onPressed: () {},
          )
        ],
        title: title,
        titleSpacing: 0,

      ),
    );
  }

  Widget _buildDatePan(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: _pageMargin,),
        Text(getMonthName(monthValue), style: _selectMonthStyle),
        SizedBox(width: 8,),
        Icon(Icons.keyboard_arrow_down, color: _iconColor, size: 22,),
      ],
    );
  }

  Widget _buildWeekPan(BuildContext context) {
    var index = 0;
    var count = weekData.length;
    assert(count >= 5);

    return Container(
      height: _calendarBoxHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: weekData.keys.map((dayValue) {
          var week = getWeekName(dayValue);
          var day = weekData[dayValue].toString();
          var marginLeft = index > 0 ? _calendarBoxGap : _pageMargin;
          var marginRight = index < count - 1 ? 0.0 : _pageMargin;
          ++index;
          return Container(
            margin: EdgeInsets.only(left: marginLeft, right: marginRight),
            width: _calendarBoxWidth,
            decoration: BoxDecoration(
              color: _calendarColor,
              borderRadius: BorderRadius.circular(_calendarBoxRadius)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(week, style: _calendarStyle,),
                SizedBox(height: _calendarTextGap,),
                Text(day, style: _calendarStyle,),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListPage(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 15,),
        Text('任务', style: _mainPanTitleStyle,),
        SizedBox(height: 15,),
        Divider(height: 0,),
      ],
    );
  }
}
