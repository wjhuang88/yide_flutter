import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yide/components/location_methods.dart';
import 'package:yide/components/timeline_list.dart';
import 'package:yide/interfaces/navigatable.dart';
import 'package:yide/models/date_tools.dart';
import 'package:yide/models/task_data.dart';
import 'package:yide/notification.dart';
import 'package:yide/screens/detail_screen/detail_list_screen.dart';
import 'package:yide/screens/edit_main_screen.dart';

class TimelineListScreen extends StatefulWidget implements Navigatable {
  const TimelineListScreen({Key key}) : super(key: key);

  static TimelineScreenController controller = TimelineScreenController();

  @override
  _TimelineListScreenState createState() =>
      _TimelineListScreenState(controller);

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (context, anim1, anim2, child) {
        final anim1Curved = Curves.easeOutCubic.transform(anim1.value);
        controller.updateTransition(1 - anim2.value);
        return Opacity(
          opacity: anim1Curved,
          child: Transform.scale(
            scale: 2 - anim1Curved,
            child: child,
          ),
        );
      },
    );
  }
}

class _TimelineListScreenState extends State<TimelineListScreen> {
  _TimelineListScreenState(this._controller);

  double transitionFactor;
  TimelineScreenController _controller;
  Widget _savedList;
  Widget _placeholder;
  Widget _loadingPlaceholder;

  Future<List<TaskPack>> _taskList;

  String _cityName = '-';
  String _temp;

  DateTime _dateTime = DateTime.now();

  void _updateLocAndTemp() async {
    final location = await LocationMethods.getLocation();
    var city = location.city ?? '-';
    if (city.endsWith('市')) {
      city = city.substring(0, city.length - 1);
    }
    setState(() {
      _cityName = city;
    });
    final http = HttpClient();
    final query = {
      'city': city,
      'appid': '29473577',
      'appsecret': '6BKj42FB',
      'version': 'v6'
    };
    final uri = Uri.https('www.tianqiapi.com', '/api', query);
    final request = await http.getUrl(uri);
    final response = await request.close();
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final map = jsonDecode(responseBody) as Map;
      setState(() {
        _temp = map['tem'];
      });
    } else {
      print('请求失败');
    }
  }

  @override
  void initState() {
    super.initState();
    transitionFactor = 0.0;
    _controller ??= TimelineScreenController();

    _savedList = _placeholder = Container();
    _loadingPlaceholder = Center(
      child: SpinKitCircle(
        color: Colors.blue,
        size: 70.0,
      ),
    );

    _taskList = getTaskList(null);
    _updateLocAndTemp();

    _controller._state = this;
  }

  @override
  void dispose() {
    _controller._state = null;
    super.dispose();
  }

  void _updateTransition(double value) {
    setState(() {
      this.transitionFactor = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (transitionFactor).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Offstage(
        offstage: opacity < 1.0,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFFAB807),
          child: const Icon(
            Icons.add,
            size: 40.0,
          ),
          onPressed: () {
            Navigator.push(context, EditMainScreen().route);
          },
        ),
      ),
      body: Opacity(
        opacity: opacity,
        child: Column(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: Container(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  icon: const Icon(
                    FontAwesomeIcons.bars,
                    color: Color(0xFFD7CAFF),
                  ),
                  onPressed: () {
                    AppNotification("open_menu").dispatch(context);
                  },
                ),
              ),
            ),
            FractionalTranslation(
              translation: Offset(0.0, transitionFactor - 1),
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
                      child: Container(
                        height: 32.0,
                        child: Image.asset('assets/images/cloud.png'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: FractionalTranslation(
                translation: Offset(transitionFactor - 1, 0.0),
                child: FutureBuilder<List<TaskPack>>(
                  future: _taskList,
                  initialData: null,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return _savedList;
                      case ConnectionState.waiting:
                        return _loadingPlaceholder;
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final dataList = snapshot.data;
                        _savedList = TimelineListView.build(
                          placeholder: _placeholder,
                          itemCount: dataList.length,
                          tileBuilder: (context, index) {
                            final item = dataList[index];
                            final rows = <Widget>[
                              Text(
                                item.data.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFFD7CAFF), fontSize: 15.0),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                item.tag.name,
                                style: TextStyle(
                                    color: item.tag.iconColor, fontSize: 12.0),
                              ),
                            ];
                            if (item.data.catalog != null &&
                                item.data.catalog.isNotEmpty) {
                              rows
                                ..add(
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                )
                                ..add(Text(
                                  item.data.catalog,
                                  style: const TextStyle(
                                      color: Color(0xFFC9A2F5), fontSize: 12.0),
                                ));
                            }
                            if (item.data.remark != null &&
                                item.data.remark.isNotEmpty) {
                              rows
                                ..add(const SizedBox(height: 10.0))
                                ..add(Text(
                                  item.data.remark,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFFC9A2F5), fontSize: 12.0),
                                ));
                            }
                            return TimelineTile(
                              rows: rows,
                              onTap: () {
                                Navigator.of(context)
                                    .push(DetailListScreen(taskPack: item,).route);
                              },
                            );
                          },
                          onGenerateTime: (index) =>
                              dataList[index]?.data?.taskTime,
                          onGenerateDotColor: (index) =>
                              dataList[index]?.tag?.iconColor,
                        );
                        return _savedList;
                      default:
                        return _placeholder;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  DateFormat('yyyy.MM.dd').format(_dateTime),
                  style: const TextStyle(
                      fontSize: 16.0, color: Color(0xFFDEC0FF), fontFamily: ''),
                ),
                Text(
                  getWeekNameLong(_dateTime.weekday),
                  style:
                      const TextStyle(fontSize: 12.0, color: Color(0xFFDEC0FF)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _cityName,
                  style:
                      const TextStyle(fontSize: 14.0, color: Color(0xFFDEC0FF)),
                ),
                Text(
                  '温度：${_temp ?? "-"}℃',
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

class TimelineScreenController {
  _TimelineListScreenState _state;

  void updateTransition(double value) {
    _state?._updateTransition(value);
  }
}
