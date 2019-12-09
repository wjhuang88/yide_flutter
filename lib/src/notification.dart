import 'package:flutter/widgets.dart';

class AppNotification extends Notification {
  final NotificationType type;
  final dynamic value;

  AppNotification(this.type, {this.value});
}

enum NotificationType {
  openMenu,
  closeMenu,
  dragMenu,
  dragMenuEnd,
}