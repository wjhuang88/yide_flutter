import 'package:flutter/material.dart';
import 'package:yide/screens/detail_screen/detail_list_screen.dart';

class SplashScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Color(0xff262626),
          elevation: 0.0,
          brightness: Brightness.dark,
        ),
        preferredSize: Size.fromHeight(30),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, DetailListScreen.routeName);
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash.png'),
            ),
            color: Color(0xff262626)
          ),
        ),
      )
    );
  }
  
}