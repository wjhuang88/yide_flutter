import 'package:flutter/cupertino.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    Key key,
    this.leadingIcon,
    this.actionIcon,
    this.title,
    this.onLeadingAction,
    this.onAction,
  }) : super(key: key);

  final Widget leadingIcon;
  final Widget actionIcon;
  final String title;

  final VoidCallback onLeadingAction;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    final leading = CupertinoButton(
      padding: EdgeInsets.zero,
      child: leadingIcon ?? const SizedBox(),
      onPressed: onLeadingAction ?? () {},
    );
    children.add(leading);

    if (title != null) {
      children.add(Text(
        title,
        style: const TextStyle(fontSize: 18.0, color: const Color(0xFFFFFFFF)),
      ));
    }

    final action = CupertinoButton(
      padding: const EdgeInsets.only(right: 15.0),
      child: actionIcon ??
          const SizedBox(),
      onPressed: onAction ?? () {},
    );
    children.add(action);

    return SafeArea(
      bottom: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}