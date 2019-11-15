import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditMainScreen extends StatefulWidget {
  static const String routeName = 'new';

  const EditMainScreen({Key key, this.transitionFactor, this.controller})
      : super(key: key);
  static Route get pageRoute => _buildRoute();

  final double transitionFactor;
  final EditScreenController controller;

  @override
  _EditMainScreenState createState() => _EditMainScreenState(controller);
}

class _EditMainScreenState extends State<EditMainScreen> {
  _EditMainScreenState(this._controller);
  final TextEditingController _textEditingController = TextEditingController();

  double transitionFactor;
  EditScreenController _controller;

  @override
  void initState() {
    super.initState();
    transitionFactor = widget.transitionFactor;
    if (_controller == null) {
      _controller = EditScreenController();
    }
    _controller._state = this;
  }

  @override
  void didUpdateWidget(EditMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transitionFactor != oldWidget.transitionFactor) {
      transitionFactor = oldWidget.transitionFactor;
    }
  }

  void _updateTransition(double value) {
    setState(() {
      this.transitionFactor = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Container(
              transform: Matrix4.translationValues(0.0, -100.0 * transitionFactor, 0.0),
              margin:
                  const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 15.0),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF975ED8), Color(0xFF7352D0)]),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      offset: Offset(0.0, 2.0),
                      blurRadius: 17.5,
                      color: Color(0x8A37256D),
                    )
                  ]),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        FontAwesomeIcons.solidCircle,
                        color: Color(0xFF62DADB),
                        size: 10.0,
                      ),
                      SizedBox(
                        width: 11.0,
                      ),
                      Text(
                        '工作',
                        style:
                            TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    ],
                  ),
                  TextField(
                    autofocus: true,
                    minLines: 3,
                    maxLines: 4,
                    controller: _textEditingController,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '记录你今天的任务',
                      hintStyle: TextStyle(color: Color(0xFF9B7FE9)),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25.5,
            ),
            Expanded(
              child: Transform.translate(
                offset: Offset(0.0, 200 * transitionFactor),
                child: Opacity(
                  opacity: 1 - transitionFactor.clamp(0.0, 1.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        '今天',
                        style: const TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      Text(
                        '11月6日',
                        style:
                            const TextStyle(color: Color(0xFFBBADE7), fontSize: 14.0),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      Text(
                        '全天',
                        style: const TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0.0, 60.0 * transitionFactor, 0.0),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '设置时间',
                    style: const TextStyle(
                        color: Color(0xFFBBADE7), fontSize: 14.0),
                  ),
                  Text(
                    '某天',
                    style: const TextStyle(
                        color: Color(0xFFBBADE7), fontSize: 14.0),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF472478),
              transform: Matrix4.translationValues(0.0, 150.0 * transitionFactor, 0.0),
              height: 45.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).maybePop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            FontAwesomeIcons.arrowAltCircleLeft,
                            color: Color(0xFFBBADE7),
                            size: 16.0,
                          ),
                          const SizedBox(
                            width: 5.5,
                          ),
                          const Text(
                            '返回',
                            style: const TextStyle(
                                color: Color(0xFFBBADE7), fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _VerticleDivider(),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Center(
                        child: const Text(
                          '更多设置',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFFBBADE7), fontSize: 14.0),
                        ),
                      ),
                    ),
                  ),
                  const _VerticleDivider(),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            FontAwesomeIcons.save,
                            color: Color(0xFFBBADE7),
                            size: 16.0,
                          ),
                          const SizedBox(
                            width: 5.5,
                          ),
                          const Text(
                            '保存',
                            style: const TextStyle(
                                color: Color(0xFFBBADE7), fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EditScreenController {
  _EditMainScreenState _state;

  void updateTransition(double value) {
    _state?._updateTransition(value);
  }
}

_buildRoute() {
  EditScreenController controller = EditScreenController();
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) {
      return EditMainScreen(
        controller: controller,
        transitionFactor: 1.0,
      );
    },
    transitionDuration: Duration(milliseconds: 400),
    transitionsBuilder: (context, anim1, anim2, child) {
      var curve = Curves.easeOutCubic;
      var offset = 1 - curve.transform(anim1.value);
      controller.updateTransition(offset);
      return child;
    },
  );
}

class _VerticleDivider extends StatelessWidget {
  const _VerticleDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 11.0),
      decoration: const BoxDecoration(
          border:
              Border(right: BorderSide(color: Color(0xFFE8E8E8), width: 0.5))),
    );
  }
}
