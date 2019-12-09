import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:yide/src/models/geo_data.dart';

class LocationMapController {
  _LocationMapViewState _state;

  Future<void> backToUserLocation() async => _state?._backToUserLocation();

  Future<AddressData> getUserAddress() async {
    final map = await _state?._getUserAddress();
    return AddressData.fromMap(map);
  }

  Future<List<AroundData>> searchAround(String keyword) async =>
      _state?._searchAround(keyword);

  Future<void> forceTriggerRegionChange() async =>
      _state?._forceTriggerRegionChange();
}

class LocationMapView extends StatefulWidget {
  final double cameraDegree;
  final double zoomLevel;
  final Offset logoOffset;
  final bool showsCompass;
  final Offset compassOffset;
  final bool showsScale;
  final Offset scaleOffset;
  final bool showsUserLocation;
  final FractionalOffset centerOffset;
  final Coordinate initCenter;
  final void Function(List<AroundData> around, Coordinate coordinate)
      onRegionChanged;
  final VoidCallback onRegionStartChanging;
  final void Function(List<String> tips) onTips;
  final void Function(Coordinate coord) onMapTap;

  final LocationMapController controller;

  const LocationMapView({
    Key key,
    this.cameraDegree,
    this.zoomLevel,
    this.logoOffset,
    this.showsCompass,
    this.compassOffset,
    this.showsScale,
    this.scaleOffset,
    this.showsUserLocation,
    this.centerOffset,
    this.controller,
    this.onRegionChanged,
    this.initCenter,
    this.onRegionStartChanging,
    this.onTips,
    this.onMapTap,
  }) : super(key: key);

  @override
  _LocationMapViewState createState() => _LocationMapViewState(controller);
}

class _LocationMapViewState extends State<LocationMapView> {
  _LocationMapViewState(this._controller);
  LocationMapController _controller;

  MethodChannel platform;

  @override
  void initState() {
    super.initState();
    _controller ??= LocationMapController();
    _controller._state = this;
    platform = const MethodChannel("yide_map_view_method");

    if (widget.onRegionChanged != null) {
      platform.setMethodCallHandler((call) async {
        if (call.method == 'onRegionChanged' && (call.arguments is Map)) {
          final args = call.arguments as Map;
          _makeAroundDataCallback(args);
        } else if (call.method == 'onRegionStartChanging' &&
            widget.onRegionStartChanging != null) {
          widget.onRegionStartChanging();
        } else if (call.method == 'onTips' && widget.onTips != null) {
          final tips = call.arguments as List;
          widget.onTips(
            tips.map((tip) => tip as String).toList(),
          );
        } else if (call.method == 'onMapTap' && widget.onMapTap != null) {
          final coordList = call.arguments as List;
          widget.onMapTap(
            Coordinate.fromList(coordList.map((d) => d as double).toList()),
          );
        }
      });
    }
  }

  void _makeAroundDataCallback(Map args) {
    final coordinateList = args['coordinate'] as List;
    final aroundMapList = args['around'] as List;
    final aroundList = _parseAroundData(aroundMapList);
    final coordinate =
        Coordinate.fromList(coordinateList.map((d) => d as double).toList());
    if (widget.onRegionChanged != null) {
      widget.onRegionChanged(aroundList, coordinate);
    }
  }

  List<AroundData> _parseAroundData(List rawList) => rawList
      .map((map) => AroundData.fromMap(
          (map as Map).map((k, v) => MapEntry(k as String, v))))
      .toList()..sort((a, b) => a.distance - b.distance);

  Future<void> _backToUserLocation() async {
    return platform.invokeMethod<void>('backToUserLocation');
  }

  Future<void> _forceTriggerRegionChange() async {
    return platform.invokeMethod<void>('forceTriggerRegionChange');
  }

  Future<Map<String, String>> _getUserAddress() async {
    return platform.invokeMapMethod<String, String>('getUserAddress');
  }

  Future<List<AroundData>> _searchAround(String keyword) async {
    final aroundMapList =
        await platform.invokeListMethod('searchAround', keyword);
    return _parseAroundData(aroundMapList ?? const []);
  }

  @override
  Widget build(BuildContext context) {
    final params = <String, dynamic>{
      "cameraDegree": widget.cameraDegree ?? 30.0,
      "zoomLevel": widget.zoomLevel ?? 16.0,
      "logoOffset": [
        widget.logoOffset?.dx ?? 0.0,
        widget.logoOffset?.dy ?? 0.0
      ],
      "showsCompass": widget.showsCompass ?? true,
      "compassOffset": [
        widget.compassOffset?.dx ?? 0.0,
        widget.compassOffset?.dy ?? 0.0
      ],
      "showsScale": widget.showsScale ?? true,
      "scaleOffset": [
        widget.scaleOffset?.dx ?? 0.0,
        widget.scaleOffset?.dy ?? 0.0
      ],
      "showsUserLocation": widget.showsUserLocation ?? true,
      "centerOffset": [
        widget.centerOffset?.dx ?? 0.0,
        widget.centerOffset?.dy ?? 0.0
      ],
    };
    if (widget.initCenter != null) {
      params['initCenter'] = [
        widget.initCenter.latitude,
        widget.initCenter.longitude
      ];
    }
    final codec = const StandardMessageCodec();

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: "yide_map_view",
        creationParams: params,
        creationParamsCodec: codec,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: "yide_map_view",
        creationParams: params,
        creationParamsCodec: codec,
      );
    } else {
      return Text("Platform: $defaultTargetPlatform is not supported.");
    }
  }
}
