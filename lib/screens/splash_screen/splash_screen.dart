import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Color(0xff262626),
          elevation: 0.0,
        ),
        preferredSize: Size.fromHeight(30),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, 'test');
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
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