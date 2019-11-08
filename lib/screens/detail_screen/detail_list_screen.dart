import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailListScreen extends StatelessWidget {

  static const String routeName = 'detail_list';
  static Route get pageRoute => _buildRoute(DetailListScreen());

  @override
  Widget build(BuildContext context) {
    final subTitleStyle = const TextStyle(
      color: Color(0xffbdaee8),
      fontSize: 14.0,
    );

    final contentStyle = const TextStyle(
      color: Color(0xfff4f3f8),
    );

    return Scaffold(
      backgroundColor: const Color(0xff5a4791),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: const Color(0xff5a4791),
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowAltCircleLeft, color: Color(0xffbdaee8),),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(FontAwesomeIcons.trashAlt, color: Color(0xffbdaee8), size: 22.0,),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _buildColumnBlock(
            color: const Color(0xff5a4791),
            padding: const EdgeInsets.only(bottom: 30.0),
            children: <Widget>[
              Text('2.8.0项目改版', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xfff4f3f8), fontSize: 22.0),),
              Text('备注', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xffbdaee8)),),
            ],
          ),

          _buildColumnBlock(
            color: const Color(0xff554389),
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            children: <Widget>[
              Text('时间', textAlign: TextAlign.center, style: subTitleStyle,),
              Transform.translate(
                offset: const Offset(0.0, -5.0),
                child: const Icon(FontAwesomeIcons.minus, color: Color(0xffefd72d), size: 16.0,),
              ),
              Text('10/11 9:00 - 10/30 18:00', textAlign: TextAlign.center, style: contentStyle,),
            ],
          ),

          _buildColumnBlock(
            color: const Color(0xff5a4791),
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            children: <Widget>[
              Text('提醒', textAlign: TextAlign.center, style: subTitleStyle,),
              Transform.translate(
                offset: Offset(0.0, -5.0),
                child: const Icon(FontAwesomeIcons.minus, color: Color(0xffefd72d), size: 16.0,),
              ),
              Text('开始提醒', textAlign: TextAlign.center, style: contentStyle,),
            ],
          ),

          _buildColumnBlock(
            color: const Color(0xff554389),
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            children: <Widget>[
              Text('频次', textAlign: TextAlign.center, style: subTitleStyle,),
              Transform.translate(
                offset: Offset(0.0, -5.0),
                child: const Icon(FontAwesomeIcons.minus, color: Color(0xffefd72d), size: 16.0,),
              ),
              Text('每周重复', textAlign: TextAlign.center, style: contentStyle,),
            ],
          ),

          _buildColumnBlock(
            color: const Color(0xff5a4791),
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            children: <Widget>[
              Text('地点', textAlign: TextAlign.center, style: subTitleStyle,),
              Transform.translate(
                offset: Offset(0.0, -5.0),
                child: const Icon(FontAwesomeIcons.minus, color: Color(0xffefd72d), size: 16.0,),
              ),
              Text('人民广场', textAlign: TextAlign.center, style: contentStyle,),
            ],
          ),

          _buildColumnBlock(
            color: const Color(0xff554389),
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            children: <Widget>[
              Text('项目', textAlign: TextAlign.center, style: subTitleStyle,),
              Transform.translate(
                offset: Offset(0.0, -5.0),
                child: const Icon(FontAwesomeIcons.minus, color: Color(0xffefd72d), size: 16.0,),
              ),
              Text('所属项目', textAlign: TextAlign.center, style: contentStyle,),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildColumnBlock({
    List<Widget> children,
    Color color,
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return Container(
      color: color,
      margin: margin,
      padding: padding,
      child: Column(
        children: children,
      ),
    );
  }
}

_buildRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) => child,
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: anim1,
            curve: Cubic(0,1,.55,1),
          ),
        ),
        child: child,
      );
    },
  );
}