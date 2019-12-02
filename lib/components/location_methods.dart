import 'package:flutter/services.dart';
import 'package:yide/models/address_data.dart';

class LocationMethods {
  static const _platform = const MethodChannel("amap_location_method");

  factory LocationMethods._() {
    return null;
  }

  static Future<LocationData> getLocation() async {
    final result =
        await _platform.invokeMapMethod<String, dynamic>('getLocation');
    return LocationData.fromMap(result);
  }
}
