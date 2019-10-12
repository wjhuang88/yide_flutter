import 'package:flutter/material.dart';

const _weekHeaders = ['日', '一', '二', '三', '四', '五', '六'];

const _aReallyBigIndex = 30000000;

class CalendarController {
  CalendarController({
    this.onSelect,
    this.onMonthChange});

  _CalendarPanelState _state;
  void Function(DateTime date) onSelect;
  void Function(int year, int month) onMonthChange;
  
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

class _CalendarPanelState extends State<CalendarPanel> {
  _CalendarPanelState(this._controller, this._selectedTime);

  DateTime _selectedTime;
  int _month;
  int _year;

  List<DateTime> _prevList = List<DateTime>();
  List<DateTime> _currentList = List<DateTime>();
  List<DateTime> _nextList = List<DateTime>();

  CalendarController _controller;

  PageController _pageController;

  void Function(DateTime date) _onSelect;

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutSine,
    );
  }

  void _prevMonth() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutSine,
    );
  }

  List<Widget> _buildItems(List<DateTime> prev, List<DateTime> current, List<DateTime> next) {
    return _weekHeaders.map((weekday) => _buildHeaderNode(weekday))
      .toList()
      ..addAll(prev.map((date) => _buildOtherNode(date)))
      ..addAll(current.map(
        (date) => 
          date.month == _selectedTime.month && date.day == _selectedTime.day 
            ? _buildSelectedNode(date)
            : _buildCurrentNode(date))
      )
      ..addAll(next.map((date) => _buildOtherNode(date)));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 350,
        child: PageView.builder(
          onPageChanged: (_i) {
            final index = _i - _aReallyBigIndex;
            final itemDate = DateTime(_year, _month + index);
            if (_controller.onMonthChange != null) {
              _controller.onMonthChange(itemDate.year, itemDate.month);
            }
          },
          controller: _pageController,
          itemBuilder: (context, _i) {
            final index = _i - _aReallyBigIndex;
            final itemDate = DateTime(_year, _month + index);
            _initList(itemDate.year, itemDate.month);
            return GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              children: _buildItems(_prevList, _currentList, _nextList),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderNode(String weekday) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Text(weekday, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),
    );
  }

  Widget _buildCurrentNode(DateTime date) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _update(date);
        if (_onSelect != null) _onSelect(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(date.day.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),
      ),
    );
  }

  Widget _buildSelectedNode(DateTime date) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _update(date);
        if (_onSelect != null) _onSelect(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(date.day.toString(), style: const TextStyle(color: const Color(0xff0a3f74), fontWeight: FontWeight.w700),),
      ),
    );
  }

  Widget _buildOtherNode(DateTime date) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(date.day.toString(), style: const TextStyle(color: const Color(0x2fffffff), fontWeight: FontWeight.w700),),
    );
  }
}