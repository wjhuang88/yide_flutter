import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:yide/src/models/geo_data.dart';

class LocationMapController {
  late _LocationMapViewState _state;

  Future<void> backToUserLocation() async => _state._backToUserLocation();

  Future<AddressData> getUserAddress() async {
    final map = await _state._getUserAddress();
    return AddressData.fromMap(map!);
  }

  Future<List<AroundData>> searchAround(String keyword) async =>
      _state._searchAround(keyword);

  Future<void> forceTriggerRegionChange() async =>
      _state._forceTriggerRegionChange();
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
  final Coordinate? initCenter;
  final void Function(List<AroundData> around, Coordinate coordinate)
      onRegionChanged;
  final VoidCallback onRegionStartChanging;
  final void Function(List<AroundData> tips) onTips;
  final void Function(Coordinate coord) onMapTap;

  final LocationMapController? controller;

  const LocationMapView({
    super.key,
    required this.cameraDegree,
    required this.zoomLevel,
    this.logoOffset = const Offset(0, 0),
    required this.showsCompass,
    required this.compassOffset,
    required this.showsScale,
    this.scaleOffset = const Offset(0, 0),
    required this.showsUserLocation,
    required this.centerOffset,
    this.controller,
    required this.onRegionChanged,
    this.initCenter,
    required this.onRegionStartChanging,
    required this.onTips,
    required this.onMapTap,
  });

  @override
  _LocationMapViewState createState() => _LocationMapViewState(controller);
}

class _LocationMapViewState extends State<LocationMapView> {
  _LocationMapViewState(this._controller);
  late LocationMapController? _controller;

  late MethodChannel platform;

  @override
  void initState() {
    super.initState();
    _controller?._state = this;
    platform = const MethodChannel("yide_map_view_method");

    platform.setMethodCallHandler((call) async {
      if (call.method == 'onRegionChanged' && (call.arguments is Map)) {
        final args = call.arguments as Map;
        _makeAroundDataCallback(args);
      } else if (call.method == 'onRegionStartChanging') {
        widget.onRegionStartChanging();
      } else if (call.method == 'onTips') {
        final tips = call.arguments as List;
        widget.onTips(
          _parseAroundData(tips),
        );
      } else if (call.method == 'onMapTap') {
        final coordList = call.arguments as List;
        widget.onMapTap(
          Coordinate.fromList(coordList.map((d) => d as double).toList()),
        );
      }
    });
  }

  void _makeAroundDataCallback(Map args) {
    final coordinateList = args['coordinate'] as List;
    final aroundMapList = args['around'] as List;
    final aroundList = _parseAroundData(aroundMapList);
    final coordinate =
        Coordinate.fromList(coordinateList.map((d) => d as double).toList());
    widget.onRegionChanged(aroundList, coordinate);
  }

  List<AroundData> _parseAroundData(List rawList) => rawList
      .map(
        (map) => AroundData.fromMap(
          (map as Map).map(
            (k, v) => MapEntry(k as String, v),
          ),
        ),
      )
      .toList()
    ..sort((a, b) => a.distance! - b.distance!);

  Future<void> _backToUserLocation() async {
    return platform.invokeMethod<void>('backToUserLocation');
  }

  Future<void> _forceTriggerRegionChange() async {
    return platform.invokeMethod<void>('forceTriggerRegionChange');
  }

  Future<Map<String, String>?> _getUserAddress() async {
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
      "cameraDegree": widget.cameraDegree,
      "zoomLevel": widget.zoomLevel,
      "logoOffset": [widget.logoOffset.dx, widget.logoOffset.dy],
      "showsCompass": widget.showsCompass,
      "compassOffset": [widget.compassOffset.dx, widget.compassOffset.dy],
      "showsScale": widget.showsScale,
      "scaleOffset": [widget.scaleOffset.dx, widget.scaleOffset.dy],
      "showsUserLocation": widget.showsUserLocation,
      "centerOffset": [widget.centerOffset.dx, widget.centerOffset.dy],
    };
    params['initCenter'] = [
      widget.initCenter?.latitude,
      widget.initCenter?.longitude
    ];
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
