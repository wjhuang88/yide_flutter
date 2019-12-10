import 'package:flutter/widgets.dart';

void showToast(String content, BuildContext context, Duration duration) async {
  //获取OverlayState
  OverlayState overlayState = Overlay.of(context);
  //创建OverlayEntry
  OverlayEntry _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Color(0x88000000)
          ),
          alignment: Alignment.center,
          child: Text(content, textAlign: TextAlign.center,),
        ),
      ));
  //显示到屏幕上。
  overlayState.insert(_overlayEntry);
  await Future.delayed(duration);
  _overlayEntry.remove();
}
