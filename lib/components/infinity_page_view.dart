import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const int _hugePageOffset = 9999999;

class InfinityPageController {
  InfinityPageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        _pageController = PageController(
            initialPage: initialPage + _hugePageOffset,
            keepPage: keepPage,
            viewportFraction: viewportFraction);

  final PageController _pageController;

  int get initialPage => _pageController.initialPage - _hugePageOffset;

  double get page => _pageController.page - _hugePageOffset;

  Future<void> animateToPage(int page, {Duration duration, Curve curve}) {
    return _pageController.animateToPage(page + _hugePageOffset,
        duration: duration, curve: curve);
  }

  void jumpToPage(int page) {
    _pageController.jumpToPage(page + _hugePageOffset);
  }

  void dispose() {
    //_pageController.dispose();
  }
}

class InfinityPageView extends StatefulWidget {
  final Axis scrollDirection;
  final bool reverse;
  final InfinityPageController controller;
  final ScrollPhysics physics;
  final bool pageSnapping;
  final ValueChanged<int> onPageChanged;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final DragStartBehavior dragStartBehavior;

  const InfinityPageView({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required this.itemBuilder,
    this.itemCount,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  @override
  _InfinityPageViewState createState() => _InfinityPageViewState(controller);
}

class _InfinityPageViewState extends State<InfinityPageView> {
  _InfinityPageViewState(this._controller);

  InfinityPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller ??= InfinityPageController();
  }

  @override
  void dispose() {
    _controller?._pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _controller._pageController,
      physics: widget.physics,
      pageSnapping: widget.pageSnapping,
      onPageChanged: (_innerPage) {
        if (widget.onPageChanged != null) {
          widget.onPageChanged(_innerPage - _hugePageOffset);
        }
      },
      itemBuilder: (context, _innerPage) =>
          widget.itemBuilder(context, _innerPage - _hugePageOffset),
      itemCount: widget.itemCount,
      dragStartBehavior: widget.dragStartBehavior,
    );
  }
}
