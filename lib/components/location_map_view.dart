import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yide/models/geo_data.dart';

class LocationMapController {
  _LocationMapViewState _state;

  Future<void> backToUserLocation() async {
    return _state?._backToUserLocation();
  }

  Future<AddressData> getUserAddress() async {
    final map = await _state?._getUserAddress();
    return AddressData.fromMap(map);
  }
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

  final LocationMapController controller;

  const LocationMapView(
      {Key key,
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
      this.initCenter})
      : super(key: key);

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
          final coordinateList = args['coordinate'] as List;
          final aroundMapList = args['around'] as List;
          final aroundList = aroundMapList
              .map((map) => AroundData.fromMap(
                  (map as Map).map((k, v) => MapEntry(k as String, v))))
              .toList();
          final coordinate = Coordinate.fromList(
              coordinateList.map((d) => d as double).toList());
          widget.onRegionChanged(aroundList, coordinate);
        }
      });
    }
  }

  Future<void> _backToUserLocation() async {
    return await platform.invokeMethod<void>('backToUserLocation');
  }

  Future<Map<String, String>> _getUserAddress() async {
    return await platform.invokeMapMethod<String, String>('getUserAddress');
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
