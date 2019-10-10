import 'dart:math';

import 'package:flutter/material.dart';

import 'task_list_data.dart';

const _taskListGap = 20.0;
const _taskListLTPadding = 20.0;
const _taskListHeight = 80.0;
const _taskContentPadding = 15.0;
const _taskContentRadius = 20.0;
const _taskTimeStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 12, fontWeight: FontWeight.w300);

class TaskList extends StatelessWidget {
  const TaskList({
    Key key,
    @required this.listData
  }) : assert(listData != null), super(key: key);

  final List<TaskData> listData;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: listData.length,
      itemBuilder: (context, index) {
        var data = listData[index];
        assert(data.id != null);
        return Task(key: ValueKey('task_list_item_${data.id}'), data: data,);
      },
      separatorBuilder: (context, index) => SizedBox(height: _taskListGap,),
      padding: EdgeInsets.fromLTRB(_taskListLTPadding, _taskListGap, _taskListLTPadding, _taskListGap * 3),
    );
  }
}

class Task extends StatelessWidget {
  const Task({
    Key key,
    @required this.data
  }) : assert(data != null), super(key: key);

  final TaskData data;

  @override
  Widget build(BuildContext context) {
    var timeFomatter = (DateTime time) {
      var hour = time.hour;
      String period;

      String _addLeadingZeroIfNeeded(int value) {
        if (value < 10)
          return '0$value';
        return value.toString();
      }

      if (hour > 12) {
        hour = hour - 12;
        period = 'pm';
      } else if (hour == 12) {
        period = 'pm';
      } else {
        period = 'am';
      }
      return '$hour:${_addLeadingZeroIfNeeded(time.minute)} $period';
    };

    var tagData = getTagData(data);

    return Container(
      height: _taskListHeight,
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(timeFomatter(data.taskTime), style: _taskTimeStyle,),
              SizedBox(height: 8,),
              Icon(Icons.check_circle_outline, color: Colors.grey[300],),
            ],
          ),
          SizedBox(width: _taskListLTPadding,),
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: tagData.backgroundColor,
                borderRadius: BorderRadius.circular(_taskContentRadius),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(width: _taskContentPadding,),
                  tagData.icon,
                  SizedBox(width: _taskContentPadding,),
                  Expanded(child: Text(data.content, maxLines: 2, overflow: TextOverflow.ellipsis,)),
                  SizedBox(width: _taskContentPadding,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TaskTag getTagData(TaskData taskData) {
  var randomList = [
    const TaskTag(
      id: '0',
      backgroundColor: const Color(0xffe9f2ff),
      icon: const Icon(Icons.home, color: Color(0xff7978fa),),
    ),
    const TaskTag(
      id: '1',
      backgroundColor: const Color(0xffffedea),
      icon: const Icon(Icons.home, color: Color(0xfffc9b41),),
    ),
    const TaskTag(
      id: '2',
      backgroundColor: const Color(0xfffeeaea),
      icon: const Icon(Icons.home, color: Color(0xffe14265),),
    ),
    const TaskTag(
      id: '3',
      backgroundColor: const Color(0xfffbe9ff),
      icon: const Icon(Icons.home, color: Color(0xfff85cc3),),
    ),
  ];

  var ran = Random(taskData.id.hashCode);

  // TODO: 改为读取动态数据
  return randomList[ran.nextInt(4)];
}