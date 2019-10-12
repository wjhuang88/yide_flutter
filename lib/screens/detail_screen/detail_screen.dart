import 'package:flutter/material.dart';
import 'package:yide/screens/list_screen/task_list/task_list_data.dart';
import 'package:yide/screens/list_screen/task_list/task_list.dart';

const _backgroundColor = const Color(0xff0a3f74);

const _taskListHeight = 80.0;
const _taskContentPadding = 15.0;
const _taskContentRadius = 20.0;
const _taskContentStyle = const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal, fontFamily: 'SourceHanSans');

const _mainPanRadius = 45.0;

const _headerStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
const _headerMargin = 20.0;

class DetailScreen extends StatelessWidget {
  DetailScreen(
    this.data,
    {Key key}
  ) : super(key: key);

  final TaskData data;

  @override
  Widget build(BuildContext context) {
    final tagData = getTagData(data);
    final heroTag = 'task_list_hero_${data.id}';
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Brightness.dark,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 28,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white, size: 20,),
            onPressed: () {},
          ),
          SizedBox(width: 10.0,)
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_mainPanRadius),
            topRight: Radius.circular(_mainPanRadius),
          ),
          boxShadow: <BoxShadow>[
            const BoxShadow(
              offset: const Offset(0.0, -3.0),
              blurRadius: 3.0,
              color: const Color(0x4CBDBDBD),
            ),
          ],
        ),
        child: ListView(
          children: <Widget>[
            const Text('任务内容', style: _headerStyle,),
            const SizedBox(height: _headerMargin,),
            _TitlePanel(heroTag: heroTag, tagData: tagData, data: data),

            const SizedBox(height: _headerMargin,),
            const Text('提醒', style: _headerStyle,),
            const SizedBox(height: _headerMargin,),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(_taskContentPadding),
              decoration: BoxDecoration(
                color: tagData.backgroundColor,
                borderRadius: BorderRadius.circular(_taskContentRadius)
              ),
              child: const Text('点击添加'),
            ),

            const SizedBox(height: _headerMargin,),
            const Text('重复', style: _headerStyle,),
            const SizedBox(height: _headerMargin,),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(_taskContentPadding),
              decoration: BoxDecoration(
                color: tagData.backgroundColor,
                borderRadius: BorderRadius.circular(_taskContentRadius)
              ),
              child: const Text('点击添加'),
            ),

            const SizedBox(height: _headerMargin,),
            const Text('备注', style: _headerStyle,),
            const SizedBox(height: _headerMargin,),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(_taskContentPadding),
              decoration: BoxDecoration(
                color: tagData.backgroundColor,
                borderRadius: BorderRadius.circular(_taskContentRadius)
              ),
              child: const Text('点击添加'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitlePanel extends StatelessWidget {
  const _TitlePanel({
    Key key,
    @required this.heroTag,
    @required this.tagData,
    @required this.data,
  }) : super(key: key);

  final String heroTag;
  final TaskTag tagData;
  final TaskData data;

  @override
  Widget build(BuildContext context) {
    return Hero(
      flightShuttleBuilder: (_, anim, ___, ____, _____) => Container(
        height: _taskListHeight * anim.value,
        decoration: BoxDecoration(
          color: tagData.backgroundColor,
          borderRadius: BorderRadius.circular(_taskContentRadius),
        ),
      ),
      tag: heroTag,
      child: Container(
        height: _taskListHeight,
        decoration: BoxDecoration(
          color: tagData.backgroundColor,
          borderRadius: BorderRadius.circular(_taskContentRadius),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: _taskContentPadding,),
            tagData.icon,
            const SizedBox(width: _taskContentPadding,),
            Expanded(child: Text(data.content, style: _taskContentStyle, maxLines: 2, overflow: TextOverflow.ellipsis,)),
            const SizedBox(width: _taskContentPadding,),
          ],
        ),
      ),
    );
  }
}