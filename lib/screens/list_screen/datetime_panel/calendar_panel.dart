import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yide/models/date_tools.dart';

const _weekHeaders = ['日', '一', '二', '三', '四', '五', '六'];

const _aReallyBigIndex = 30000000;

const _pagePadding = 30.0;
const _itemSpace = 8.0;
const _gridDelegate_4 = const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 4,
  childAspectRatio: 1.0,
  mainAxisSpacing: _itemSpace,
  crossAxisSpacing: _itemSpace,
);
const _gridDelegate_7 = const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 7,
  childAspectRatio: 1.0,
  mainAxisSpacing: _itemSpace,
  crossAxisSpacing: _itemSpace,
);

const _animCurve = Curves.easeOutSine;
const _animDuration = 200;

const _borderRadius = const BorderRadius.all(const Radius.circular(10));

class CalendarController {
  CalendarController({
    this.onSelect,
    this.onMonthChange});

  _CalendarPanelState _state;
  void Function(DateTime date) onSelect;
  void Function(int year, int month) onMonthChange;

  bool get isHigher => _state._pageLines[_state._pageController.page.round() - _aReallyBigIndex] == 5;
  
  void update(DateTime newDate) {
    _state?._update(newDate);
  }

  void goNextMonth() {
    _state?._nextMonth();
  }

  void goPrevMonth() {
    _state?._prevMonth();
  }

  void resetMonth(DateTime newDate) {
    _state?._update(newDate);
    _state?._pageController?.jumpToPage(_aReallyBigIndex);
  }
}

class CalendarPanel extends StatefulWidget {
  const CalendarPanel({Key key, this.baseTime, this.controller}) : super(key: key);

  final DateTime baseTime;
  final CalendarController controller;

  @override
  _CalendarPanelState createState() => _CalendarPanelState(controller, baseTime);
}

class _CalendarPanelState extends State<CalendarPanel> with SingleTickerProviderStateMixin {
  _CalendarPanelState(this._controller, this._selectedTime);

  DateTime _selectedTime;
  int _month;
  int _year;
  int get _index {
    var i;
    try {
      i = _pageController.page.round() - _aReallyBigIndex;
    } catch (e) {
      i = 0;
    }
    return i;
  }
  DateTime get _currentDate => DateTime(_year, _month + _index);

  List<DateTime> _prevList = List<DateTime>();
  List<DateTime> _currentList = List<DateTime>();
  List<DateTime> _nextList = List<DateTime>();

  Map<int, int> _pageLines = {};

  CalendarController _controller;

  AnimationController _animController;
  Animation<double> _anim;
  Animation<double> _opacityAnim;

  PageController _pageController;
  int _currentPage = 0;

  bool _animBarrier = false;

  void Function(DateTime date) _onSelect;

  double _boxHeight = 268.0;
  double _opacityFactor = 0.0;
  DateTime _showPrevMonth;
  DateTime _showCurrentMonth;
  DateTime _showNextMonth;
  DateTime _shuffleMonth;

  @override
  void initState() {
    super.initState();
    _month = _selectedTime.month;
    _year = _selectedTime.year;
    if (_controller == null) _controller = CalendarController();
    _controller._state = this;
    _onSelect = _controller.onSelect;

    _initList(_year, _month);

    _pageController = PageController(
      initialPage: _aReallyBigIndex,
      keepPage: false,
    );

    refreshShowDate();
    _shuffleMonth = _showCurrentMonth;

    _animController = AnimationController(duration: Duration(milliseconds: _animDuration), vsync: this);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval(
        0.2,
        1.0,
        curve: _animCurve,
      ),
    ))..addStatusListener((status) {
      switch(status) {
        case AnimationStatus.completed: 
        case AnimationStatus.dismissed: {
          _animBarrier = false;
          break;
        }
        case AnimationStatus.forward:
        case AnimationStatus.reverse: {
          refreshShowDate();
          _animBarrier = true;
          break;
        }
      }
    })..addListener((){
      setState(() {
        _opacityFactor = -4 * (_opacityAnim.value - 0.5) * (_opacityAnim.value - 0.5) + 1;
      });
    });
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: _animCurve,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void refreshShowDate() {
    _showCurrentMonth = _currentDate;
    var currentYear = _showCurrentMonth.year;
    var currentMonth = _showCurrentMonth.month;
    _showPrevMonth = DateTime(currentYear, currentMonth - 1);
    _showNextMonth = DateTime(currentYear, currentMonth + 1);
  }

  void substractShuffleMonth() {
    _showCurrentMonth = _currentDate;
    var currentYear = _showCurrentMonth.year;
    var currentMonth = _showCurrentMonth.month;
    _shuffleMonth = DateTime(currentYear, currentMonth - 1);
  }

  void addShuffleMonth() {
    _showCurrentMonth = _currentDate;
    var currentYear = _showCurrentMonth.year;
    var currentMonth = _showCurrentMonth.month;
    _shuffleMonth = DateTime(currentYear, currentMonth + 1);
  }

  void _initList(int year, int month) {
    _prevList.clear();
    _currentList.clear();
    _nextList.clear();
    var beginDay = DateTime(year, month, 1);
    var beginWeek = beginDay.weekday;
    if (beginWeek != DateTime.sunday) {
      for (var i = beginWeek; i >= 1; i--) {
        _prevList.add(beginDay.subtract(Duration(days: i)));
      }
    }
    while(beginDay.month == month) {
      _currentList.add(beginDay);
      beginDay = beginDay.add(Duration(days: 1));
    }
    while(beginDay.weekday <= DateTime.saturday) {
      _nextList.add(beginDay);
      beginDay = beginDay.add(Duration(days: 1));
    }
  }

  void _update(DateTime newDate) {
    if (_month != newDate.month) {
      _initList(newDate.year, newDate.month);
    }
    setState(() {
      _selectedTime = newDate;
    });
  }

  void _nextMonth() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _prevMonth() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildItem(List<DateTime> prev, List<DateTime> current, List<DateTime> next, int index) {
    if (index < prev.length) {
      return _buildOtherNode(prev[index]);
    } else if (index < prev.length + current.length) {
      var date = current[index - prev.length];
      return date.year == _selectedTime.year && date.month == _selectedTime.month && date.day == _selectedTime.day 
            ? _buildSelectedNode(date)
            : _buildCurrentNode(date);
    } else if (index < prev.length + current.length + next.length) {
      return _buildOtherNode(next[index - prev.length - current.length]);
    } else {
      print('Index out of range: prev.length: ${prev.length}; current.length: ${current.length}; next.length: ${next.length}; index: $index');
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {

    var blockSizeHigher = (MediaQuery.of(context).size.width - _pagePadding * 2) / 7 * 5;
    var blockSize = (MediaQuery.of(context).size.width - _pagePadding * 2) / 7 * 6;

    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _controller.goPrevMonth(),
              child: _buildCalendarBar(),
            ),
            Offstage(
              offstage: _opacityFactor < 0.001,
              child: Opacity(
                opacity: _opacityFactor,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    transform: Matrix4.identity()..translate(0.0, lerpDouble(0.0, 30.0, _anim.value), 0.0),
                    height: 38,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: _pagePadding),
                    child: _buildHead(_shuffleMonth, lerpDouble(14.0, 17.0, _anim.value), Colors.white, weight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
          child: Opacity(
            opacity: 1 - _opacityFactor,
            child: Transform.translate(
              offset: Offset(0.0, lerpDouble(0.0, 5.0, _opacityFactor)),
              child: _buildHead(_showCurrentMonth, 17, Colors.white, weight: FontWeight.w700),
            ),
          ),
        ),
        SizedBox(height: 8,),
        Container(
          height: 40,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: _gridDelegate_7,
            itemBuilder: (context, i) => _buildHeaderNode(_weekHeaders[i]),
            itemCount: _weekHeaders.length,
          ),
        ),
        Container(
          height: _boxHeight,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            onPageChanged: (_i) {
              final index = _i - _aReallyBigIndex;
              if (_currentPage == index) return;

              if ((index - _currentPage).abs() > 1000) {
                _pageController.jumpToPage(_currentPage + _aReallyBigIndex);
                return;
              }

              final itemDate = DateTime(_year, _month + index);
              if (_controller.onMonthChange != null) {
                _controller.onMonthChange(itemDate.year, itemDate.month);
              }
              setState(() {
                _boxHeight = _pageLines[index] == 5 ? blockSizeHigher : blockSize;
              });
              if (index < _currentPage && !_animBarrier) {
                _animController.forward(from: 0.01);
              } else if (index > _currentPage && !_animBarrier) {
                _animController.reverse(from: 0.99);
              }
              _currentPage = index;
            },
            controller: _pageController,
            itemBuilder: (context, _i) {
              final index = _i - _aReallyBigIndex;
              final itemDate = DateTime(_year, _month + index);
              _initList(itemDate.year, itemDate.month);
              var count = _prevList.length + _currentList.length + _nextList.length;
              if (_pageLines[index] == null) {
                var lines = _pageLines[index] = count ~/ 7;
                _boxHeight = lines == 5 ? blockSizeHigher : blockSize;
              } else {
                _pageLines[index] = count ~/ 7;
              }
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: _gridDelegate_7,
                itemBuilder: (context, i) => _buildItem(_prevList, _currentList, _nextList, i),
                itemCount: _prevList.length + _currentList.length + _nextList.length,
              );
            },
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _controller.goNextMonth(),
          child: _buildCalendarBottom(),
        ),
      ],
    );
  }

  Container _buildCalendarBottom() {
    return Container(
        height: 38,
        alignment: Alignment.center,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: _pagePadding),
                child: _buildHead(_showNextMonth, 14, const Color(0x4fffffff)),
              ),
            ),
            Expanded(
              flex: 4,
              child: _buildDotIcons(),
            ),
          ],
        ),
      );
  }

  Widget _buildHeaderNode(String weekday) {
    return Container(
      key: ValueKey('header_node_$weekday'),
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(weekday, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),
    );
  }

  Widget _buildCurrentNode(DateTime date) {
    const background = Colors.transparent;
    const textColor = Colors.white;
    return InkWell(
      key: ValueKey('header_node_${date.month}_${date.day}'),
      borderRadius: _borderRadius,
      onTap: () {
        _update(date);
        if (_onSelect != null) _onSelect(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: _borderRadius,
        ),
        alignment: Alignment.center,
        child: Text(date.day.toString(), style: const TextStyle(color: textColor, fontWeight: FontWeight.w700),),
      ),
    );
  }

  Widget _buildSelectedNode(DateTime date) {
    return InkWell(
      key: ValueKey('header_node_${date.month}_${date.day}'),
      borderRadius: _borderRadius,
      onTap: () {
        _update(date);
        if (_onSelect != null) _onSelect(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _borderRadius,
        ),
        alignment: Alignment.center,
        child: Text(date.day.toString(), style: const TextStyle(color: const Color(0xff0a3f74), fontWeight: FontWeight.w700),),
      ),
    );
  }

  Widget _buildOtherNode(DateTime date) {
    return Container(
      key: ValueKey('header_node_${date.month}_${date.day}'),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: _borderRadius,
      ),
      alignment: Alignment.center,
      child: Text(date.day.toString(), style: const TextStyle(color: const Color(0x2fffffff), fontWeight: FontWeight.w700),),
    );
  }

  Widget _buildCalendarBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        alignment: Alignment.center,
        height: 38,
        color: Colors.transparent,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: _pagePadding),
                child: Opacity(
                  opacity: 1 - _opacityFactor < 0.99 ? 0.0 : 1 - _opacityFactor,
                  child: _buildHead(_showPrevMonth, 14, const Color(0x4fffffff)),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: _buildDotIcons(),
            ),
          ],
        ),
      ),
    );
  }

  GridView _buildDotIcons() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: _itemSpace, right: _pagePadding),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: _gridDelegate_4,
      itemBuilder: (context, i) => const Icon(Icons.brightness_1, color: const Color(0x4fffffff), size: 8,),
      itemCount: 4,
    );
  }

  Widget _buildHead(DateTime currentDate, double size, Color color, {FontWeight weight = FontWeight.normal}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(getMonthName(currentDate.month), style: TextStyle(color: color, fontSize: size, fontWeight: weight)),
        const SizedBox(width: 8,),
        Text(currentDate.year.toString() + ' 年', style: TextStyle(color: color, fontSize: size - 2, fontWeight: weight),),
      ],
    );
  }
}