import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/components/location_map_view.dart';

class DetailMapScreen extends StatefulWidget {
  static const String routeName = 'detail_map';
  static Route get pageRoute => _buildRoute(DetailMapScreen());

  @override
  _DetailMapScreenState createState() => _DetailMapScreenState();
}

class _DetailMapScreenState extends State<DetailMapScreen> {
  LocationMapController _locationMapController;

  @override
  void initState() {
    super.initState();
    _locationMapController = LocationMapController();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: LocationMapView(
              controller: _locationMapController,
              cameraDegree: 30.0,
              zoomLevel: 16.0,
              showsCompass: true,
              compassOffset: Offset(-10.0, 40.0),
              showsScale: false,
              showsUserLocation: true,
              centerOffset: FractionalOffset(0.5, 0.3),
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height / 4,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xDD8346C8), Color(0xDD523F88)]),
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Column(
                  children: <Widget>[
                    //Icon(FontAwesomeIcons.search),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 50.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x55000000), Color(0x00000000)],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 15.0, left: 15.0),
              child: Container(
                height: 110.0,
                width: 45.0,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    boxShadow: [
                      BoxShadow(color: Color(0x44523F88), blurRadius: 3.0)
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: CupertinoButton(
                            child: const Icon(
                              FontAwesomeIcons.chevronLeft,
                              color: Color(0xFF8346C8),
                              size: 14.0,
                            ),
                            onPressed: () {
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                      ),
                      const Divider(
                        color: Color(0xFF8346C8),
                        height: 0.0,
                      ),
                      Expanded(
                        child: Center(
                          child: CupertinoButton(
                            child: const Icon(
                              FontAwesomeIcons.locationArrow,
                              color: Color(0xFF8346C8),
                              size: 14.0,
                            ),
                            onPressed: () {
                              _locationMapController.backToUserLocation();
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            reverseCurve: Curves.easeInCubic),
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
