import 'package:flutter/widgets.dart';
import 'package:yide/src/interfaces/navigatable.dart';

class MenuNotification extends Notification {
  final MenuNotificationType type;
  final dynamic value;

  MenuNotification(this.type, {this.value});
}

enum MenuNotificationType {
  openMenu,
  closeMenu,
}

class PushRouteNotification extends Notification {
  final Navigatable page;
  final ValueChanged callback;
  final bool isReplacement;

  PushRouteNotification(this.page, {this.isReplacement = false, this.callback});
}

class PopRouteNotification extends Notification {
  final ValueChanged<bool> callback;
  final dynamic result;

  PopRouteNotification({this.result, this.callback});
}
