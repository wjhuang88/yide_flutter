//
//  LocationMethod.swift
//  Runner
//
//  Created by Gerald Huang on 2019/12/2.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Flutter
import AMapFoundationKit

public class LocationMethod : NSObject, AMapSearchDelegate {
    
    let _channel: FlutterMethodChannel
    let _locationManager: AMapLocationManager
    let _searchManager: AMapSearchAPI
    let _weatherHandler: WeatherHandler
    
    public init(channel: FlutterMethodChannel, locationManager: AMapLocationManager) {
        self._channel = channel
        self._locationManager = locationManager
        self._searchManager = AMapSearchAPI()
        self._weatherHandler = WeatherHandler()
        
        super.init()
        
        self._searchManager.delegate = self
        
        channel.setMethodCallHandler { [self](call, result) in
            if "getLocation" == call.method {
                self.getLocation(result: result)
            } else if "getWeather" == call.method {
                if let adcode = call.arguments as? String {
                    let request = AMapWeatherSearchRequest()
                    request.type = AMapWeatherType.live
                    request.city = adcode
                    let invokeId = request.hash
                    self._weatherHandler.results[invokeId] = result
                    self._weatherHandler.handles[invokeId] = {(response, result) in
                        if response.lives.count > 0 {
                            if let live = response.lives.first {
                                let map = Dictionary<String, String>(
                                    dictionaryLiteral:
                                    ("adcode", live.adcode),
                                    ("province", live.province),
                                    ("city", live.city),
                                    ("weather", live.weather),
                                    ("temperature", live.temperature),
                                    ("windDirection", live.windDirection),
                                    ("windPower", live.windPower),
                                    ("humidity", live.humidity),
                                    ("reportTime", live.reportTime)
                                )
                                result(map)
                            } else {
                                result(Dictionary<String, Any?>())
                            }
                        } else {
                            result(Dictionary<String, Any?>())
                        }
                    }
                    self._searchManager.aMapWeatherSearch(request)
                } else {
                    result(Dictionary<String, Any?>())
                }
            } else {
                result(Dictionary<String, Any?>())
            }
        }
    }
    
    public func onWeatherSearchDone(_ request: AMapWeatherSearchRequest!, response: AMapWeatherSearchResponse!) {
        let _invokeId: Int = request.hash
        if let handler = self._weatherHandler.handles[_invokeId] {
            if let result = self._weatherHandler.results[_invokeId] {
                handler(response, result)
                self._weatherHandler.handles.removeValue(forKey: _invokeId)
            }
        }
    }
    
    private func getLocation(result: @escaping FlutterResult) {
        self._locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self._locationManager.locationTimeout = 2
        self._locationManager.reGeocodeTimeout = 2
        self._locationManager.requestLocation(withReGeocode: true) { (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            if let error = error {
                let error = error as NSError
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                    NSLog("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
                }
                else {
                //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
                }
            }
            var resultMap: Dictionary<String, Any?>
            if let comp = reGeocode {
                resultMap = Dictionary<String, Any?>(
                dictionaryLiteral:
                      ("country", comp.country),
                      ("province", comp.province),
                      ("city", comp.city),
                      ("citycode", comp.citycode),
                      ("district", comp.district),
                      ("street", comp.street),
                      ("adcode", comp.adcode),
                      ("formattedAddress", comp.formattedAddress)
                )
            } else {
                resultMap = Dictionary<String, Any?>()
            }
            
            if let coord = location?.coordinate {
                resultMap["latitude"] = coord.latitude
                resultMap["longitude"] = coord.longitude
            }
            
            result(resultMap)
        }
    }
    
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("Error:\(String(describing: error))")
        self._channel.invokeMethod("onError", arguments: NSString(utf8String: String(describing: error)))
    }
}

class WeatherHandler : NSObject {
    var handles: Dictionary<Int, ((AMapWeatherSearchResponse, FlutterResult) -> Void)>
    var results: Dictionary<Int, FlutterResult>
    
    override init() {
        self.handles = Dictionary<Int, ((AMapWeatherSearchResponse, FlutterResult) -> Void)>()
        self.results = Dictionary<Int, FlutterResult>()
    }
}
