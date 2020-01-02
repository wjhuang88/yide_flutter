import 'dart:math' as Math;

import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/src/components/svg_icon.dart';
import 'package:yide/src/config.dart';

import 'tap_animator.dart';

class TimelineListView extends StatefulWidget {
  const TimelineListView._()
      : tileBuilder = null,
        onGenerateLabel = null,
        onGenerateLabelColor = null,
        onGenerateDotColor = null,
        onGenerateDotIcon = null,
        itemCount = 0,
        placeholder = null;

  TimelineListView.build({
    Key key,
    @required this.tileBuilder,
    this.onGenerateLabel,
    this.onGenerateDotColor,
    this.onGenerateDotIcon,
    @required this.itemCount,
    this.placeholder = const SizedBox(),
    this.onGenerateLabelColor,
  })  : assert(onGenerateLabel != null),
        super(key: key);

  final IndexedWidgetBuilder tileBuilder;
  final String Function(int index) onGenerateLabel;
  final Color Function(int index) onGenerateLabelColor;
  final Color Function(int index) onGenerateDotColor;
  final Icon Function(int index) onGenerateDotIcon;
  final int itemCount;
  final Widget placeholder;

  @override
  _TimelineListViewState createState() => _TimelineListViewState();
}

class _TimelineListViewState extends State<TimelineListView> {
  @override
  Widget build(BuildContext context) {
    final sideWidth = 80.0;
    if (widget.itemCount > 0) {
      return Stack(
        children: <Widget>[
          Positioned(
            left: sideWidth + 16,
            top: 0,
            bottom: 15.0,
            child: Container(
              width: 2.0,
              decoration: BoxDecoration(gradient: timelineGradient),
            ),
          ),
          Positioned(
            left: sideWidth + 13,
            bottom: 15.0,
            child: const Icon(
              FontAwesomeIcons.solidCircle,
              color: Color(0xFFFFFFFF),
              size: 8.0,
            ),
          ),
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment(0.0, -1.0),
                end: Alignment(0.0, 1.0),
                stops: [0.0, 0.1, 0.5, 0.75, 1.0],
                colors: <Color>[
                  Color(0x00FFFFFF),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFFFFF),
                  Color(0x00FFFFFF)
                ],
              ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  left: 17.0, right: 50.0, top: 40.0, bottom: 40.0),
              itemCount: widget.itemCount,
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: sideWidth,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 23.5),
                      child: Text(
                        widget.onGenerateLabel(index),
                        maxLines: 1,
                        style: TextStyle(
                          color: widget.onGenerateLabelColor != null
                              ? widget.onGenerateLabelColor(index)
                              : const Color(0xFFC9A2F5),
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TimelineDecorated(
                        decorationIcon: widget.onGenerateDotIcon != null
                            ? widget.onGenerateDotIcon(index)
                            : null,
                        decorationColor: (widget.onGenerateDotColor ??
                            (i) => const Color(0xFFFFFFFF))(index),
                        isBorderShow: index + 1 != widget.itemCount,
                        child: (widget.tileBuilder ?? (c, i) => SizedBox())(
                            context, index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    } else {
      return widget.placeholder;
    }
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
    double size;
    if (decorationIcon is Icon) {
      size = (decorationIcon as Icon).size;
    } else if (decorationIcon is SvgIcon) {
      size = (decorationIcon as SvgIcon).size;
    } else {
      size = 10.0;
    }
    return Stack(
      children: <Widget>[
        Container(
          transform: Matrix4.translationValues(0.0, 3.0, 0.0),
          child: Transform.translate(
            offset: const Offset(0.0, -3.0),
            child: child,
          ),
        ),
        Transform.translate(
          offset: Offset(-size / 2, -2.0),
          child: decorationIcon == null
              ? Icon(
                  FontAwesomeIcons.solidCircle,
                  color: decorationColor,
                  size: 10.0,
                )
              : decorationIcon,
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
