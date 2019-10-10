import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'date_tools.dart';

const double _sizeFactor = 1.3;
const int _indexOffset = 2;
const double _offsetFactor = 0.7;
const int _animationSpeed = 300;

class WeekPanel extends StatefulWidget {
  const WeekPanel({
    Key key,
    @required this.calendarColor,
    @required this.calendarStyle,
    @required this.calendarBoxHeight,
    @required this.calendarBoxWidth,
    @required this.calendarBoxRadius,
    @required this.calendarBoxGap,
    @required this.calendarTextGap,
    @required this.pageMargin,
    @required this.baseTime,
    @required this.onChange,
    this.tileCount = 9,
  }) : super(key: key);

  final Color calendarColor;
  final TextStyle calendarStyle;
  final double calendarBoxHeight;
  final double calendarBoxWidth;
  final double calendarBoxRadius;
  final double calendarBoxGap;
  final double calendarTextGap;
  final double pageMargin;

  final DateTime baseTime;
  final int tileCount;

  final void Function(DateTime date) onChange;

  @override
  _WeekPanelState createState() => _WeekPanelState(baseTime, tileCount);
}

class _WeekPanelState extends State<WeekPanel> with TickerProviderStateMixin {
  _WeekPanelState(this._selectedTime, int titleCount) : _selectedIndex = titleCount ~/ 2 - _indexOffset;

  DateTime _selectedTime;
  SplayTreeMap<int, DayInfo> _weekData;

  Map<int, Key> _tileKeyList = {};
  int _selectedIndex;

  double _listOffset;
  double _listOffsetDelta = 0.0;
  double _listOffsetDeltaNext = 0.0;

  AnimationController _weekController;
  Animation<double> _listAnim;

  Map<int, AnimationController> _tileControllers = {};
  Map<int, Animation<double>> _tileAnims = {};

  bool _animationBarrier = false;

  double _dragStart = 0, _dragDelta = 0;

  @override
  void initState() {
    super.initState();
    _weekData = _getDayInfoList(_selectedTime);
    _listOffset = (widget.calendarBoxWidth + widget.calendarBoxGap) * (_selectedIndex) - widget.calendarBoxWidth * _offsetFactor;
    _weekController = AnimationController(duration: Duration(milliseconds: _animationSpeed), vsync: this);
    _listAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _weekController,
      curve: Curves.bounceInOut
    ));

    _weekController.addListener(() {
      setState(() {
        if (_listOffsetDelta != _listOffsetDeltaNext) {
          _listOffsetDelta = lerpDouble(_listOffsetDelta, _listOffsetDeltaNext, _listAnim.value);
        }
      });
    });
    _weekController.addStatusListener((status) {
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        _animationBarrier = true;
      }
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _animationBarrier = false;
        _weekController.reset();
      }
    });
    var first = _weekData.firstKey();
    var last = _weekData.lastKey();
    for (var i = first; i <= last; i++) {
      var tileCtrl = AnimationController(duration: Duration(milliseconds: _animationSpeed), vsync: this);
      var tileAnim = Tween<double>(begin: 0, end: 1).animate(tileCtrl);
      if (i == _selectedIndex) {
        tileCtrl.value = 1;
      }
      _tileControllers[i] = tileCtrl;
      _tileAnims[i] = tileAnim;
      tileAnim.addListener((){
        setState(() {
          // 触发渲染
        });
      });
    }
  }

  @override
  void dispose() {
    _weekController.dispose();
    _tileKeyList.clear();
    _weekData.clear();

    _tileControllers.forEach((i, e) => e.dispose());
    _tileControllers.clear();
    _tileAnims.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.calendarBoxHeight * _sizeFactor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragDown: (detail) {
          _dragStart = detail.globalPosition.dx;
        },
        onHorizontalDragUpdate: (detail) {
          _dragDelta = detail.globalPosition.dx - _dragStart;
          if (_animationBarrier) return;
          if (_dragDelta.abs() > 30) {
            _doListMove(_dragDelta);
            _dragStart = detail.globalPosition.dx;
            _dragDelta = 0;
          }
        },
        onHorizontalDragEnd: (detail) {
          if (_animationBarrier) return;
          _doListMove(_dragDelta);
        },
        child: Viewport(
          axisDirection: AxisDirection.right,
          offset: ViewportOffset.fixed(_listOffset + _listOffsetDelta),
          slivers: _makeTileSlivers(),
        ),
      ),
    );
  }

  void _doListMove(double dragDelta) {
    if (dragDelta > 10) {
      _goPrevTile();
    } else if (dragDelta < -10) {
      _goNextTile();
    }
    _weekController.forward();
  }

  void _goNextTile() {
    final lastkey = _weekData.lastKey();
    final firstkey = _weekData.firstKey();
    final nextDate = _weekData[lastkey].dateTime.add(Duration(days: 1));
    setState(() {
      _weekData[lastkey + 1] = DayInfo.fromDateTime(nextDate);
      _tileControllers[lastkey + 1] = _tileControllers[firstkey];
      _tileControllers.remove(firstkey);
      _tileAnims[lastkey + 1] = _tileAnims[firstkey];
      _tileAnims.remove(firstkey);
      _weekData.remove(firstkey);
      _listOffset -= widget.calendarBoxWidth + widget.calendarBoxGap;
    });
    _listOffsetDeltaNext = _listOffsetDelta + widget.calendarBoxWidth + widget.calendarBoxGap;
    _tileControllers[_selectedIndex].reverse(from: 1);
    _tileControllers[++_selectedIndex].forward(from: 0);
    widget.onChange(_weekData[_selectedIndex].dateTime);
  }

  void _goPrevTile() {
    final firstkey = _weekData.firstKey();
    final lastkey = _weekData.lastKey();
    final prevDate = _weekData[firstkey].dateTime.subtract(Duration(days: 1));
    setState(() {
      _weekData[firstkey - 1] = DayInfo.fromDateTime(prevDate);
      _tileControllers[firstkey - 1] = _tileControllers[lastkey];
      _tileControllers.remove(lastkey);
      _tileAnims[firstkey - 1] = _tileAnims[lastkey];
      _tileAnims.remove(lastkey);
      _weekData.remove(lastkey);
      _listOffset += widget.calendarBoxWidth + widget.calendarBoxGap;
    });
    _listOffsetDeltaNext = _listOffsetDelta - widget.calendarBoxWidth - widget.calendarBoxGap;
    _tileControllers[_selectedIndex].reverse(from: 1);
    _tileControllers[--_selectedIndex].forward(from: 0);
    widget.onChange(_weekData[_selectedIndex].dateTime);
  }

  List<SliverToBoxAdapter> _makeTileSlivers() {
    final firstIndex = _weekData.firstKey();
    final lastIndex = _weekData.lastKey();
    final slivers = <SliverToBoxAdapter>[];
    _tileKeyList.clear();
    for (var i = firstIndex; i <= lastIndex; i++) {
      var data = _weekData[i];
      var week = getWeekName(data.weekday);
      var day = data.day.toString();
      if (i != firstIndex) {
        slivers.add(SliverToBoxAdapter(child: Container(width: widget.calendarBoxGap,),));
      }
      var sliverKey = ValueKey('week_pan_tile_$week\_$day');
      var anim = _tileAnims[i];
      slivers.add(SliverToBoxAdapter(
        key: sliverKey,
        child: _WeekPanTile(
          data: data,
          parent: widget,
          week: week,
          day: day,
          emphasize: anim.value,
        ),
      ));
      _tileKeyList[i] = sliverKey;
    }
    return slivers;
  }

  SplayTreeMap<int, DayInfo> _getDayInfoList(DateTime baseTime) {
    var list = SplayTreeMap<int, DayInfo>();
    var range = widget.tileCount ~/ 2;
    var mapIndex = 0;
    for (var i = - range + _indexOffset; i <= range + _indexOffset; i++) {
      if (i < 0 ) {
        list[mapIndex] = DayInfo.fromDateTime(baseTime.subtract(Duration(days: -i)));
      } else if (i == 0) {
        list[mapIndex] = DayInfo.fromDateTime(baseTime, isSelected: true);
      } else {
        list[mapIndex] = DayInfo.fromDateTime(baseTime.add(Duration(days: i)));
      }
      mapIndex++;
    }
    return list;
  }
}

class _WeekPanTile extends StatelessWidget {
  const _WeekPanTile({
    Key key,
    @required this.data,
    @required this.parent,
    @required this.week,
    @required this.day,
    this.emphasize = 0,
  }) : super(key: key);

  final DayInfo data;
  final WeekPanel parent;
  final String week;
  final String day;

  final double emphasize;

  @override
  Widget build(BuildContext context) {
    var sizeMultiple = lerpDouble(1.0, _sizeFactor, emphasize);
    var opacityLerp = lerpDouble(0.3, 1.0, emphasize);
    return Align(
      key: ValueKey('weekday_panel_key_${data.weekday}_${data.day}'),
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacityLerp,
        child: Container(
          height: parent.calendarBoxHeight * sizeMultiple,
          width: parent.calendarBoxWidth * sizeMultiple,
          decoration: BoxDecoration(
            color: parent.calendarColor,
            borderRadius: BorderRadius.circular(parent.calendarBoxRadius)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(week, style: parent.calendarStyle,),
              SizedBox(height: parent.calendarTextGap,),
              Text(day, style: parent.calendarStyle,),
            ],
          ),
        ),
      ),
    );
  }
}