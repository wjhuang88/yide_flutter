import 'package:flutter/material.dart';

class ListToday extends StatefulWidget {
  @override
  _ListToday createState() => _ListToday();
}

class _ListToday extends State<ListToday> {

  @override
  Widget build(BuildContext context) {
    
    return _constructList();
  }

  Widget _constructList() {

    var list = <Widget>[];

    for (var i = 0; i < 5; i ++) {
      list.add(
        Container(
          margin: EdgeInsets.only(top: 10, left: 20, right: 20),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  '我要做一件事，我要做一件事我要做一件事，我要做一件事我要做一件事。', 
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff161a37)
                  ),
                  softWrap: true,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.alarm, color: Colors.grey[400], size: 18,),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        '2019/10/1',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400]
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      );
    }

    return ListView(
      children: list,
    );
  }
}

