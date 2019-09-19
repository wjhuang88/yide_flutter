import 'package:flutter/material.dart';

class NewTaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          //backgroundColor: Color(0xff262626),
          elevation: 0.0,
        ),
        preferredSize: Size.fromHeight(50),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Center(
              child: Text('没有任务！', style: TextStyle(color: Colors.black, fontSize: 25),)
            )
          ),
          Positioned(
            child: Container(
              child: Center(child: Text('+', style: TextStyle(color: Colors.white, fontSize: 30),),),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[400],
                boxShadow: [BoxShadow(
                  color: Colors.grey[400],
                  spreadRadius: 3.0,
                  blurRadius: 3.0
                )]
              ),
            ),
            bottom: 50,
            right: 30,
          )
        ],
      )
    );
  }

}