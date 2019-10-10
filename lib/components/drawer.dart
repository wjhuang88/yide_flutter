import 'package:flutter/material.dart';

@deprecated
class ListDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(15),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: Color(0xff161a37)),
                      image: DecorationImage(
                        image: AssetImage('assets/images/user.jpg'),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '名字',
                        style:
                            TextStyle(fontSize: 20, color: Color(0xff161a37)),
                      ),
                      Text(
                        '已完成 8 项任务',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xffaaaaaa)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            _buildTile(context, title: '收集箱', iconData: Icons.inbox),
            _buildTile(context,
                title: '今日', iconData: Icons.star, selected: true),
            _buildTile(context, title: '计划', iconData: Icons.assignment),
            _buildTile(context, title: '随时', iconData: Icons.widgets),
            _buildTile(context, title: '某天', iconData: Icons.archive),
            Divider(),
            _buildTile(context, title: '项目', iconData: Icons.folder, onTap: () => Navigator.pushNamed(context, 'project_list')),
            _buildTile(context, title: '标签', iconData: Icons.local_offer),
          ],
        ),
      ),
    );
  }
}

Widget _buildTile(BuildContext context,
    {String title,
    IconData iconData,
    bool selected = false,
    int value = 0,
    void Function() onTap}) {
  return Container(
    margin: EdgeInsets.only(left: 15, right: 15),
    height: 60,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: selected ? Color(0xffffc400) : Colors.transparent,
    ),
    child: ListTile(
      leading:
          Icon(iconData, color: !selected ? Color(0xff161a37) : Colors.white),
      trailing: Text(
        value.toString(),
        style: TextStyle(
            color: !selected ? Color(0xff161a37) : Colors.white, fontSize: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
            color: !selected ? Color(0xff161a37) : Colors.white, fontSize: 18),
      ),
      onTap: onTap ??
          () {
            Navigator.pop(context);
          },
    ),
  );
}
