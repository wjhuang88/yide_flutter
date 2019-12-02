import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/components/timeline_list.dart';
import 'package:yide/models/task_data.dart';
import 'package:yide/notification.dart';
import 'package:yide/screens/detail_screen/edit_main_screen.dart';

class TimelineListScreen extends StatefulWidget {
  static const String routeName = 'timeline_list';

  const TimelineListScreen(
      {Key key, this.transitionFactor = 0.0, this.controller})
      : super(key: key);
  static Route get pageRoute => _buildRoute();

  final double transitionFactor;
  final TimelineScreenController controller;

  @override
  _TimelineListScreenState createState() =>
      _TimelineListScreenState(controller);
}

class _TimelineListScreenState extends State<TimelineListScreen> {
  _TimelineListScreenState(this._controller);

  double transitionFactor;
  TimelineScreenController _controller;
  Widget _savedList;
  Widget _placeholder;
  Widget _loadingPlaceholder;

  Future<List<TaskPack>> _taskList;

  @override
  void initState() {
    super.initState();
    transitionFactor = widget.transitionFactor;
    if (_controller == null) {
      _controller = TimelineScreenController();
    }

    _savedList = _placeholder = Container();
    _loadingPlaceholder = Center(
      child: SpinKitCircle(
        color: Colors.blue,
        size: 70.0,
      ),
    );

    _taskList = getTaskList(null);

    _controller._state = this;
  }

  @override
  void didUpdateWidget(TimelineListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transitionFactor != oldWidget.transitionFactor) {
      transitionFactor = oldWidget.transitionFactor;
    }
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
            Navigator.pushNamed(context, EditMainScreen.routeName);
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

class TimelineScreenController {
  _TimelineListScreenState _state;

  void updateTransition(double value) {
    _state?._updateTransition(value);
  }
}

_buildRoute() {
  TimelineScreenController controller = TimelineScreenController();
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) {
      return TimelineListScreen(
        transitionFactor: anim2.value,
        controller: controller,
      );
    },
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
