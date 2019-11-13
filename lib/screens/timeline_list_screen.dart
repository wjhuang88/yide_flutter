import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TimelineListScreen extends StatelessWidget {
  static const String routeName = 'timeline_list';
  static Route get pageRoute => _buildRoute(TimelineListScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFAB807),
        child: const Icon(
          Icons.add,
          size: 40.0,
        ),
        onPressed: () {},
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8346C8), Color(0xFF523F88)]),
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 310.0,
              child: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                brightness: Brightness.dark,
                leading: IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.bars,
                    color: Color(0xFFD7CAFF),
                  ),
                  onPressed: () {},
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(182.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 17.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 18.0),
                    height: 182.0,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF975ED8), Color(0xFF7352D0)]),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0.0, 6.0),
                            blurRadius: 23.0,
                            color: Color(0x8A4F3A8C),
                          )
                        ]),
                    child: Stack(
                      children: <Widget>[
                        _buildHeaderColumn(),
                        Positioned(
                          right: 0.0,
                          top: 0.0,
                          child: Text('图标!'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 5.0),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(right: 23.5),
                child: const Text(
                  '7:00 AM',
                  style: const TextStyle(
                      color: Color(0xFFC9A2F5), fontSize: 12.0, fontFamily: ''),
                ),
              ),
              Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 27.5, bottom: 30.0),
                    decoration: const BoxDecoration(
                        border: Border(
                      left: BorderSide(color: Color(0xFF6F54BC)),
                    )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '早起跑步健身',
                          style: const TextStyle(
                              color: Color(0xFFD7CAFF), fontSize: 15.0),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          '生活',
                          style: const TextStyle(
                              color: Color(0xFFF0DC26), fontSize: 12.0),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          '项目名称',
                          style: const TextStyle(
                              color: Color(0xFFC9A2F5), fontSize: 12.0),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          '备注',
                          style: const TextStyle(
                              color: Color(0xFFC9A2F5), fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(-5, 2.0),
                    child: const Icon(
                      FontAwesomeIcons.solidCircle,
                      color: Color(0xFFF0DC26),
                      size: 12.0,
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Widget _buildHeaderColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '总共10件事还剩',
          style: const TextStyle(fontSize: 14.0, color: Color(0xFFDEC0FF)),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: <Widget>[
              Text(
                '5',
                style: const TextStyle(
                    fontSize: 75.0,
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w200,
                    fontFamily: ''),
              ),
              Text(
                '未完成',
                style:
                    const TextStyle(fontSize: 12.0, color: Color(0xFFFFFFFF)),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '2019.11.08',
                  style: const TextStyle(
                      fontSize: 16.0, color: Color(0xFFDEC0FF), fontFamily: ''),
                ),
                Text(
                  '星期三',
                  style:
                      const TextStyle(fontSize: 12.0, color: Color(0xFFDEC0FF)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '上海',
                  style:
                      const TextStyle(fontSize: 14.0, color: Color(0xFFDEC0FF)),
                ),
                Text(
                  '温度：20℃',
                  style:
                      const TextStyle(fontSize: 12.0, color: Color(0xFFDEC0FF)),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}

_buildRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) => child,
    transitionDuration: Duration(milliseconds: 1000),
    transitionsBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
            .animate(
          CurvedAnimation(
            parent: anim1,
            curve: Cubic(0, 1, .55, 1),
          ),
        ),
        child: child,
      );
    },
  );
}
