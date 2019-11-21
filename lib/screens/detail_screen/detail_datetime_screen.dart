import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailDateTimeScreen extends StatelessWidget {
  static const String routeName = 'detail_datetime';
  static Route get pageRoute => _buildRoute(DetailDateTimeScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8346C8),
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
        title: Text('设置日期', style: TextStyle(fontSize: 18.0, color: Colors.white),),
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
        height: 300.0,
        margin: const EdgeInsets.only(top: 100.0),
        child: CupertinoTheme(
          data: const CupertinoThemeData(
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 21,)
            ),
          ),
          child: CupertinoDatePicker(
            backgroundColor: const Color(0xFF8346C8),
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (date) {
              print(date);
            },
          ),
        ),
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
        ),
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
