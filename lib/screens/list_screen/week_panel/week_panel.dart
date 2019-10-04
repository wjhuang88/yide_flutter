import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'date_tools.dart';

class WeekPanel extends StatefulWidget {
  WeekPanel({
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
  _WeekPanelState(this._selectedTime, int titleCount) : _selectedIndex = titleCount ~/ 2;

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
    _listOffset = (widget.calendarBoxWidth + widget.calendarBoxGap) * (widget.tileCount ~/ 2) - widget.calendarBoxWidth * 0.6;
    _weekController = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
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
      var tileCtrl = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
      var tileAnim = Tween<double>(begin: 0, end: 1).animate(tileCtrl);
      if (i == _selectedIndex) {
        tileCtrl.value = 1;
      }
      _tileControllers[i] = tileCtrl;
      _tileAnims[i] = tileAnim;
      tileAnim.addListener((){
        setState(() {
          
        });
      });
    }
  }

  @override
  void dispose() {
    _weekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.calendarBoxHeight * 1.2,
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
    if (dragDelta > 0) {
      _goPrevTile();
    } else if (dragDelta < 0) {
      _goNextTile();
    }
    _weekController.forward();
  }

  void _goNextTile() {
    final lastkey = _weekData.lastKey();
    final nextDate = _weekData[lastkey].dateTime.add(Duration(days: 1));
    final tileCtrl = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    final tileAnim = Tween<double>(begin: 0, end: 1).animate(tileCtrl);
    setState(() {
      _weekData[lastkey + 1] = DayInfo.fromDateTime(nextDate);
      _tileControllers[lastkey + 1] = tileCtrl;
      _tileAnims[lastkey + 1] = tileAnim;
      _weekData.remove(_weekData.firstKey());
      _listOffset -= widget.calendarBoxWidth + widget.calendarBoxGap;
    });
    _listOffsetDeltaNext = _listOffsetDelta + widget.calendarBoxWidth + widget.calendarBoxGap;
    _tileControllers[_selectedIndex].reverse(from: 1);
    _tileControllers[++_selectedIndex].forward(from: 0);
    widget.onChange(_weekData[_selectedIndex].dateTime);
  }

  void _goPrevTile() {
    final firstkey = _weekData.firstKey();
    final prevDate = _weekData[firstkey].dateTime.subtract(Duration(days: 1));
    final tileCtrl = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    final tileAnim = Tween<double>(begin: 0, end: 1).animate(tileCtrl);
    setState(() {
      _weekData[firstkey - 1] = DayInfo.fromDateTime(prevDate);
      _tileControllers[firstkey - 1] = tileCtrl;
      _tileAnims[firstkey - 1] = tileAnim;
      _listOffset += widget.calendarBoxWidth + widget.calendarBoxGap;
      _weekData.remove(_weekData.lastKey());
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
    for (var i = - range; i <= range; i++) {
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
    var sizeMultiple = lerpDouble(1.0, 1.2, emphasize);
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