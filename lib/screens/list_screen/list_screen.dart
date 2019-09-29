import 'package:flutter/material.dart';

import 'list_today.dart';
import 'menu_block.dart';
import '../../components/drawer.dart';
import '../../weather_icons.dart';

class ListScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return _buildScaffold(context);
  }
}

Widget _buildScaffold(BuildContext context) {
  
  return Scaffold(
    appBar: PreferredSize(
      child: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: _LeadingButton(),
        actions: <Widget>[
          _SearchButton(),
        ],
        title: _buildTitleView(),
      ),
      preferredSize: Size.fromHeight(50),
    ),
    body: _buildListBody(context),
    drawer: ListDrawer(),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Color(0xff0a2463),
      onPressed: () {
        Navigator.pushNamed(context, 'add');
      },
    ),
  );
}

class _LeadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.menu,
        color: Color(0xff161a37),
      ), 
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

class _SearchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      color: Color(0xff161a37),
      onPressed: () {},
    );
  }

}

Widget _buildTitleView() {
    
  return Row(
    children: <Widget>[
      Icon(
        WeatherIcons.sun,
        color: Color(0xffffc400),
        size: 25,
      ),
      SizedBox(width: 10,),
      Text('周三', style: TextStyle(fontSize: 16, color: Color(0xff161a37))),
      SizedBox(width: 10,),
      Text('9月18日', style: TextStyle(fontSize: 16, color: Color(0xff161a37))),
      SizedBox(width: 20,),
      // Container(
      //   height: 30,
      //   width: 30,
      //   decoration: BoxDecoration(
      //     shape: BoxShape.circle,
      //     border: Border.all(width: 1, color: Color(0xff262626)),
      //     image: DecorationImage(
      //       image: AssetImage('assets/images/user.jpg'),
      //     ),
      //   ),
      // ),
    ],
  );
}

Widget _buildListBody(BuildContext context) {

  var headStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xff0a2453)
  );
  
  return Container(
    padding: EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text('分类', style: headStyle),
          padding: EdgeInsets.only(left: 20),
        ),
        _constructMenuRow(),
        Container(
          child: Text('今日', style: headStyle),
          padding: EdgeInsets.only(left: 20),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 10),
            child: ListToday(),
          )
        ),
      ],
    ),
  );
}

Widget _constructMenuRow() {
  return Container(
    height: 130,
    padding: EdgeInsets.only(top: 20, bottom: 20),
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        MenuBlock(title: '收集箱', iconData: Icons.inbox, first: true),
        MenuBlock(title: '今日', iconData: Icons.star, actived: true),
        MenuBlock(title: '计划', iconData: Icons.assignment),
        MenuBlock(title: '随时', iconData: Icons.widgets),
        MenuBlock(title: '某天', iconData: Icons.archive, last: true),
      ],
    ),
  );
}