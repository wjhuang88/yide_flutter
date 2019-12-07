import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yide/components/location_map_view.dart';
import 'package:yide/interfaces/navigatable.dart';
import 'package:yide/models/geo_data.dart';
import 'package:yide/tools/icon_tools.dart';

class DetailMapScreen extends StatefulWidget implements Navigatable {
  final AroundData address;

  const DetailMapScreen({Key key, this.address}) : super(key: key);
  @override
  _DetailMapScreenState createState() => _DetailMapScreenState(address);

  @override
  Route get route {
    return PageRouteBuilder<AroundData>(
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

const gradientDecoration = const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF975ED8), Color(0xFF7352D0)],
  ),
  borderRadius: BorderRadius.all(
    Radius.circular(10.0),
  ),
  boxShadow: [
    BoxShadow(
      offset: Offset(0.0, 6.0),
      blurRadius: 23.0,
      color: Color(0x8A4F3A8C),
    ),
  ],
);

class _DetailMapScreenState extends State<DetailMapScreen>
    with SingleTickerProviderStateMixin {
  _DetailMapScreenState(this._selectedAddress);
  LocationMapController _locationMapController;

  AroundData _selectedAddress;
  List<AroundData> _arounds = List<AroundData>();

  AnimationController _pinJumpController;
  Animation _pinJumpAnim;

  bool _isLoadingValue = true;
  bool get _isLoading => _isLoadingValue;
  set _isLoading(bool value) {
    setState(() {
      _isLoadingValue = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _locationMapController = LocationMapController();
    _pinJumpController = AnimationController(
        vsync: this, value: 1.0, duration: Duration(milliseconds: 500));
    _pinJumpAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pinJumpController,
        curve: Curves.decelerate,
        reverseCurve: Curves.elasticIn,
      ),
    );
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final originPanelHeight = screenHeight / 3;
    final panelHeight = originPanelHeight - (originPanelHeight % 50) + 20;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: LocationMapView(
              controller: _locationMapController,
              initCenter: _selectedAddress?.coordinate,
              cameraDegree: 30.0,
              zoomLevel: 16.0,
              showsCompass: true,
              compassOffset: const Offset(-10.0, 40.0),
              showsScale: false,
              showsUserLocation: true,
              centerOffset: const FractionalOffset(0.5, 0.3),
              onRegionStartChanging: () async {
                _isLoading = true;
                await _pinJumpController.forward();
                await _pinJumpController.reverse();
              },
              onRegionChanged: (around, coord) async {
                setState(() {
                  _arounds = around;
                  _isLoadingValue = false;
                });
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
            top: screenHeight * 0.3 - 40.0,
            left: screenWidth * 0.5 - 20.0,
            child: Transform.translate(
                offset: Offset(0.0, -10.0 * _pinJumpAnim.value),
                child: const Icon(
                  CupertinoIcons.location_solid,
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
            bottom: 10.0,
            left: 10.0,
            right: 10.0,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 50.0,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: gradientDecoration,
                    child: CupertinoTextField(
                      maxLines: 1,
                      placeholder: '搜索关键字',
                      style: const TextStyle(fontSize: 16.0, color: Color(0xFFFFFFFF)),
                      placeholderStyle: const TextStyle(fontSize: 16.0, color: Color(0x66FFFFFF)),
                      clearButtonMode: OverlayVisibilityMode.editing,
                      prefix: Icon(CupertinoIcons.search),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  _LocationListPanel(
                      isLoading: _isLoading,
                      panelHeight: panelHeight,
                      values: _arounds),
                ],
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
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF975ED8), Color(0xFF7352D0)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0.0, 6.0),
                      blurRadius: 23.0,
                      color: Color(0x8A4F3A8C),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.left_chevron,
                          color: Color(0x99FFFFFF),
                          size: 25.0,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const Divider(
                      color: Color(0x99FFFFFF),
                      height: 0.0,
                      thickness: 0.1,
                    ),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          buildCupertinoIconData(0xf474),
                          color: Color(0x99FFFFFF),
                          size: 22.0,
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

class _LocationListPanel extends StatelessWidget {
  const _LocationListPanel({
    Key key,
    @required this.panelHeight,
    @required List<AroundData> values,
    this.isLoading = false,
  })  : _arounds = values,
        super(key: key);

  final double panelHeight;
  final List<AroundData> _arounds;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: panelHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: gradientDecoration,
      child: isLoading
          ? CupertinoActivityIndicator(
              radius: 15.0,
            )
          : ListView.separated(
              itemCount: _arounds.length,
              separatorBuilder: (context, i) => const Divider(
                color: Colors.white,
                thickness: 0.2,
              ),
              itemBuilder: (context, i) {
                final data = _arounds[i];
                final dist = data.distance < 30 ? '30m内' : '${data.distance}m';
                final addr = data.address;
                return GestureDetector(
                  onTap: () =>
                      Navigator.of(context).maybePop<AroundData>(_arounds[i]),
                  child: Container(
                    height: 50.0,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          buildCupertinoIconData(0xf37c),
                          color: Color(0x88FFFFFF),
                          size: 20.0,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                data.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w200),
                              ),
                              Text(
                                '$dist | $addr',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0x88FFFFFF),
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w200),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
