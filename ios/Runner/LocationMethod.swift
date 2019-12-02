//
//  LocationMethod.swift
//  Runner
//
//  Created by Gerald Huang on 2019/12/2.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Flutter
import AMapFoundationKit

public class LocationMethod : NSObject {
    
    let _channel: FlutterMethodChannel
    let _locationManager: AMapLocationManager
    
    public init(channel: FlutterMethodChannel, locationManager: AMapLocationManager) {
        self._channel = channel
        self._locationManager = locationManager
        
        super.init()
        
        channel.setMethodCallHandler { [self](call, result) in
            if "getLocation" == call.method {
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
                    
                    print(resultMap)
                    
                    result(resultMap)
                }
            } else {
                result(Dictionary<String, Any?>())
            }
        }
    }
}
