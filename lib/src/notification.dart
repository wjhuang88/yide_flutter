import 'package:flutter/widgets.dart';
import 'package:yide/src/interfaces/navigatable.dart';

import 'config.dart' as Config;

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

class NotificationContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onMenuOpen;
  final VoidCallback onMenuClose;
  final VoidCallback onMenuActive;
  final VoidCallback onMenuDeactive;

  const NotificationContainer({
    Key key,
    @required this.onMenuOpen,
    @required this.onMenuClose,
    @required this.onMenuActive,
    @required this.onMenuDeactive,
    @required this.child,
  }) : super(key: key);

  @override
  _NotificationContainerState createState() => _NotificationContainerState();
}

class _NotificationContainerState extends State<NotificationContainer> {

  bool _lastRouteWithMenu = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<Notification>(
      onNotification: (Notification n) {
        if (n is MenuNotification) {
          () async {
            switch (n.type) {
              case MenuNotificationType.openMenu:
                widget.onMenuOpen();
                break;
              case MenuNotificationType.closeMenu:
                widget.onMenuClose();
                break;
              default:
            }
            if (n.callback != null) n.callback();
          }();
        } else if (n is PushRouteNotification) {
          (() async {
            final temp = _lastRouteWithMenu;
            _lastRouteWithMenu = n.page.withMene;
            if (_lastRouteWithMenu) {
              widget.onMenuActive();
            } else {
              widget.onMenuDeactive();
            }
            NavigatorState nav;
            if (n.isSide) {
              nav = Config.sideNavigatorKey.currentState;
            } else {
              nav = Config.mainNavigatorKey.currentState;
            }
            var result;
            if (n.isReplacement) {
              result = await nav.pushReplacement(n.page.route);
            } else {
              result = await nav.push(n.page.route);
            }
            _lastRouteWithMenu = temp;
            if (_lastRouteWithMenu) {
              widget.onMenuActive();
            } else {
              widget.onMenuDeactive();
            }
            (n.callback ?? (arg) {})(result);
          })();
        } else if (n is PopRouteNotification) {
          NavigatorState nav;
          if (n.isSide) {
            nav = Config.sideNavigatorKey.currentState;
          } else {
            nav = Config.mainNavigatorKey.currentState;
          }
          nav.maybePop(n.result).then((ret) {
            (n.callback ?? (arg) {})(ret);
          });
        }
        return true;
      },
      child: widget.child,
    );
  }
}
