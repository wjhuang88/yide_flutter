import 'dart:math';

import 'package:flutter/material.dart';

class TaskTag {
  const TaskTag({
    this.id,
    this.backgroundColor,
    this.icon,
    this.name,
  });

  const TaskTag.defaultNull()
    : id = '-1',
      backgroundColor = Colors.white,
      icon = const Icon(Icons.label),
      name = '载入中';

  final String id;
  final Color backgroundColor;
  final Widget icon;
  final String name;
}

class TaskData {
  const TaskData({
    this.id,
    this.createTime,
    this.taskTime,
    this.tagId,
    this.isFinished = false,
    this.content,
    this.remark,
    this.catalog,
  });

  TaskData.defultNull() 
    : id = '-1',
      createTime = DateTime(1970),
      taskTime = DateTime(1970),
      tagId = '-1',
      isFinished = false,
      content = '',
      remark = '',
      catalog = '';

  final String id;
  final DateTime createTime;
  final DateTime taskTime;
  final String tagId;
  final bool isFinished;
  final String content;
  final String remark;
  final String catalog;
}

class TaskPack {
  final TaskData data;
  final TaskTag tag;

  TaskPack(this.data, this.tag);
}

Future<TaskPack> getTaskData(String id) async {
  // TODO: 请求远程数据
  var _getList = (String id) async => {
    '0': TaskData(
      id: '0',
      tagId: '0',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    '1': TaskData(
      id: '1',
      tagId: '2',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!再来一个'
    ),
    '2': TaskData(
      id: '2',
      tagId: '0',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    '3': TaskData(
      id: '3',
      tagId: '1',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    '4': TaskData(
      id: '4',
      tagId: '2',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    '5': TaskData(
      id: '5',
      tagId: '0',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    '6': TaskData(
      id: '6',
      tagId: '1',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    '7': TaskData(
      id: '7',
      tagId: '1',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    '8': TaskData(
      id: '8',
      tagId: '0',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
    '9': TaskData(
      id: '9',
      tagId: '2',
      taskTime: DateTime.now(),
      content: '我要做点什么事情，要做一件事！看看,look look, English!'
    ),
  }[id];

  TaskData data = await _getList(id);
  TaskTag tag = await _getTagData(data);

  return TaskPack(data, tag);
}

Future<List<TaskPack>> getTaskList(Object args) async {
  // TODO: 请求远程数据
  var list = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  var result = <TaskPack>[];
  for (var i = 0; i < list.length; i++) {
    var item = await getTaskData(list[i]);
    result.add(item);
  }
  await Future.delayed(Duration(milliseconds: 200));
  return result;
}

Future<TaskTag> _getTagData(TaskData taskData) async {
  // TODO: 改为读取动态数据
  var tagList = {
    '0': const TaskTag(
      id: '0',
      backgroundColor: const Color(0xffe9f2ff),
      icon: const Icon(Icons.work, color: Color(0xff7978fa),),
      name: '工作',
    ),
    '1': const TaskTag(
      id: '1',
      backgroundColor: const Color(0xffffedea),
      icon: const Icon(Icons.home, color: Color(0xfffc9b41),),
      name: '生活',
    ),
    '2': const TaskTag(
      id: '2',
      backgroundColor: const Color(0xfffeeaea),
      icon: const Icon(Icons.book, color: Color(0xffe14265),),
      name: '自我提升',
    ),
  };

  return tagList[taskData.tagId];
}

Future<List<TaskTag>> getTagList() async {
  return [
    const TaskTag(
      id: '0',
      backgroundColor: const Color(0xffe9f2ff),
      icon: const Icon(Icons.work, color: Color(0xff7978fa),),
      name: '工作',
    ),
    const TaskTag(
      id: '1',
      backgroundColor: const Color(0xffffedea),
      icon: const Icon(Icons.home, color: Color(0xfffc9b41),),
      name: '生活',
    ),
    const TaskTag(
      id: '2',
      backgroundColor: const Color(0xfffeeaea),
      icon: const Icon(Icons.book, color: Color(0xffe14265),),
      name: '自我提升',
    ),
  ];
}