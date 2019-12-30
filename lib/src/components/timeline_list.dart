import 'dart:math' as Math;

import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'tap_animator.dart';

class TimelineListView extends StatelessWidget {
  const TimelineListView._()
      : showTime = true,
        tileBuilder = null,
        onGenerateLabel = null,
        onGenerateLabelColor = null,
        onGenerateDotColor = null,
        onGenerateDotIcon = null,
        itemCount = 0,
        placeholder = null;

  TimelineListView.build({
    Key key,
    this.showTime = true,
    @required this.tileBuilder,
    this.onGenerateLabel,
    this.onGenerateDotColor,
    this.onGenerateDotIcon,
    @required this.itemCount,
    this.placeholder = const SizedBox(),
    this.onGenerateLabelColor,
  })  : assert(!showTime || onGenerateLabel != null),
        super(key: key);

  final bool showTime;
  final IndexedWidgetBuilder tileBuilder;
  final String Function(int index) onGenerateLabel;
  final Color Function(int index) onGenerateLabelColor;
  final Color Function(int index) onGenerateDotColor;
  final Icon Function(int index) onGenerateDotIcon;
  final int itemCount;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    return itemCount > 0
        ? ListView.builder(
            padding: const EdgeInsets.only(
                left: 17.0, right: 50.0, top: 20.0, bottom: 40.0),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  showTime
                      ? Container(
                          width: 60.0,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 23.5),
                          child: Text(
                            onGenerateLabel(index),
                            maxLines: 1,
                            style: TextStyle(
                              color: onGenerateLabelColor != null
                                  ? onGenerateLabelColor(index)
                                  : const Color(0xFFC9A2F5),
                              fontSize: 12.0,
                            ),
                          ),
                        )
                      : SizedBox(),
                  Expanded(
                    child: TimelineDecorated(
                      decorationIcon: onGenerateDotIcon != null ? onGenerateDotIcon(index) : null,
                      decorationColor: (onGenerateDotColor ??
                          (i) => const Color(0xFFFFFFFF))(index),
                      isBorderShow: index + 1 != itemCount,
                      child:
                          (tileBuilder ?? (c, i) => SizedBox())(context, index),
                    ),
                  ),
                ],
              );
            })
        : placeholder;
  }
}

class TimelineDecorated extends StatelessWidget {
  const TimelineDecorated({
    Key key,
    this.decorationColor,
    this.decorationIcon,
    this.child,
    this.isBorderShow = true,
  }) : super(key: key);

  final Color decorationColor;
  final Widget decorationIcon;
  final Widget child;
  final bool isBorderShow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          transform: Matrix4.translationValues(0.0, 3.0, 0.0),
          decoration: BoxDecoration(
              border: Border(
            left: isBorderShow
                ? BorderSide(color: Color(0xFF6F54BC))
                : BorderSide(color: Color(0x00000000)),
          )),
          child: Transform.translate(
            offset: const Offset(0.0, -3.0),
            child: child,
          ),
        ),
        Transform.translate(
          offset: const Offset(-10.5, -2.0),
          child: decorationIcon == null ? Icon(
            FontAwesomeIcons.solidCircle,
            color: decorationColor,
            size: 10.0,
          ) : decorationIcon,
        ),
      ],
    );
  }
}

class TimelineTile extends StatelessWidget {
  final List<Widget> rows;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final EdgeInsetsGeometry padding;

  const TimelineTile({
    Key key,
    @required this.rows,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.only(left: 27.5, bottom: 0.0),
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TapAnimator(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      builder: (_factor) => Container(
        width: double.infinity,
        padding: padding,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(-_factor * Math.pi / 24)
          ..rotateX(-_factor * Math.pi / 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }
}
