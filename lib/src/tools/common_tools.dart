import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<void> showToast(
    String content, BuildContext context, Duration duration) async {
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
              decoration: const BoxDecoration(color: Color(0x88000000)),
              alignment: Alignment.center,
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ));
  //显示到屏幕上。
  overlayState.insert(_overlayEntry);
  await Future.delayed(duration);
  _overlayEntry.remove();
  return;
}

Future<void> haptic() async {
  bool hasSuitableHapticHardware;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      hasSuitableHapticHardware = true;
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.macOS:
      hasSuitableHapticHardware = false;
      break;
  }
  assert(hasSuitableHapticHardware != null);
  if (hasSuitableHapticHardware) {
    return HapticFeedback.selectionClick();
  }
}

Future<void> editPopup(BuildContext context,
    {VoidCallback onCancel,
    VoidCallback onEdit,
    String editTitle = '进入编辑',
    String clearTitle = '清除当前设置的内容',
    VoidCallback onClear}) async {
  final act = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            editTitle,
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF000000),
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(true),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: Text(
            clearTitle,
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF000000),
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(false),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          '取消',
          style: const TextStyle(
            fontSize: 16.0,
            color: Color(0xFF000000),
          ),
        ),
        onPressed: Navigator.of(context).maybePop,
      ),
    ),
  );
  if (act == null) {
    (onCancel ?? () {})();
  } else if (act) {
    (onEdit ?? () {})();
  } else {
    (onClear ?? () {})();
  }
}

Future<void> detailPopup(
  BuildContext context, {
  VoidCallback onCancel,
  VoidCallback onDetail,
  VoidCallback onDelete,
  VoidCallback onDone,
  VoidCallback onReactive,
  String detailTitle = '查看任务详情',
  String deleteTitle = '删除此任务',
  String doneTitle = '设置此任务为已完成',
  String reactiveTitle = '重新激活任务',
  bool isDone = false,
}) async {
  actions(BuildContext context) {
    final actions = <Widget>[
      CupertinoActionSheetAction(
        child: Text(
          detailTitle,
          style: const TextStyle(
            fontSize: 16.0,
            color: Color(0xFF000000),
          ),
        ),
        onPressed: () => Navigator.of(context).maybePop(0),
      )
    ];
    if (!isDone) {
      actions.add(
        CupertinoActionSheetAction(
          child: Text(
            doneTitle,
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF000000),
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(1),
        ),
      );
    } else {
      actions.add(
        CupertinoActionSheetAction(
          child: Text(
            reactiveTitle,
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF000000),
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(-1),
        ),
      );
    }
    actions.add(
      CupertinoActionSheetAction(
        isDestructiveAction: true,
        child: Text(
          deleteTitle,
          style: const TextStyle(
            fontSize: 16.0,
            color: Color(0xDDFF0000),
          ),
        ),
        onPressed: () => Navigator.of(context).maybePop(2),
      ),
    );
    return actions;
  }

  final act = await showCupertinoModalPopup<int>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      message: Text('选择一个对此任务的操作：'),
      actions: actions(context),
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          '取消',
          style: const TextStyle(
            fontSize: 16.0,
            color: Color(0xFF000000),
          ),
        ),
        onPressed: Navigator.of(context).maybePop,
      ),
    ),
  );
  if (act == null) {
    (onCancel ?? () {})();
  } else if (act == 0) {
    (onDetail ?? () {})();
  } else if (act == 1) {
    (onDone ?? () {})();
  } else if (act == 2) {
    (onDelete ?? () {})();
  } else if (act == -1) {
    (onReactive ?? () {})();
  }
}
