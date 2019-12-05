class AddressData {
  final String country;
  final String province;
  final String city;
  final String citycode;
  final String district;
  final String adcode;
  final String township;
  final String towncode;
  final String neighborhood;
  final String building;
  final String formattedAddress;

  AddressData(
      {this.country,
      this.province,
      this.city,
      this.citycode,
      this.district,
      this.adcode,
      this.township,
      this.towncode,
      this.neighborhood,
      this.building,
      this.formattedAddress});

  AddressData.fromMap(Map<String, String> map)
      : assert(map != null),
        this.country = map["country"],
        this.province = map["province"],
        this.city = map["city"],
        this.citycode = map["citycode"],
        this.district = map["district"],
        this.adcode = map["adcode"],
        this.township = map["township"],
        this.towncode = map["towncode"],
        this.neighborhood = map["neighborhood"],
        this.building = map["building"],
        this.formattedAddress = map["formattedAddress"];

  @override
  String toString() {
    return '''{
      country: $country,
      province: $province,
      city: $city,
      citycode: $citycode,
      district: $district,
      adcode: $adcode,
      township: $township,
      towncode: $towncode,
      neighborhood: $neighborhood,
      building: $building,
      formattedAddress: $formattedAddress,
    }''';
  }
}

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate({this.latitude, this.longitude});
  Coordinate.fromList(List<dynamic> list)
      : assert(list != null && list.length >= 2),
        this.latitude = list[0] as double,
        this.longitude = list[1] as double;

  @override
  String toString() {
    return '{latitude: $latitude, longitude: $longitude}';
  }
}

class AroundData {
  final String id;
  final String name;
  final int distance;
  final String address;
  final Coordinate coordinate;

  AroundData(
      {this.address, this.coordinate, this.id, this.name, this.distance});
  AroundData.fromMap(Map<String, dynamic> map)
      : assert(map != null),
        this.id = map['id'] as String,
        this.name = map['name'] as String,
        this.distance = map['distance'] as int,
        this.address = map['address'] as String,
        this.coordinate = Coordinate(
            latitude: map['latitude'] as double,
            longitude: map['longitude'] as double);

  @override
  String toString() {
    return '{address: $address, coordinate: $coordinate}';
  }
}

class LocationData {
  final String country;
  final String province;
  final String city;
  final String citycode;
  final String district;
  final String street;
  final String adcode;
  final String formattedAddress;
  final Coordinate coordinate;

  LocationData({
    this.country,
    this.province,
    this.city,
    this.citycode,
    this.district,
    this.street,
    this.adcode,
    this.formattedAddress,
    this.coordinate,
  });

  LocationData.fromMap(Map<String, dynamic> map)
      : assert(map != null),
        this.country = map['country'] as String,
        this.province = map['province'] as String,
        this.city = map['city'] as String,
        this.citycode = map['citycode'] as String,
        this.district = map['district'] as String,
        this.street = map['street'] as String,
        this.adcode = map['adcode'] as String,
        this.formattedAddress = map['formattedAddress'] as String,
        this.coordinate = Coordinate(
            latitude: map['latitude'] as double,
            longitude: map['longitude'] as double);
}

class WeatherData {
  final String adcode;
  final String province;
  final String city;
  final String weather;
  final String temperature;
  final String windDirection;
  final String windPower;
  final String humidity;
  final String reportTime;

  WeatherData(
      {this.adcode,
      this.province,
      this.city,
      this.weather,
      this.temperature,
      this.windDirection,
      this.windPower,
      this.humidity,
      this.reportTime});

  WeatherData.fromMap(Map<String, String> map)
      : assert(map != null),
        this.adcode = map['adcode'],
        this.province = map['province'],
        this.city = map['city'],
        this.weather = map['weather'],
        this.temperature = map['temperature'],
        this.windDirection = map['windDirection'],
        this.windPower = map['windPower'],
        this.humidity = map['humidity'],
        this.reportTime = map['reportTime'];

  @override
  String toString() {
    return '''{
      adcode: $adcode,
      province: $province,
      city: $city,
      weather: $weather,
      temperature: $temperature,
      windDirection: $windDirection,
      windPower: $windPower,
      humidity: $humidity,
      reportTime: $reportTime,
    }''';
  }
}

Map<String, String> weatherImageMap = {
  '晴': 'assets/images/weather/sunny.png',
  '多云': 'assets/images/weather/cloudy.png',
  '阴': 'assets/images/weather/overcast.png',
  '阵雨': 'assets/images/weather/shower.png',
  '雷阵雨': 'assets/images/weather/thunderstorm.png',
  '雷阵雨并伴有冰雹': 'assets/images/weather/thunder_hail.png',
  '雨夹雪': 'assets/images/weather/sleet.png',
  '小雨': 'assets/images/weather/light_rain.png',
  '中雨': 'assets/images/weather/moderate_rain.png',
  '大雨': 'assets/images/weather/heavy_rain.png',
  '暴雨': 'assets/images/weather/rainstorm.png',
  '大暴雨': 'assets/images/weather/heavy_rainstorm.png',
  '特大暴雨': 'assets/images/weather/super_rainstorm.png',
  '阵雪': 'assets/images/weather/snow_shower.png',
  '小雪': 'assets/images/weather/light_snow.png',
  '中雪': 'assets/images/weather/moderate_snow.png',
  '大雪': 'assets/images/weather/heavy_snow.png',
  '暴雪': 'assets/images/weather/super_snow.png',
  '雾': 'assets/images/weather/fog.png',
  '冻雨': 'assets/images/weather/freezing.png',
  '沙尘暴': 'assets/images/weather/sand_storm.png',
  '小雨-中雨': 'assets/images/weather/moderate_rain.png',
  '中雨-大雨': 'assets/images/weather/heavy_rain.png',
  '大雨-暴雨': 'assets/images/weather/rainstorm.png',
  '暴雨-大暴雨': 'assets/images/weather/heavy_rainstorm.png',
  '大暴雨-特大暴雨': 'assets/images/weather/super_rainstorm.png',
  '小雪-中雪': 'assets/images/weather/moderate_snow.png',
  '中雪-大雪': 'assets/images/weather/heavy_snow.png',
  '大雪-暴雪': 'assets/images/weather/super_snow.png',
  '浮尘': 'assets/images/weather/dust.png',
  '扬沙': 'assets/images/weather/sand.png',
  '强沙尘暴': 'assets/images/weather/heavy_sand_storm.png',
  '飑': 'assets/images/weather/sand.png',
  '龙卷风': 'assets/images/weather/heavy_sand_storm.png',
  '弱高吹雪': 'assets/images/weather/super_snow.png',
  '轻霾': 'assets/images/weather/haze.png',
  '霾': 'assets/images/weather/haze.png',
};
