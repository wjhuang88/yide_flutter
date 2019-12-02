import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yide/components/location_map_view.dart';
import 'package:yide/interfaces/navigatable.dart';
import 'package:yide/models/address_data.dart';

class DetailMapScreen extends StatefulWidget implements Navigatable {
  @override
  _DetailMapScreenState createState() => _DetailMapScreenState();

  @override
  Route get route {
    return PageRouteBuilder(
      pageBuilder: (context, anim1, anim2) => this,
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
}

class _DetailMapScreenState extends State<DetailMapScreen>
    with SingleTickerProviderStateMixin {
  LocationMapController _locationMapController;

  List<AroundData> _arounds = List<AroundData>();

  AnimationController _pinJumpController;
  Animation _pinJumpAnim;

  @override
  void initState() {
    super.initState();
    _locationMapController = LocationMapController();
    _pinJumpController = AnimationController(
        vsync: this, value: 1.0, duration: Duration(milliseconds: 150));
    _pinJumpAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _pinJumpController, curve: Curves.easeInOutCubic));
    _pinJumpAnim.addListener(() {
      setState(() {
        // Trigger update.
      });
    });
  }

  @override
  void dispose() {
    _pinJumpController.dispose();
    super.dispose();
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
              onRegionChanged: (around, coord) async {
                setState(() {
                  _arounds = around;
                });
                await _pinJumpController.forward();
                await _pinJumpController.reverse();
              },
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
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3 - 40.0,
            left: MediaQuery.of(context).size.width * 0.5 - 20.0,
            child: Transform.translate(
                offset: Offset(0.0, -10.0 * _pinJumpAnim.value),
                child: const Icon(
                  FontAwesomeIcons.mapPin,
                  color: Color(0xFFFAB807),
                  size: 40.0,
                )),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: 50.0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x55000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height / 3,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8346C8), Color(0xFF523F88)]),
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: ListView.separated(
                  itemCount: _arounds.length,
                  separatorBuilder: (context, i) => const Divider(
                    color: Colors.white,
                    thickness: 0.2,
                  ),
                  itemBuilder: (context, i) {
                    final data = _arounds[i];
                    final dist =
                        data.distance < 50 ? '50m内' : '${data.distance}m';
                    final addr = data.address;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            data.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18.0),
                          ),
                          Text(
                            '$dist | $addr',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xFFFAB807), fontSize: 14.0),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 15.0, left: 15.0),
              child: Container(
                height: 100.0,
                width: 45.0,
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    boxShadow: [
                      BoxShadow(color: Color(0x44523F88), blurRadius: 3.0)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
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
                    const Divider(
                      color: Color(0xFF8346C8),
                      height: 0.0,
                      thickness: 0.1,
                    ),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          FontAwesomeIcons.locationArrow,
                          color: Color(0xFF8346C8),
                          size: 14.0,
                        ),
                        onPressed: () {
                          _locationMapController.backToUserLocation();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
