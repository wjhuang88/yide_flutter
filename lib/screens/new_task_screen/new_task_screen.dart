import 'package:flutter/material.dart';

import '../list_screen/edit_page.dart';

class NewTaskScreen extends StatelessWidget {

  static const headerHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff161a37),
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Color(0xff161a37),
          elevation: 0.0,
          brightness: Brightness.dark,
          automaticallyImplyLeading: false,
          leading: _buildBackButton(context),
          actions: <Widget>[
            _buildComfirmButton(context),
            SizedBox(width: 10,)
          ],
        ),
        preferredSize: Size.fromHeight(headerHeight),
      ),
      body: Stack(
        children: <Widget>[
          Hero(
            child: EditPage(isOpened: true,),
            tag: 'bottom_bar',
            flightShuttleBuilder: (context, anim, dir, from, to) => Container(
              height: 40,
              margin: EdgeInsets.fromLTRB(20, 30, 20, 30),
              decoration: BoxDecoration(
                  color: Color(0xfff6f7f7),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
          ),
        ],
      )
    );
  }

}

Widget _buildBackButton(BuildContext context) {
  return BackButton(
    color: Colors.white,
  );
}

Widget _buildComfirmButton(BuildContext context) {
  return IconButton(
    icon: Icon(Icons.done),
    color: Colors.white,
    iconSize: 30,
    tooltip: 'Done',
    onPressed: () {},
  );
}