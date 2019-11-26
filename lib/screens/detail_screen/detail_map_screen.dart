import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DetailMapScreen extends StatelessWidget {

  static const String routeName = 'detail_map';
  static Route get pageRoute => _buildRoute(DetailMapScreen());

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      child: Column(
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: SizedBox(),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 1.8,
            child: _buildPlatformView(),
          ),
          
        ],
      ),
    );
  }

  Widget _buildPlatformView() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: "yide_map_view",
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: "yide_map_view",
      );
    } else {
      return Text("Platform: $defaultTargetPlatform is not supported.");
    }
  }

}

_buildRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) => child,
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, anim1, anim2, child) {
      final anim1Curved = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic
        ),
      );
      return FractionalTranslation(
        translation: Offset(0.0, 1 - anim1Curved.value),
        child: Opacity(
          opacity: anim1Curved.value,
          child: child,
        ),
      );
    },
  );
}