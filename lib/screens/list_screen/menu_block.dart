import 'package:flutter/material.dart';

class MenuBlock extends StatefulWidget {
  MenuBlock({
    @required this.title,
    @required this.iconData,
    this.actived = false,
    this.first = false,
    this.last = false,
  });

  final String title;
  final IconData iconData;
  final bool actived;
  final bool first;
  final bool last;

  @override
  _MenuBlockState createState() => _MenuBlockState(title, iconData, actived, first, last);
}

class _MenuBlockState extends State<MenuBlock> {

  _MenuBlockState(
    this.title,
    this.iconData,
    [this.actived = false,
    this.first = false,
    this.last = false]
  );

  String title;
  IconData iconData;
  bool actived;
  bool first;
  bool last;

  @override
  Widget build(BuildContext context) {
    var marginLeft = first ? 20.0 : 10.0;
    var marginRight = last ? 20.0 : 0.0;

    Color backgroundColor, textColor;
    if (actived) {
      backgroundColor = const Color(0xffffc400);
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white;
      textColor = const Color(0xff0a2453);
    }

    return Container(
      width: 160,
      margin: EdgeInsets.only(left: marginLeft, right: marginRight),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(iconData, color: textColor, size: 22,),
          SizedBox(height: 15,),
          Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

