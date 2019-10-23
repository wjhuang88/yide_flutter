import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:yide/models/task_data.dart';

const _taskListGap = 25.0;
const _taskListLTPadding = 20.0;
const _taskListHeight = 80.0;
const _taskContentPadding = 15.0;
const _taskContentRadius = 20.0;
const _taskTimeStyle = const TextStyle(color: const Color(0xff020e2c), fontSize: 12, fontWeight: FontWeight.w300);
const _taskContentStyle = const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal, fontFamily: 'SourceHanSans');

final logger = Logger(
  printer: PrettyPrinter(methodCount: 0, lineLength: 80, printTime: true),
);

class TaskList extends StatelessWidget {
  const TaskList({
    Key key,
    @required this.data,
    this.onItemTap,
  }) : assert(data != null, 'list data can not be null.'), super(key: key);

  final List<TaskPack> data;
  final void Function(TaskPack data) onItemTap;

  @override
  Widget build(BuildContext context) {
    logger.d('Building list view in main list page.');
    return ListView.separated(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        assert(item != null, 'item with index: $index is null.');
        return Task(
          key: ValueKey('task_list_item_${item.data.id}'),
          dataPack: item,
          onTap: (data) => onItemTap(data),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: _taskListGap,),
      padding: EdgeInsets.fromLTRB(_taskListLTPadding, _taskListGap, _taskListLTPadding, _taskListGap * 3),
    );
  }
}

class Task extends StatelessWidget {
  const Task({
    Key key,
    @required this.dataPack,
    this.onTap,
  }) : assert(dataPack != null, 'data pack cannot be null.'), super(key: key);

  final TaskPack dataPack;
  final void Function(TaskPack data) onTap;

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

    return Container(
      height: _taskListHeight,
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(timeFomatter(dataPack.data.taskTime), style: _taskTimeStyle,),
              SizedBox(height: 8,),
              Icon(Icons.check_circle_outline, color: Colors.grey[300],),
            ],
          ),
          SizedBox(width: _taskListLTPadding,),
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(dataPack),
              child: TaskItemContainer(dataPack: dataPack),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskItemContainer extends StatelessWidget {
  const TaskItemContainer({
    Key key,
    @required this.dataPack,
  }) : super(key: key);

  final TaskPack dataPack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: dataPack.tag.backgroundColor,
        borderRadius: BorderRadius.circular(_taskContentRadius),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: _taskContentPadding,),
          Container(
            alignment: Alignment.center,
            height: 40.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: dataPack.tag.iconColor,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Icon(dataPack.tag.icon, color: Colors.white, size: 18,),
          ),
          const SizedBox(width: _taskContentPadding,),
          Expanded(child: Text(dataPack.data.content, style: _taskContentStyle, maxLines: 2, overflow: TextOverflow.ellipsis,)),
          const SizedBox(width: _taskContentPadding,),
        ],
      ),
    );
  }
}

