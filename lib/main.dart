import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text('left', textDirection: TextDirection.ltr),
          ),
          Container(
            child: Text('right', textDirection: TextDirection.ltr),
            color: Color(0xffffffff),
            height: 100.0,
          )
        ],
        textDirection: TextDirection.ltr
      )
    );
  }
}

