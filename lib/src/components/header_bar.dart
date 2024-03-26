import 'package:flutter/cupertino.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    this.leadingIcon,
    this.actionIcon,
    this.title = '',
    this.onLeadingAction,
    this.onAction,
    this.indent = 0.0,
    this.endIndet = 15.0,
  });

  final Widget? leadingIcon;
  final Widget? actionIcon;
  final String title;
  final double indent;
  final double endIndet;

  final VoidCallback? onLeadingAction;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    final leading = CupertinoButton(
      padding: EdgeInsets.only(left: indent),
      child: leadingIcon ?? SizedBox(),
      onPressed: onLeadingAction,
    );
    children.add(leading);

    final action = CupertinoButton(
      padding: EdgeInsets.only(right: endIndet),
      child: actionIcon ?? SizedBox(),
      onPressed: onAction,
    );
    children.add(action);

    final fullWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );

    return SafeArea(
      bottom: false,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 18.0, color: const Color(0xFFFFFFFF)),
              ),
            ),
          ),
          fullWidget,
        ],
      ),
    );
  }
}
