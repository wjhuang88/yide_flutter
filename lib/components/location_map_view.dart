import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LocationMapController {
  _LocationMapViewState _state;

  void backToUserLocation() {
    _state?._backToUserLocation();
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
      this.controller})
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
  }

  void _backToUserLocation() {
    platform.invokeMethod('backToUserLocation');
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
