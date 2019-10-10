import 'package:flutter/material.dart';

import 'edit_page.dart';

@deprecated
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
          ],
        ),
        preferredSize: Size.fromHeight(headerHeight),
      ),
      body: EditPage()
    );
  }

}

Widget _buildBackButton(BuildContext context) {
  return BackButton(
    color: Colors.white,
  );
}

Widget _buildComfirmButton(BuildContext context) {
  return FlatButton(
    textColor: Color(0xffffc400),
    child: Text('保存', style: TextStyle(fontSize: 18),),
    shape: StadiumBorder(),
    onPressed: () {},
  );
}