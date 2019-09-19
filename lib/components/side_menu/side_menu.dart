import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();

}

class _SideMenuState extends State<SideMenu> {

  bool clipped = true;

  @override
  Widget build(BuildContext context) {
    if (clipped) {
      return ClipPath(
        child: _Menu(),
        clipper: _MenuClipper(),
      );
    } else {
      return _Menu();
    }
  }

}

class _Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text('今日', style: TextStyle(fontSize: 20, color: Colors.white),),
            ),
          )
        ],
      ),
      color: Color(0xff262626),
      width: MediaQuery.of(context).size.width / 2,
    );
  }
}

class _MenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(20, 0);
    var firstControlPoint = Offset(size.width * 1.5, size.height / 2);
    var firstEndPont = Offset(20, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPont.dx, firstEndPont.dy);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }

}