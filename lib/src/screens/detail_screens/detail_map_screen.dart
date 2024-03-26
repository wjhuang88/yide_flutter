import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yide/src/components/location_map_view.dart';
import 'package:yide/src/components/native_oneline_textfield.dart';
import 'package:yide/src/interfaces/navigatable.dart';
import 'package:yide/src/models/geo_data.dart';
import 'package:yide/src/notification.dart';
import 'package:yide/src/tools/common_tools.dart';
import 'package:yide/src/tools/icon_tools.dart';

class DetailMapScreen extends StatefulWidget implements Navigatable {
  final AroundData? address;

  const DetailMapScreen({super.key, this.address});
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

  @override
  bool get withMene => false;

  @override
  String get name => '地址';
}

const _gradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF975ED8), Color(0xFF7352D0)],
);

const _shadow = const [
  BoxShadow(
    offset: Offset(0.0, 6.0),
    blurRadius: 23.0,
    color: Color(0x8A4F3A8C),
  ),
];

const _gradientDecoration = const BoxDecoration(
  gradient: _gradient,
  borderRadius: BorderRadius.all(
    Radius.circular(10.0),
  ),
  boxShadow: _shadow,
);

const _iconDecoration = BoxDecoration(
  gradient: _gradient,
  boxShadow: _shadow,
  borderRadius: BorderRadius.all(
    Radius.circular(30.0),
  ),
);

class _DetailMapScreenState extends State<DetailMapScreen>
    with TickerProviderStateMixin {
  _DetailMapScreenState(this._selectedAddress);
  LocationMapController? _locationMapController;

  AroundData? _selectedAddress;
  List<AroundData> _arounds = [];

  AnimationController? _pinJumpController;
  Animation? _pinJumpAnim;

  AnimationController? _bottomBoxController;
  Animation? _bottomBoxAnim;

  ScrollController _listController = ScrollController();
  double _panelHeight = 0.0;
  bool _isLockHeight = false;
  bool _backProcessing = false;

  NativeOnelineTextFieldController _textEditingController =
      NativeOnelineTextFieldController();

  Timer? _inputTime;

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
      vsync: this,
      value: 1.0,
      duration: Duration(milliseconds: 500),
    );
    _pinJumpAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pinJumpController!,
        curve: Curves.decelerate,
        reverseCurve: Curves.elasticIn,
      ),
    );
    _pinJumpAnim?.addListener(() => setState(() {}));

    _bottomBoxController = AnimationController(
      vsync: this,
      value: 0.0,
      duration: Duration(milliseconds: 400),
    );
    _bottomBoxAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _bottomBoxController!,
          curve: Curves.decelerate,
          reverseCurve: Curves.decelerate.flipped),
    );
    _bottomBoxAnim?.addListener(() => setState(() {}));

    _listController.addListener(() {
      final offset = _listController.offset;
      final min = _listController.position.minScrollExtent;
      final max = _listController.position.maxScrollExtent;

      _textEditingController.unfocus();
      if (offset <= min) {
        _isLockHeight = false;
      } else if (min != max) {
        _isLockHeight = true;
      }

      if (_isLockHeight) {
        _bottomBoxController?.forward();
      } else {
        _bottomBoxController?.reverse();
      }

      if (offset <= min - 70) {
        if (_backProcessing) {
          return;
        }
        _backProcessing = true;
        haptic();
        PopRouteNotification().dispatch(context);
      }
    });
  }

  @override
  void dispose() {
    _pinJumpController?.dispose();
    _bottomBoxController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final originPanelHeight = screenHeight / 2.5;
    final baseHeight = originPanelHeight - (originPanelHeight % 70);

    final minPanelHeight = baseHeight;
    final maxPanelHeight = screenHeight * 0.78 - 60.0;
    _panelHeight = minPanelHeight +
        (maxPanelHeight - minPanelHeight) * _bottomBoxAnim?.value;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
            brightness: Brightness.dark,
            textTheme: CupertinoTextThemeData(primaryColor: Color(0xFFFAB807))),
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
                  _textEditingController.unfocus();
                  _textEditingController.clear();
                  await _pinJumpController?.forward();
                  await _pinJumpController?.reverse();
                },
                onRegionChanged: (around, coord) async {
                  setState(() {
                    _arounds = around;
                    _isLoadingValue = false;
                  });
                },
                onTips: (tips) {
                  //print("get tips: $tips");
                },
                onMapTap: (coord) {
                  _textEditingController.unfocus();
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
                  offset: Offset(0.0, -10.0 * _pinJumpAnim?.value),
                  child: const Icon(
                    CupertinoIcons.location_solid,
                    color: Color(0xFFFAB807),
                    size: 40.0,
                  )),
            ),
            Positioned(
              bottom: 10.0,
              left: 10.0,
              right: 10.0,
              child: SafeArea(
                maintainBottomViewPadding: true,
                child: Column(
                  children: <Widget>[
                    _buildSearchBar(),
                    const SizedBox(
                      height: 10.0,
                    ),
                    _LocationListPanel(
                      isLoading: _isLoading,
                      panelHeight: _panelHeight,
                      values: _arounds,
                      controller: _listController,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Container(
                margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                decoration: _iconDecoration,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 55.0,
                  child: const Icon(
                    CupertinoIcons.left_chevron,
                    color: Color(0x99FFFFFF),
                    size: 25.0,
                  ),
                  onPressed: () => PopRouteNotification().dispatch(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: _gradientDecoration,
            child: Row(
              children: <Widget>[
                const Icon(
                  CupertinoIcons.search,
                  color: Color(0xFFFFFFFF),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: NativeOnelineTextField(
                    autofocus: false,
                    height: 50.0,
                    alignment: Alignment.centerLeft,
                    controller: _textEditingController,
                    placeholder: '搜索关键字',
                    onChanged: _onKeywordChange,
                    onSubmitted: (keyword) async {
                      if (keyword.isEmpty) {
                        _locationMapController?.forceTriggerRegionChange();
                        return;
                      }
                      final list =
                          await _locationMapController?.searchAround(keyword);
                      setState(() {
                        _arounds = list ?? [];
                      });
                    },
                    onFocus: () {
                      _isLockHeight = true;
                      _bottomBoxController?.forward();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 5.0,
        ),
        !_isLockHeight
            ? DecoratedBox(
                decoration: _gradientDecoration,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 50.0,
                  child: Icon(
                    buildCupertinoIconData(0xf474),
                    color: const Color(0x99FFFFFF),
                    size: 30.0,
                  ),
                  onPressed: _locationMapController?.backToUserLocation,
                ),
              )
            : DecoratedBox(
                decoration: _gradientDecoration,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 50.0,
                  child: Icon(
                    CupertinoIcons.down_arrow,
                    color: const Color(0x99FFFFFF),
                    size: 20.0,
                  ),
                  onPressed: () {
                    _isLockHeight = false;
                    _textEditingController.unfocus();
                    _bottomBoxController?.reverse();
                  },
                ),
              )
      ],
    );
  }

  Future<void> _onKeywordChange(String keyword) async {
    _inputTime?.cancel();
    _inputTime = Timer(const Duration(milliseconds: 500), () async {
      if (keyword.isEmpty) {
        _locationMapController?.forceTriggerRegionChange();
        return;
      }
      final list = await _locationMapController?.searchAround(keyword);
      setState(() {
        _arounds = list ?? [];
      });
    });
  }
}

class _LocationListPanel extends StatelessWidget {
  const _LocationListPanel({
    super.key,
    required this.panelHeight,
    required List<AroundData> values,
    this.isLoading = false,
    this.controller,
  }) : _arounds = values;

  final double panelHeight;
  final List<AroundData> _arounds;
  final bool isLoading;

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: panelHeight,
      alignment: Alignment.center,
      decoration: _gradientDecoration,
      child: isLoading
          ? CupertinoActivityIndicator(
              radius: 15.0,
            )
          : _buildListBody(),
    );
  }

  ListView _buildListBody() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _arounds.length,
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(
          parent: const BouncingScrollPhysics()),
      itemExtent: 70.0,
      itemBuilder: (context, i) {
        final data = _arounds[i];
        final dist = data == null
            ? '-'
            : data.distance! < 30
                ? '30m内'
                : data.distance! < 1000
                    ? '${data.distance} m'
                    : '${(data.distance! / 1000).toStringAsFixed(1)} km';
        final addr = data.address;
        var border;
        if (i == 0) {
          border = const Border.fromBorderSide(BorderSide.none);
        } else {
          border = const Border(
            top: BorderSide(
              color: Color(0x88FFFFFF),
              width: 0.2,
            ),
          );
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            PopRouteNotification(result: _arounds[i]).dispatch(context);
          },
          child: Container(
            height: 70.0,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              border: border,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  buildCupertinoIconData(0xf37c),
                  color: const Color(0x88FFFFFF),
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
                        data.name ?? '',
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
    );
  }
}
