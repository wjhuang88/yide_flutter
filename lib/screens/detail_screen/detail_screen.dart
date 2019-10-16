import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yide/models/date_tools.dart';
import 'package:yide/models/task_data.dart';

const _backgroundColor = const Color(0xff0a3f74);

const _appTitleHeight = 45.0;
const _mainHeight = 600.0;

const _mainPanRadius = 45.0;

const _headerStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
const _headerMargin = 20.0;

const _panelBottomMargin = 70.0;

const _boxOffsetMin = 0.0;
const _boxOffsetMax = 5.0;

const _panelDecoration = const BoxDecoration(
  color: Colors.white,
  borderRadius: const BorderRadius.only(
    topLeft: const Radius.circular(_mainPanRadius),
    topRight: const Radius.circular(_mainPanRadius),
    bottomLeft: const Radius.circular(_mainPanRadius),
    bottomRight: const Radius.circular(_mainPanRadius),
  ),
  boxShadow: <BoxShadow>[
    const BoxShadow(
      offset: const Offset(0.0, -3.0),
      blurRadius: 3.0,
      color: const Color(0x4CBDBDBD),
    ),
  ],
);
const _subPanelDecoration = const BoxDecoration(
  color: Colors.white,
  borderRadius: const BorderRadius.only(
    topLeft: const Radius.circular(_mainPanRadius),
    topRight: const Radius.circular(_mainPanRadius),
    bottomLeft: const Radius.circular(_mainPanRadius),
    bottomRight: const Radius.circular(_mainPanRadius),
  ),
  boxShadow: <BoxShadow>[
    const BoxShadow(
      offset: const Offset(0.0, 0.0),
      blurRadius: 3.0,
      spreadRadius: 1.0,
      color: Colors.grey,
    ),
  ],
);

const _panelMargin = const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, _panelBottomMargin);

typedef _PageRouteBuilder = Widget Function(BuildContext);

class DetailScreen extends StatefulWidget {
  DetailScreen(
    this.data,
    {Key key}
  ) : super(key: key);

  final TaskData data;

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {

  Future<TaskTag> tagData;
  double boxOffset = 0.0;

  AnimationController _boxOffsetController;
  Animation<double> _boxOffsetAnim;

  IconData _floatingButtomIcon = Icons.check;
  VoidCallback _floatingButtomAction = () {};

  @override
  void initState() {
    super.initState();
    tagData = getTagData(widget.data);
    _boxOffsetController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _boxOffsetAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_boxOffsetController);
    _boxOffsetAnim.addListener(() => setState((){
      boxOffset = lerpDouble(_boxOffsetMin, _boxOffsetMax, _boxOffsetAnim.value);
    }));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_appTitleHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          brightness: Brightness.dark,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white, size: 28,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.white, size: 24,),
              onPressed: () {},
            ),
            SizedBox(width: 10.0,),
          ],
        ),
      ),
      floatingActionButtonLocation: _FloatingLocation(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(_floatingButtomIcon),
        onPressed: _floatingButtomAction,
      ),
      body: Hero(
        tag: 'panel_background',
        flightShuttleBuilder: (_, __, ___, ____, _____) => Container(
          decoration: _panelDecoration,
          margin: _panelMargin,
        ),
        child: Container(
          alignment: Alignment.topCenter,
          transform: Matrix4.translationValues(boxOffset, boxOffset, 0.0),
          height: _mainHeight,
          margin: _panelMargin,
          decoration: _panelDecoration,
          child: Navigator(
            initialRoute: 'home',
            onGenerateRoute: (settings) {
              switch(settings.name) {
                case 'home': {
                  return _buildFadeRoute(_mainPanelBuilder);
                }
                case 'tags': {
                  return _buildSlideRoute(_tagsPanelBuilder);
                }
                default:
                  throw FlutterError(
                    'The builder for route "${settings.name}" returned null.\n'
                    'Route builders must never return null.'
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _buildSlideRoute(_PageRouteBuilder pageBuilder) {
    return PageRouteBuilder<bool>(
      pageBuilder: (context, anim1, anim2) => pageBuilder(context),
      transitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(-1.0, -1.0), end: Offset(0.0, 0.0)).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutSine,
            ),
          ),
          child: child,
        );
      },
    );
  }

  PageRouteBuilder _buildFadeRoute(_PageRouteBuilder pageBuilder) {
    return PageRouteBuilder<bool>(
      pageBuilder: (context, anim1, anim2) => pageBuilder(context),
      transitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        );
      },
    );
  }

  Widget _tagsPanelBuilder(BuildContext context) {
    _floatingButtomIcon = Icons.keyboard_backspace;
    return Container(
      alignment: Alignment.topCenter,
      transform: Matrix4.translationValues(-boxOffset, -boxOffset, 0.0),
      height: _mainHeight,
      decoration: _subPanelDecoration,
      child: FlatButton(
        child: Text('back'),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
    );
  }

  Widget _mainPanelBuilder(BuildContext context) {
    _floatingButtomIcon = Icons.check;
    return ListView(
      padding: const EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 0.0),
      children: <Widget>[
        Text(widget.data.content, style: _headerStyle, textAlign: TextAlign.center,),

        const SizedBox(height: _headerMargin,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.calendar_today, color: Colors.grey, size: 18,),
        const SizedBox(width: 5,),
            Text('${widget.data.taskTime.month}月${widget.data.taskTime.day}日  ${getWeekNameLong(widget.data.taskTime.weekday)}', textAlign: TextAlign.center,),
          ],
        ),
        const SizedBox(height: _headerMargin,),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<TaskTag>(
              stream: (() async* {yield await tagData;})(),
              initialData: TaskTag.defaultNull(),
              builder: (context, snapshot) {
                return FlatButton.icon(
                  icon: snapshot.data.icon,
                  label: Text(snapshot.data.name),
                  color: snapshot.data.backgroundColor,
                  colorBrightness: Brightness.light,
                  shape: StadiumBorder(),
                  onPressed: () async {
                    _boxOffsetController.forward(from: 0);
                    var callback = await Navigator.of(context).pushNamed<bool>('tags');
                    if (callback) {
                      _boxOffsetController.reverse(from: 1);
                    }
                  },
                );
              }
            ),
          ],
        ),

        const SizedBox(height: _headerMargin,),
        const Text('提醒', style: _headerStyle, textAlign: TextAlign.center,),
        const SizedBox(height: _headerMargin,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20,),
            const Text('点击添加', textAlign: TextAlign.center,),
          ],
        ),

        const SizedBox(height: _headerMargin,),
        const Text('重复', style: _headerStyle, textAlign: TextAlign.center,),
        const SizedBox(height: _headerMargin,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20,),
            const Text('点击添加', textAlign: TextAlign.center,),
          ],
        ),

        const SizedBox(height: _headerMargin,),
        const Text('备注', style: _headerStyle, textAlign: TextAlign.center,),
        const SizedBox(height: _headerMargin,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20,),
            const Text('点击添加', textAlign: TextAlign.center,),
          ],
        ),
      ],
    );
  }
}

class _FloatingLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;
    double fabY = _appTitleHeight + _mainHeight + 15;
    return Offset(fabX, fabY);
  }

}