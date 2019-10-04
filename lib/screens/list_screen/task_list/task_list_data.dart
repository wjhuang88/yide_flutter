import 'package:flutter/material.dart';

class TaskTag {
  const TaskTag({
    this.id,
    this.backgroundColor,
    this.icon,
  });

  final String id;
  final Color backgroundColor;
  final Widget icon;
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

  final String id;
  final DateTime createTime;
  final DateTime taskTime;
  final String tagId;
  final bool isFinished;
  final String content;
  final String remark;
  final String catalog;
}