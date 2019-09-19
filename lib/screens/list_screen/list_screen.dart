import 'package:flutter/material.dart';
import '../../weather_icons.dart';

class ListScreen extends StatelessWidget {

  buildScaffold() {
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          leading: _LeadingButton(),
          title: _TitleView(),
          flexibleSpace: FlexibleSpaceBar(
            title: _SearchBar(),
          ),
        ),
        preferredSize: Size.fromHeight(120),
      ),
      body: _ListBody(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: buildScaffold(),
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }
}

class _LeadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return IconButton(
      icon: Icon(
        Icons.menu
      ), 
      onPressed: () {},
    );
  }

}

class _TitleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: <Widget>[
        Icon(
          WeatherIcons.sun,
          color: Color(0xffffc400),
          size: 25,
        ),
        Container(
          child: Text('周三', style: TextStyle(fontSize: 16)),
          margin: EdgeInsets.only(left: 10),
        ),
        Container(
          child: Text('9月18日', style: TextStyle(fontSize: 16)),
          margin: EdgeInsets.only(left: 10),
        )
      ],
    );
  }

}

class _SearchBar extends StatelessWidget {

  buildTextField() {
    return TextField(
      decoration: InputDecoration(
        icon: Icon(Icons.search, color: Color(0xffe5e5e5),size: 30,),
        hintText: '搜索',
        hintStyle: TextStyle(color: Color(0xffe5e5e5)),
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      child: buildTextField(),
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Color(0xfff6f7f7f7)
      ),
    );
  }

}

class _ListBody extends StatelessWidget {

  static const headStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xff0a2453)
  );

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text('筛选', style: headStyle),
            padding: EdgeInsets.only(left: 20),
          ),
          constructMenuRow(),
          Container(
            child: Text('今日', style: headStyle),
            padding: EdgeInsets.only(left: 20),
          ),
          constructList(),
          buildBottomBar()
        ],
      ),
    );
  }

  constructMenuRow() {
    return Container(
      height: 150,
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          buildMenuBlock('收集箱', Icons.inbox, first: true),
          buildMenuBlock('今日', Icons.star, actived: true),
          buildMenuBlock('计划', Icons.calendar_today),
          buildMenuBlock('随时', Icons.folder_open),
          buildMenuBlock('某天', Icons.archive, last: true),
        ],
      ),
    );
  }

  buildMenuBlock(String title, IconData iconData, {
    bool actived = false,
    bool first = false,
    bool last = false
  }) {

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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Icon(iconData, color: textColor, size: 30,),
            margin: EdgeInsets.only(top: 20, left: 20),
          ),
          Container(
            child: Text(title, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
            margin: EdgeInsets.only(top: 15, left: 20),
          )
        ],
      ),
    );
  }

  constructList() {

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
                    color: Color(0xff0a2453)
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

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 10),
        child: ListView(
          children: list,
        ),
      )
    );
  }

  buildBottomBar() {
    return Stack(
      children: <Widget>[
        Container(
          color: Color(0x55000000),
          height: 100,
        )
      ],
    );
  }

}