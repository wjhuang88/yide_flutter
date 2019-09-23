import 'dart:ui';

import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  EditPage({this.isOpened = false});

  final bool isOpened;

  @override
  _EditPageState createState() => _EditPageState(isOpened);
}

class _EditPageState extends State<EditPage> with SingleTickerProviderStateMixin {
  _EditPageState(this.isOpened);

  Animation<double> animation;            
  AnimationController controller;
  bool isOpened;
  bool showEditArea = false;

  @override            
  void initState() {            
    super.initState();  
    if (isOpened) {
      controller =            
          AnimationController(duration: const Duration(milliseconds: 500), vsync: this);            
      animation = CurvedAnimation(
        parent: controller,
        curve: Cubic(.93, .21, .05, .89),
      )..addListener(() {            
        setState(() {            
          // The state that has changed here is the animation object’s value.            
        });            
      })..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          showEditArea = true;
        } else if (state == AnimationStatus.dismissed) {
          showEditArea = false;
        }
      });            
      controller.forward();
    }        
  }

  @override
  void dispose() {
    controller?.dispose();
    isOpened = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var heightScreen = MediaQuery.of(context).size.height;
    var heightCalc = isOpened ? lerpDouble(40, heightScreen, animation.value) : 40.0;
    var marginCalc = isOpened ? lerpDouble(20.0, 0.0, animation.value) : 20.0;
    var marginCalcTopDown = isOpened ? lerpDouble(30.0, 0.0, animation.value) : 30.0;

    return Container(
      decoration: BoxDecoration(
          color: Color(0xff161a37),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Stack(
        alignment: isOpened ? Alignment.topCenter : Alignment.center,
        children: <Widget>[
          Positioned(
            height: 4,
            width: 90,
            top: 10,
            child: Offstage(
              offstage: isOpened,
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xfff6f7f7),
                    borderRadius: BorderRadius.all(Radius.circular(2))),
              ),
            ),
          ),
          Container(
            height: isOpened ? lerpDouble(40, heightCalc, animation.value) : 40,
            margin: EdgeInsets.fromLTRB(marginCalc, marginCalcTopDown, marginCalc, marginCalcTopDown),
            decoration: BoxDecoration(
                color: Color(0xfff6f7f7),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Center(
              child: Stack(
                children: <Widget>[
                  Offstage(
                    offstage: isOpened,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add_box,
                          color: Color(0xff161a37),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '新建代办事项',
                          style: TextStyle(color: Color(0xff161a37), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Offstage(
                    child: _buildEditArea(context),
                    offstage: !showEditArea,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildEditArea(BuildContext context) {
  return Container(
    margin: EdgeInsets.all(30),
    child: ListView(
      children: <Widget>[
        TextField(
          maxLines: null,
          decoration: InputDecoration(
            hintText: '任务',
            hintStyle: TextStyle(color: Color(0xffe5e5e5), fontSize: 20, fontWeight: FontWeight.w500,),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Color(0xff161a37), fontSize: 20, fontWeight: FontWeight.w700,),
        ),
        TextField(
          maxLines: null,
          decoration: InputDecoration(
            hintText: '备注',
            hintStyle: TextStyle(color: Color(0xffe5e5e5), fontSize: 16, fontWeight: FontWeight.w500,),
            border: InputBorder.none,
          ),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff999999)),
        ),
        SizedBox(height: 10,),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xffe5e5e5),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.calendar_today, size: 20,),
              SizedBox(width: 10,),
              Expanded(child: Text('日期')),
              Icon(Icons.arrow_right),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xffe5e5e5),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.alarm, size: 20,),
              SizedBox(width: 10,),
              Expanded(child: Text('提醒')),
              Icon(Icons.arrow_right),
            ],
          ),
        ),
      ],
    ),
  );
}