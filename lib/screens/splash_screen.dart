import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/screens/timeline_list_screen.dart';

class SplashScreen extends StatelessWidget {

  static const String routeName = 'splash';

  static Route get pageRoute => _buildRoute();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushNamed(context, TimelineListScreen.routeName);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: const Icon(FontAwesomeIcons.jedi, size: 150.0, color: Color(0xFFE4CEFF),),
              ),
            ),
            Expanded(
              child: Center(
                child: const Text('点击继续', style: TextStyle(fontSize: 14.0, color: Color(0xFFE4CEFF)),),
              ),
            ),
          ],
        ),
      )
    );
  }
  
}

_buildRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, anim1, anim2) {
      return SplashScreen();
    },
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: 1.0 - anim2.value,
        child: Opacity(
          opacity: 1 - anim2.value,
          child: child,
        ),
      );
    },
  );
}