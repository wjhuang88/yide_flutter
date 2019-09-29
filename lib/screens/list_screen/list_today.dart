import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ListToday extends StatefulWidget {
  @override
  _ListToday createState() => _ListToday();
}

class _ListToday extends State<ListToday> {
  @override
  Widget build(BuildContext context) {
    return _constructList(context);
  }
}

Widget _constructList(BuildContext context) {

  return ListView.builder(
    itemCount: 20,
    itemBuilder: (context, index) {
      return _buildListTile(context,
        key: index.toString(),
        title: '我要做一件事，我要做一件事我要做一件事，我要做一件事我要做一件事。',
        date: '2019/10/1');
    },
  );
}

Widget _buildListTile(BuildContext context,
    {@required String key, String title = '', String date = '无日期'}) {
  return Container(
    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Color(0xffe5e5e5),
          blurRadius: 10,
        ),
      ],
    ),
    child: Slidable(
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      key: Key(key),
      actions: <Widget>[
        Container(
          height: double.infinity,
          margin: EdgeInsets.fromLTRB(0, 15, 10, 15),
          decoration: BoxDecoration(
            color: Color(0xff00ab9d),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: IconButton(
            icon: Icon(Icons.done, color: Colors.white,),
            onPressed: () {print('done ' + key);},
          ),
        ),
      ],
      secondaryActions: <Widget>[
        Container(
          height: double.infinity,
          margin: EdgeInsets.fromLTRB(10, 15, 0, 15),
          decoration: BoxDecoration(
            color: Color(0xff26c7ff),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white,),
            onPressed: () {print('select ' + key);},
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Color(0xff161a37)),
              softWrap: true,
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.alarm,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(
                      date,
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}
