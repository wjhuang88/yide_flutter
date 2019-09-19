import 'package:flutter/material.dart';

class SideTimeline extends StatelessWidget {
  SideTimeline({this.width, this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {

    if (this.width <= 0) {
      return Container();
    }

    var elements = <Widget>[];
    var data = ["9:12", "10:15", "12:00"];
    var len = data.length;
    for (var i = 0; i < len; i++) {
      var w = (len / 2).floor();
      var size = 35 - (w - i).abs() * 9 / w;
      print(size);
      elements.add(
        Expanded(
          flex: (size * size).toInt() ,
          child: Center(
            child: Text(
              data[i], 
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: size
              ),
            )
          ),
        )
      );
    }

    return Container(
          width: this.width,
          child: Container(
            child: Center(
              child: Column(
                children: elements,
              ),
            ),
            color: this.color,
          ),
        );
  }
}