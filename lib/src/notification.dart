import 'package:flutter/widgets.dart';
import 'package:yide/src/interfaces/navigatable.dart';

class MenuNotification extends Notification {
  final MenuNotificationType type;
  final dynamic value;
  final VoidCallback callback;

  MenuNotification(this.type, {this.value, this.callback});
}

enum MenuNotificationType {
  openMenu,
  closeMenu,
}

class PushRouteNotification extends Notification {
  final Navigatable page;
  final ValueChanged callback;
  final bool isReplacement;
  final bool isSide;

  PushRouteNotification(this.page,
      {this.isSide = false, this.isReplacement = false, this.callback});
}

class PopRouteNotification extends Notification {
  final ValueChanged<bool> callback;
  final dynamic result;
  final bool isSide;

  PopRouteNotification({this.isSide = false, this.result, this.callback});
}
