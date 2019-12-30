import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yide/src/components/header_bar.dart';
import 'package:yide/src/components/native_textfield.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/notification.dart';

class DetailCommentsScreen extends StatefulWidget implements Navigatable {
  DetailCommentsScreen({Key key, this.value}) : super(key: key);

  final String value;

  @override
  _DetailCommentsScreenState createState() => _DetailCommentsScreenState();

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

  @override
  String get name => '备注';
}

class _DetailCommentsScreenState extends State<DetailCommentsScreen> {
  NativeTextFieldController _controller = NativeTextFieldController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: Column(
        children: <Widget>[
          HeaderBar(
            leadingIcon: const Icon(
              CupertinoIcons.clear,
              color: Color(0xFFD7CAFF),
              size: 40.0,
            ),
            onLeadingAction: () {
              _controller.unfocus();
              PopRouteNotification().dispatch(context);
            },
            actionIcon: const Text(
              '完成',
              style: const TextStyle(
                  fontSize: 15.0, color: const Color(0xFFEDE7FF)),
            ),
            onAction: () {
              _controller.unfocus();
              PopRouteNotification(result: _controller.text).dispatch(context);
            },
            title: widget.name,
          ),
          Container(
            margin: const EdgeInsets.only(top: 40.0, left: 15.0, right: 15.0),
            child: NativeTextField(
              autofocus: true,
              text: widget.value,
              height: 200.0,
              controller: _controller,
              onSubmitted: (text) =>
                  PopRouteNotification(result: text).dispatch(context),
              placeholder: '请输入内容',
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }
}
