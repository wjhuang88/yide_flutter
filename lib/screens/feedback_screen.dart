import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dotted_border/dotted_border.dart';

class FeedbackScreen extends StatelessWidget {

  static const String routeName = 'feedback';
  static Route get pageRoute => _buildRoute();

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
            FontAwesomeIcons.chevronLeft,
            color: Color(0xFFD7CAFF),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '提交',
              style: TextStyle(fontSize: 16.0, color: Color(0xFFEDE7FF)),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 26.0),
        child: ListView(
          children: <Widget>[
            TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
              autofocus: true,
              maxLines: 8,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14.5),
                border: InputBorder.none,
                hintText: '说说你想反馈的内容吧',
                hintStyle: const TextStyle(color: Color(0xFF9B7FE9))
              ),
            ),
            Container(
              height: 30.0,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 14.5,),
                  FlatButton.icon(
                    icon: const Icon(FontAwesomeIcons.plus, size: 12.0, color: Color(0xFFFAB807),),
                    label: const Text('问题', style: TextStyle(fontSize: 12.0),),
                    textColor: const Color(0xFFD7C7F3),
                    shape: const StadiumBorder(side: BorderSide(color: Color(0xFFD7C7F3))),
                    onPressed: () {},
                  ),
                  SizedBox(width: 14.5,),
                  FlatButton.icon(
                    icon: Icon(FontAwesomeIcons.plus, size: 12.0, color: Color(0xFFFAB807),),
                    label: const Text('建议', style: TextStyle(fontSize: 12.0),),
                    textColor: const Color(0xFFD7C7F3),
                    shape: const StadiumBorder(side: BorderSide(color: Color(0xFFD7C7F3))),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 14.5, top: 28.0),
              child: DottedBorder(
                color: const Color(0xFFBB7FFF),
                strokeWidth: 0.5,
                dashPattern: [4, 3],
                padding: EdgeInsets.zero,
                borderType: BorderType.RRect,
                radius: Radius.circular(5),
                child: Container(
                  height: 75.0,
                  width: 75.0,
                  alignment: Alignment.center,
                  child: Stack(
                    children: <Widget>[
                      const Icon(FontAwesomeIcons.camera, color: Color(0x99FFFFFF), size: 30.0,),
                      Transform.translate(
                        offset: Offset(20.0, 0.0),
                        child: const Icon(FontAwesomeIcons.plus, color: Color(0xFFFAB807), size: 13.0,),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

_buildRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) {
      return Container(
        decoration: const BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8346C8), Color(0xFF523F88)]),
        ),
        child: FeedbackScreen(),
      );
    },
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, anim1, anim2, child) {
      final anim1Curved = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );
      return Opacity(
        opacity: anim1Curved.value,
        child: child,
      );
    },
  );
}