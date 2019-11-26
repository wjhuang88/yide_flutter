//
//  MapView.swift
//  Runner
//
//  Created by Gerald Huang on 2019/11/26.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
import UIKit
import Flutter
import AMapFoundationKit

public class MapView : NSObject, FlutterPlatformView {
    
    let frame: CGRect
    let viewId: Int64
    
    let _view: MAMapView
    let _locationManager: AMapLocationManager
    let _channel: FlutterMethodChannel
    
    let cameraDegree: CGFloat
    let zoomLevel: CGFloat
    let logoOffset: CGPoint
    let compassOffset: CGPoint
    let scaleOffset: CGPoint
    let showsUserLocation: Bool
    let showsCompass: Bool
    let showsScale: Bool
    let centerOffset: CGPoint
    
    init(_ frame: CGRect, viewId: Int64, methodChannel: FlutterMethodChannel, args: Any?) {
        self.frame = frame
        self.viewId = viewId
        self._channel = methodChannel
        self._locationManager = AMapLocationManager()
        
        self._locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self._locationManager.locationTimeout = 2
        self._locationManager.reGeocodeTimeout = 2
        
        if let map = args as? Dictionary<String, Any> {
            if let cameraDegreeValue = map["cameraDegree"] as? NSNumber {
                self.cameraDegree = CGFloat(truncating: cameraDegreeValue)
                NSLog("获取参数cameraDegree：\(self.cameraDegree)")
            } else {
                self.cameraDegree = 30
                NSLog("使用默认的cameraDegree：\(self.cameraDegree)")
            }
            
            if let zoomLevelValue = map["zoomLevel"] as? NSNumber {
                self.zoomLevel = CGFloat(truncating: zoomLevelValue)
                NSLog("获取参数zoomLevel：\(self.zoomLevel)")
            } else {
                self.zoomLevel = 16
                NSLog("使用默认的zoomLevel：\(self.zoomLevel)")
            }
            
            if let showsUserLocationValue = map["showsUserLocation"] as? Bool {
                self.showsUserLocation = showsUserLocationValue
                NSLog("获取参数showsUserLocation：\(self.showsUserLocation)")
            } else {
                self.showsUserLocation = true
                NSLog("使用默认的showsUserLocation：\(self.showsUserLocation)")
            }
            
            if let showsCompassValue = map["showsCompass"] as? Bool {
                self.showsCompass = showsCompassValue
                NSLog("获取参数showsCompass：\(self.showsCompass)")
            } else {
                self.showsCompass = true
                NSLog("使用默认的showsCompass：\(self.showsCompass)")
            }
            
            if let showsScaleValue = map["showsScale"] as? Bool {
                self.showsScale = showsScaleValue
                NSLog("获取参数showsScale：\(self.showsScale)")
            } else {
                self.showsScale = true
                NSLog("使用默认的showsScale：\(self.showsScale)")
            }
            
            if let logoOffsetList = map["logoOffset"] as? Array<NSNumber> {
                self.logoOffset = CGPoint(x: CGFloat(truncating: logoOffsetList[0] ), y: CGFloat(truncating: logoOffsetList[1] ))
                NSLog("获取参数logoOffset：\(self.logoOffset)")
            } else {
                self.logoOffset = CGPoint(x: 0, y: 0)
                NSLog("使用默认的logoOffset：\(self.logoOffset)")
            }
            
            if let compassOffsetList = map["compassOffset"] as? Array<NSNumber> {
                self.compassOffset = CGPoint(x: CGFloat(truncating: compassOffsetList[0] ), y: CGFloat(truncating: compassOffsetList[1] ))
                NSLog("获取参数compassOffset：\(self.compassOffset)")
            } else {
                self.compassOffset = CGPoint(x: 0, y: 0)
                NSLog("使用默认的compassOffset：\(self.compassOffset)")
            }
            
            if let scaleOffsetList = map["scaleOffset"] as? Array<NSNumber> {
                self.scaleOffset = CGPoint(x: CGFloat(truncating: scaleOffsetList[0] ), y: CGFloat(truncating: scaleOffsetList[1] ))
                NSLog("获取参数scaleOffset：\(self.scaleOffset)")
            } else {
                self.scaleOffset = CGPoint(x: 0, y: 0)
                NSLog("使用默认的scaleOffset：\(self.scaleOffset)")
            }
            
            if let centerOffsetList = map["centerOffset"] as? Array<NSNumber> {
                self.centerOffset = CGPoint(x: CGFloat(truncating: centerOffsetList[0] ), y: CGFloat(truncating: centerOffsetList[1] ))
                NSLog("获取参数centerOffset：\(self.centerOffset)")
            } else {
                self.centerOffset = CGPoint(x: 0, y: 0)
                NSLog("使用默认的centerOffset：\(self.centerOffset)")
            }
        } else {
            self.cameraDegree = 30
            self.zoomLevel = 16
            self.showsUserLocation = true
            self.showsCompass = true
            self.showsScale = true
            self.logoOffset = CGPoint(x: 0, y: 0)
            self.compassOffset = CGPoint(x: 0, y: 0)
            self.scaleOffset = CGPoint(x: 0, y: 0)
            self.centerOffset = CGPoint(x: 0, y: 0)
            NSLog("没有找到传入参数，全部使用默认参数")
        }
        
        let view = MAMapView(frame: frame)
        view.showsUserLocation = self.showsUserLocation
        view.userTrackingMode = .follow
        view.isRotateCameraEnabled = true
        view.setCameraDegree(cameraDegree, animated: true, duration: 300)
        view.setZoomLevel(zoomLevel, animated: true)
        
        let path = Bundle.main.bundlePath
        let stylePath = path + "/style.data"
        let extraPath = path + "/style_extra.data"
        let styleData = NSData.init(contentsOfFile: stylePath)
        let extraData = NSData.init(contentsOfFile: extraPath)
        let options = MAMapCustomStyleOptions.init()
        options.styleData = styleData! as Data
        options.styleExtraData = extraData! as Data
        
        view.setCustomMapStyleOptions(options)
        view.customMapStyleEnabled = true
        
        let srcLogoCenter = view.logoCenter
        view.logoCenter = CGPoint(x: srcLogoCenter.x + logoOffset.x, y: srcLogoCenter.y + logoOffset.y)
        
        view.showsCompass = self.showsCompass
        let srcCompassOrigin = view.compassOrigin
        view.compassOrigin = CGPoint(x: srcCompassOrigin.x + compassOffset.x, y: srcCompassOrigin.y + compassOffset.y)
        
        view.showsScale = self.showsScale
        let srcScaleOrigin = view.scaleOrigin
        view.scaleOrigin = CGPoint(x: srcScaleOrigin.x + scaleOffset.x, y: srcScaleOrigin.y + scaleOffset.y)
        
        let r = MAUserLocationRepresentation()
        r.showsAccuracyRing = false
        r.showsHeadingIndicator = false
        r.locationDotFillColor = UIColor(red: 0.98, green: 0.72, blue: 0.03, alpha: 1)
        view.update(r)
        
        view.screenAnchor = centerOffset

        _channel.setMethodCallHandler({
          (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if("backToUserLocation" == call.method) {
                view.setCenter(view.userLocation.coordinate, animated: true)
            }
        });
        
        self._view = view
    }
    
    public func view() -> UIView {
        return _view
    }
    
    private func requestLocation(callback: @escaping ((_ location: CLLocation, _ geoString: String) -> Void)) {
        _locationManager.requestLocation(withReGeocode: true, completionBlock: { (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
                    
            if let error = error {
                let error = error as NSError
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    NSLog("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
                }
                else {
                    //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
                }
            }
            
            if let reGeocode = reGeocode {
                callback(location!, reGeocode.formattedAddress)
            }
        })
    }
    
}

public class MapViewFactory : NSObject, FlutterPlatformViewFactory {
    
    let _messager: FlutterBinaryMessenger
    public let flutterId = "yide_map_view"
    
    init(messager: FlutterBinaryMessenger) {
        self._messager = messager
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        AMapServices.shared().apiKey = "ee7d937c67b8bf8317f712fb2a5e7774"
        AMapServices.shared().enableHTTPS = true
        
        let channel = FlutterMethodChannel(name: flutterId + "_method", binaryMessenger: _messager)
        return MapView(frame, viewId: viewId, methodChannel: channel, args: args)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
}
