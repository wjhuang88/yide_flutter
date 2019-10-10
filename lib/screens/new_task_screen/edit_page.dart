import 'dart:ui';

import 'package:flutter/material.dart';

@deprecated
class EditPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Color(0xfff6f7f7),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      ),
      child: _buildEditArea(context),
    );
  }
}

Widget _buildEditArea(BuildContext context) {
  const headStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Color(0xff0a2453)
  );

  return ClipRRect(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
    child: ListView(
      children: <Widget>[
        const SizedBox(height: 30,),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: const Text('内容', style: headStyle,),
        ),
        const SizedBox(height: 20,),
        Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(15, 7, 15, 7),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '任务',
                    hintStyle: TextStyle(color: Color(0xffe5e5e5), fontSize: 16, fontWeight: FontWeight.w500,),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Color(0xff161a37), fontSize: 16, fontWeight: FontWeight.w700,),
                ),
              ),
              Divider(thickness: 2, color: Color(0xfff6f7f7), height: 2,),
              Container(
                padding: EdgeInsets.fromLTRB(15, 7, 15, 7),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '备注',
                    hintStyle: TextStyle(color: Color(0xffe5e5e5), fontSize: 16, fontWeight: FontWeight.w500,),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff999999)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: const Text('时间', style: headStyle,),
        ),
        const SizedBox(height: 20,),
        Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.calendar_today, size: 20,),
                    SizedBox(width: 10,),
                    Expanded(child: const Text('日期')),
                    Icon(Icons.arrow_right),
                  ],
                ),
              ),
              Divider(thickness: 2, color: Color(0xfff6f7f7), height: 2,),
              Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.alarm, size: 20,),
                    SizedBox(width: 10,),
                    Expanded(child: const Text('提醒')),
                    Icon(Icons.arrow_right),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: const Text('检查项', style: headStyle,),
        ),
        const SizedBox(height: 20,),
        Container(
          color: Colors.white,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildCheckoutItem(context, 'data', first: true),
                _buildCheckoutItem(context, 'data'),
                _buildCheckoutItem(context, 'data'),
                _buildCheckoutItem(context, 'data'),
                _buildCheckoutItem(context, 'data'),
                Divider(thickness: 2, color: Color(0xfff6f7f7), height: 2,),
                Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      child: const Text('添加检查项'),
                      onPressed: () {
                        print('object');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Container(
          margin: EdgeInsets.only(left: 15, right: 15),
          child: FlatButton(
            child: const Text('保存'),
            shape: StadiumBorder(),
            color: Color(0xffffc400),
            textColor: Colors.white,
            onPressed: () {
              print('object');
            },
          ),
        )
      ],
    ),
  );
}

Widget _buildCheckoutItem(BuildContext context, String text, {bool first = false}) {
  return Container(
    padding: EdgeInsets.fromLTRB(15, first ? 15 : 7, 15, 7),
    child: Row(
      children: <Widget>[
        Checkbox(
          onChanged: (bool value) {}, 
          value: false,
        ),
        Text(text),
      ],
    ),
  );
}