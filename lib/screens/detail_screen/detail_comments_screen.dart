import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/interfaces/navigatable.dart';

class DetailCommentsScreen extends StatelessWidget implements Navigatable {
  final TextEditingController _controller;

  DetailCommentsScreen({Key key, String value})
      : _controller = TextEditingController(text: value),
        super(key: key);

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
          '备注',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '完成',
              style: TextStyle(fontSize: 16.0, color: Color(0xFFEDE7FF)),
            ),
            onPressed: () => Navigator.of(context).maybePop<String>(_controller.text),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 50.0),
        child: TextField(
          style: const TextStyle(color: Colors.white, fontSize: 14.0),
          autofocus: true,
          maxLines: null,
          controller: _controller,
          keyboardType: TextInputType.text,
          keyboardAppearance: Brightness.dark,
          textInputAction: TextInputAction.done,
          onSubmitted: (text) => Navigator.of(context).maybePop<String>(text),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
              border: InputBorder.none,
              hintText: '请输入内容',
              hintStyle: const TextStyle(color: Color(0xFF9B7FE9))),
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
}
