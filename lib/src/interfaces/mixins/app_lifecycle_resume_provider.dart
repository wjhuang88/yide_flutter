import 'package:flutter/widgets.dart';

mixin AppLifecycleResumeProvider<T extends StatefulWidget> on State<T> {
  _LifecycleListener listener;
  void onResumed();

  @override
  void initState() {
    super.initState();
    listener = _LifecycleListener(onResumed);
    WidgetsBinding.instance.addObserver(listener);
    print('ResumeProvider installed for ${this.runtimeType}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(listener);
    print('ResumeProvider uninstalled for ${this.runtimeType}');
    super.dispose();
  }
}

class _LifecycleListener extends WidgetsBindingObserver {
  final VoidCallback callback;

  _LifecycleListener(this.callback);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (callback != null) {
          callback();
        }
        break;
      default:
      // donothing.
    }
  }
}
