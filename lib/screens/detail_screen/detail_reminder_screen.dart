import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/components/flipping_tile.dart';

class DetailReminderScreen extends StatefulWidget {
  static const String routeName = 'detail_reminder';
  static Route get pageRoute => _buildRoute(DetailReminderScreen());

  @override
  _DetailReminderScreenState createState() => _DetailReminderScreenState();
}

class _DetailReminderScreenState extends State<DetailReminderScreen> {
  int bitMap = 0;

  bool get _isRightTime => bitMap & 1 != 0;
  void _reverseRightTime() => bitMap ^= 1;

  bool get _is5Minites => bitMap & (1 << 1) != 0;
  void _reverse5Minites() => bitMap ^= 1 << 1;

  bool get _is10Minites => bitMap & (1 << 2) != 0;
  void _reverse10Minites() => bitMap ^= 1 << 2;

  bool get _is15Minites => bitMap & (1 << 3) != 0;
  void _reverse15Minites() => bitMap ^= 1 << 3;

  bool get _is30Minites => bitMap & (1 << 4) != 0;
  void _reverse30Minites() => bitMap ^= 1 << 4;

  bool get _isHour => bitMap & (1 << 5) != 0;
  void _reverseHour() => bitMap ^= 1 << 5;

  bool get _is2Hour => bitMap & (1 << 6) != 0;
  void _reverse2Hour() => bitMap ^= 1 << 6;

  bool get _isDay => bitMap & (1 << 7) != 0;
  void _reverseDay() => bitMap ^= 1 << 7;

  bool get _isWeek => bitMap & (1 << 8) != 0;
  void _reverseWeek() => bitMap ^= 1 << 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.times,
            color: Color(0xFFD7CAFF),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '设置提醒',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '完成',
              style: TextStyle(fontSize: 16.0, color: Color(0xFFEDE7FF)),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          padding: const EdgeInsets.only(top: 15.0, bottom: 50.0),
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.solidCircle,
                  color: Color(0xFFFAB807),
                  size: 8,
                ),
                const SizedBox(
                  width: 11.5,
                ),
                const Text(
                  '准时提醒',
                  style: TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            FlippingTile(
              title: '活动开始时',
              selected: _isRightTime,
              onTap: () {
                setState(() {
                  _reverseRightTime();
                });
              },
            ),
            const SizedBox(
              height: 45.0,
            ),
            Row(
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.solidCircle,
                  color: Color(0xFFFAB807),
                  size: 8,
                ),
                const SizedBox(
                  width: 11.5,
                ),
                const Text(
                  '活动开始前分钟数',
                  style: TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Column(
              children: <Widget>[
                Container(
                  height: 60.0,
                  child: Row(
                    children: <Widget>[
                      _buildMiniteTile(5,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                          )),
                      const VerticalDivider(
                        width: 0.0,
                        color: const Color(0xFFD7CAFF),
                        thickness: 0.1,
                      ),
                      _buildMiniteTile(10,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.0),
                          )),
                    ],
                  ),
                ),
                const Divider(
                  height: 0.0,
                  color: const Color(0xFFD7CAFF),
                  thickness: 0.1,
                ),
                Container(
                  height: 60.0,
                  child: Row(
                    children: <Widget>[
                      _buildMiniteTile(15,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                          )),
                      const VerticalDivider(
                        width: 0.0,
                        color: const Color(0xFFD7CAFF),
                        thickness: 0.1,
                      ),
                      _buildMiniteTile(30,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10.0),
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 45.0,
            ),
            Row(
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.solidCircle,
                  color: Color(0xFFFAB807),
                  size: 8,
                ),
                const SizedBox(
                  width: 11.5,
                ),
                const Text(
                  '活动开始前更长时间',
                  style: TextStyle(color: Color(0xFFEDE7FF), fontSize: 15.0),
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Column(
              children: <Widget>[
                FlippingTile.custom(
                  selected: _isHour,
                  builder: (context, color, textColor) {
                    return Container(
                      height: 60.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          )),
                      child: Text(
                        '1小时',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  },
                  onTap: () {
                    setState(() {
                      _reverseHour();
                    });
                  },
                ),
                const Divider(
                  height: 0.0,
                  color: const Color(0xFFD7CAFF),
                  thickness: 0.1,
                ),
                FlippingTile.custom(
                  selected: _is2Hour,
                  builder: (context, color, textColor) {
                    return Container(
                      height: 60.0,
                      alignment: Alignment.center,
                      color: color,
                      child: Text(
                        '2小时',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  },
                  onTap: () {
                    setState(() {
                      _reverse2Hour();
                    });
                  },
                ),
                const Divider(
                  height: 0.0,
                  color: const Color(0xFFD7CAFF),
                  thickness: 0.1,
                ),
                FlippingTile.custom(
                  selected: _isDay,
                  builder: (context, color, textColor) {
                    return Container(
                      height: 60.0,
                      alignment: Alignment.center,
                      color: color,
                      child: Text(
                        '1天',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  },
                  onTap: () {
                    setState(() {
                      _reverseDay();
                    });
                  },
                ),
                const Divider(
                  height: 0.0,
                  color: const Color(0xFFD7CAFF),
                  thickness: 0.1,
                ),
                FlippingTile.custom(
                  selected: _isWeek,
                  builder: (context, color, textColor) {
                    return Container(
                      height: 60.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          )),
                      child: Text(
                        '1周',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  },
                  onTap: () {
                    setState(() {
                      _reverseWeek();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniteTile(int minites, {BorderRadius borderRadius}) {
    var selected;
    var callback;
    switch (minites) {
      case 5:
        selected = _is5Minites;
        callback = _reverse5Minites;
        break;
      case 10:
        selected = _is10Minites;
        callback = _reverse10Minites;
        break;
      case 15:
        selected = _is15Minites;
        callback = _reverse15Minites;
        break;
      case 30:
        selected = _is30Minites;
        callback = _reverse30Minites;
        break;
      default:
        throw FlutterError('Unsupported reminder minits.');
    }
    return Expanded(
      child: FlippingTile.custom(
        selected: selected,
        builder: (context, color, textColor) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
            ),
            child: Text(
              '$minites',
              style: TextStyle(color: textColor),
            ),
          );
        },
        onTap: () {
          setState(() {
            callback();
          });
        },
      ),
    );
  }
}

_buildRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) => child,
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, anim1, anim2, child) {
      final anim1Curved = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic),
      );
      return FractionalTranslation(
        translation: Offset(0.0, 1 - anim1Curved.value),
        child: Opacity(
          opacity: anim1Curved.value,
          child: child,
        ),
      );
    },
  );
}