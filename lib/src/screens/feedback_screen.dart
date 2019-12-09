import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/interfaces/navigatable.dart';

class FeedbackScreen extends StatelessWidget implements Navigatable {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: Column(
        children: <Widget>[
          HeaderBar(
            leadingIcon: const Icon(
              CupertinoIcons.left_chevron,
              color: Color(0xFFD7CAFF),
              size: 30.0,
            ),
            onLeadingAction: Navigator.of(context).maybePop,
            actionIcon: const Text(
              '提交',
              style: const TextStyle(
                  fontSize: 15.0, color: const Color(0xFFEDE7FF)),
            ),
            onAction: () {},
            title: '设置重复',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 26.0),
              children: <Widget>[
                CupertinoTextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14.0),
                  autofocus: true,
                  maxLines: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 14.5),
                  placeholder: '说说你想反馈的内容吧',
                  placeholderStyle: const TextStyle(color: Color(0xFF9B7FE9)),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                Container(
                  height: 30.0,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 14.5,
                      ),
                      FlatButton.icon(
                        icon: const Icon(
                          CupertinoIcons.add,
                          size: 20.0,
                          color: Color(0xFFFAB807),
                        ),
                        label: const Text(
                          '问题',
                          style: TextStyle(fontSize: 12.0),
                        ),
                        textColor: const Color(0xFFD7C7F3),
                        shape: const StadiumBorder(
                            side: BorderSide(color: Color(0xFFD7C7F3))),
                        onPressed: () {},
                      ),
                      SizedBox(
                        width: 14.5,
                      ),
                      FlatButton.icon(
                        icon: Icon(
                          CupertinoIcons.add,
                          size: 20.0,
                          color: Color(0xFFFAB807),
                        ),
                        label: const Text(
                          '建议',
                          style: TextStyle(fontSize: 12.0),
                        ),
                        textColor: const Color(0xFFD7C7F3),
                        shape: const StadiumBorder(
                            side: BorderSide(color: Color(0xFFD7C7F3))),
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
                          const Icon(
                            CupertinoIcons.photo_camera,
                            color: Color(0x99FFFFFF),
                            size: 45.0,
                          ),
                          Transform.translate(
                            offset: Offset(25.0, 0.0),
                            child: const Icon(
                              CupertinoIcons.add,
                              color: Color(0xFFFAB807),
                              size: 22.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) {
        return Container(
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8346C8), Color(0xFF523F88)]),
          ),
          child: this,
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
}
