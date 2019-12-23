import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/config.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/notification.dart';

class DetailCommentsScreen extends StatelessWidget implements Navigatable {
  final TextEditingController _controller;

  DetailCommentsScreen({Key key, String value})
      : _controller = TextEditingController(text: value),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: backgroundGradient
        ),
        child: Column(
          children: <Widget>[
            HeaderBar(
              leadingIcon: const Icon(
                CupertinoIcons.clear,
                color: Color(0xFFD7CAFF),
                size: 40.0,
              ),
              onLeadingAction: () => PopRouteNotification().dispatch(context),
              actionIcon: const Text(
                '完成',
                style: const TextStyle(
                    fontSize: 15.0, color: const Color(0xFFEDE7FF)),
              ),
              onAction: () => PopRouteNotification(result: _controller.text).dispatch(context),
              title: '备注',
            ),
            Container(
              margin: const EdgeInsets.only(top: 50.0),
              child: CupertinoTextField(
                style: const TextStyle(color: Colors.white, fontSize: 14.0),
                autofocus: true,
                maxLines: null,
                controller: _controller,
                keyboardType: TextInputType.text,
                keyboardAppearance: Brightness.dark,
                textInputAction: TextInputAction.done,
                onSubmitted: (text) => Navigator.of(context).maybePop<String>(text),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                placeholder: '请输入内容',
                placeholderStyle: const TextStyle(color: Color(0xFF9B7FE9)),
                decoration: BoxDecoration(
                  color: Colors.transparent
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Route get route {
    return PageRouteBuilder<String>(
      pageBuilder: (context, anim1, anim2) => this,
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

  @override
  bool get withMene => false;
}
