import 'package:flutter/services.dart';

import 'package:yide/src/models/geo_data.dart';

class LocationMethods {
  static const _platform = const MethodChannel("amap_location_method");

  factory LocationMethods._() {
    return null;
  }

  static Future<LocationData> getLocation() async {
    final result = await _platform.invokeMapMethod<String, dynamic>('getLocation');
    return LocationData.fromMap(result);
  }

  static Future<WeatherData> getWeather(String adCode) async {
    final result =
        await _platform.invokeMapMethod<String, String>('getWeather', adCode);
    return WeatherData.fromMap(result);
  }
}
