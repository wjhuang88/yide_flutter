import 'package:flutter/widgets.dart';
import 'package:yide/src/interfaces/navigatable.dart';

import 'config.dart' as Config;
import 'globle_variable.dart';

class PushRouteNotification extends Notification {
  final Navigatable page;
  final ValueChanged? callback;
  final bool isReplacement;
  final bool isSide;

  PushRouteNotification(this.page,
      {this.isSide = false, this.isReplacement = false, this.callback});
}

class PopRouteNotification extends Notification {
  final ValueChanged<bool>? callback;
  final dynamic result;
  final bool isSide;

  PopRouteNotification({this.isSide = false, this.result, this.callback});
}

class NotificationContainer extends StatefulWidget {
  final Widget child;

  const NotificationContainer({
    super.key,
    required this.child,
  });

  @override
  _NotificationContainerState createState() => _NotificationContainerState();
}

class _NotificationContainerState extends State<NotificationContainer> {
  bool _lastRouteWithMenu = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<Notification>(
      onNotification: (Notification n) {
        if (n is PushRouteNotification) {
          if (n.page.runtimeType == lastPageType) {
            return true;
          }
          lastPageType = n.page.runtimeType;
          if (n.isReplacement) {
            if (routeNames.isNotEmpty) {
              routeNames.removeLast();
            }
          }
          routeNames.add(n.page.name);
          (() async {
            final temp = _lastRouteWithMenu;
            _lastRouteWithMenu = n.page.withMene;
            NavigatorState? nav;
            if (n.isSide) {
              nav = Config.sideNavigatorKey.currentState;
            } else {
              nav = Config.mainNavigatorKey.currentState;
            }
            var result;
            if (n.isReplacement) {
              result = await nav?.pushReplacement(n.page.route);
            } else {
              result = await nav?.push(n.page.route);
            }
            _lastRouteWithMenu = temp;
            (n.callback ?? (arg) {})(result);
          })();
        } else if (n is PopRouteNotification) {
          NavigatorState? nav;
          if (n.isSide) {
            nav = Config.sideNavigatorKey.currentState;
          } else {
            nav = Config.mainNavigatorKey.currentState;
          }
          if (routeNames.length > 1) {
            routeNames.removeLast();
          }
          lastPageType = null;
          nav?.maybePop(n.result).then((ret) {
            (n.callback ?? (arg) {})(ret);
          });
        }
        return true;
      },
      child: widget.child,
    );
  }
}
