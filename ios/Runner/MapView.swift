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

public class MapView : NSObject, FlutterPlatformView, AMapSearchDelegate, AMapLocationManagerDelegate, MAMapViewDelegate {
    
    let frame: CGRect
    let viewId: Int64
    
    let _view: MAMapView
    let _locationManager: AMapLocationManager
    let _searchManager: AMapSearchAPI
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
    
    let _reGeoHandler: ReGeoHandler
    let _poiHandler: POIHandler
    
    var _regionCenter: CLLocationCoordinate2D?
    
    init(_ frame: CGRect, viewId: Int64, methodChannel: FlutterMethodChannel, args: Any?) {
        
        self.frame = frame
        self.viewId = viewId
        self._channel = methodChannel
        self._locationManager = AMapLocationManager()
        self._searchManager = AMapSearchAPI()
        self._view = MAMapView(frame: frame)
        self._reGeoHandler = ReGeoHandler()
        self._poiHandler = POIHandler()
        
        self._regionCenter = nil
        
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
        
        super.init()
        
        self._locationManager.delegate = self
        self._searchManager.delegate = self
        self._view.delegate = self
        
        self._locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self._locationManager.locationTimeout = 2
        self._locationManager.reGeocodeTimeout = 2
        
        self._view.showsUserLocation = self.showsUserLocation
        self._view.userTrackingMode = .follow
        self._view.isRotateCameraEnabled = true
        self._view.setCameraDegree(cameraDegree, animated: true, duration: 300)
        self._view.setZoomLevel(zoomLevel, animated: true)
        
        let path = Bundle.main.bundlePath
        let stylePath = path + "/style.data"
        let extraPath = path + "/style_extra.data"
        let styleData = NSData.init(contentsOfFile: stylePath)
        let extraData = NSData.init(contentsOfFile: extraPath)
        let options = MAMapCustomStyleOptions.init()
        options.styleData = styleData! as Data
        options.styleExtraData = extraData! as Data
        self._view.setCustomMapStyleOptions(options)
        self._view.customMapStyleEnabled = true
        
        let srcLogoCenter = self._view.logoCenter
        self._view.logoCenter = CGPoint(x: srcLogoCenter.x + logoOffset.x, y: srcLogoCenter.y + logoOffset.y)
        
        self._view.showsCompass = self.showsCompass
        let srcCompassOrigin = self._view.compassOrigin
        self._view.compassOrigin = CGPoint(x: srcCompassOrigin.x + compassOffset.x, y: srcCompassOrigin.y + compassOffset.y)
        
        self._view.showsScale = self.showsScale
        let srcScaleOrigin = self._view.scaleOrigin
        self._view.scaleOrigin = CGPoint(x: srcScaleOrigin.x + scaleOffset.x, y: srcScaleOrigin.y + scaleOffset.y)
        
        let r = MAUserLocationRepresentation()
        r.showsAccuracyRing = false
        r.showsHeadingIndicator = false
        r.locationDotFillColor = UIColor(red: 0.98, green: 0.72, blue: 0.03, alpha: 1)
        self._view.update(r)
        
        self._view.screenAnchor = centerOffset

        _channel.setMethodCallHandler({ [self]
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if("backToUserLocation" == call.method) {
                self._view.setCenter(self._userLocation.coordinate, animated: true)
                result(nil)
            } else if("getUserLocation" == call.method) {
                var resultMap = Dictionary<String, Double>()
                let coord = self._userLocation.coordinate
                resultMap["latitude"] = coord.latitude
                resultMap["longitude"] = coord.longitude
                result(resultMap)
            } else if("getUserAddress" == call.method) {
                let request = AMapReGeocodeSearchRequest()
                let coord = self._userLocation.coordinate
                request.location = AMapGeoPoint.location(withLatitude: CGFloat(coord.latitude), longitude: CGFloat(coord.longitude))
                request.requireExtension = true
                let invokeId = request.hash
                self._reGeoHandler.results[invokeId] = result
                self._reGeoHandler.handles[invokeId] = {(response, result) -> Void in
                    if let regeocode = response.regeocode {
                        result(self.makeDictionaryFromReGeocode(regeocode: regeocode))
                    } else {
                        result(Dictionary<String, String>())
                    }
                }
                self._searchManager.aMapReGoecodeSearch(request)
            }
        });
    }
    
    private var _userLocation: MAUserLocation {
        get {
            return _view.userLocation
        }
    }
    
    private func makeDictionaryFromReGeocode(regeocode: AMapReGeocode) -> Dictionary<String, String> {
        let comp = regeocode.addressComponent
        return Dictionary<String, String>(
            dictionaryLiteral:
                  ("country", comp!.country),
                  ("province", comp!.province),
                  ("city", comp!.city),
                  ("citycode", comp!.citycode),
                  ("district", comp!.district),
                  ("adcode", comp!.adcode),
                  ("township", comp!.township),
                  ("towncode", comp!.towncode),
                  ("neighborhood", comp!.neighborhood),
                  ("building", comp!.building),
                  ("formattedAddress", regeocode.formattedAddress)
            )
    }
    
    private func requestPOI(coord: CLLocationCoordinate2D, keyword: String?, result: @escaping FlutterResult) {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coord.latitude), longitude: CGFloat(coord.longitude))
        if let keyword = keyword {
            request.keywords = keyword
        }
        request.requireExtension = true
        let invokeId = request.hash
        self._poiHandler.results[invokeId] = result
        self._poiHandler.handles[invokeId] = {(response, result) -> Void in
            result(response.pois.map { (poi) -> Dictionary<String, Any?> in
                return Dictionary<String, Any?>(
                    dictionaryLiteral:
                    ("name", poi.name),
                    ("id", poi.uid),
                    ("distance", poi.distance),
                    ("address", poi.address),
                    ("latitude", poi.location.latitude),
                    ("longitude", poi.location.longitude)
                )
            })
        }
        
        self._searchManager.aMapPOIAroundSearch(request)
    }
    
    public func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        let _invokeId: Int = request.hash
        if let handler = self._reGeoHandler.handles[_invokeId] {
            if let result = self._reGeoHandler.results[_invokeId] {
                handler(response, result)
                self._reGeoHandler.handles.removeValue(forKey: _invokeId)
            }
        }
    }
    
    public func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        let _invokeId: Int = request.hash
        if let handler = self._poiHandler.handles[_invokeId] {
            if let result = self._poiHandler.results[_invokeId] {
                handler(response, result)
                self._poiHandler.handles.removeValue(forKey: _invokeId)
            }
        }
    }
    
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("Error:\(String(describing: error))")
    }
    
    public func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        let centerCoord = self._view.region.center
        if let lastCoord = _regionCenter {
            let dist = MAMetersBetweenMapPoints(MAMapPointForCoordinate(centerCoord), MAMapPointForCoordinate(lastCoord))
            if dist < 50 {
                return
            }
        }
        _regionCenter = centerCoord
        requestPOI(coord: centerCoord, keyword: nil) { (data) in
            let coordList = Array(arrayLiteral: centerCoord.latitude, centerCoord.longitude)
            let resultMap = Dictionary<String, Any?>(
                dictionaryLiteral:
                ("coordinate", coordList),
                ("around", data)
            )
            self._channel.invokeMethod("onRegionChanged", arguments: resultMap)
        }
    }
    
    public func view() -> UIView {
        return _view
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

class ReGeoHandler : NSObject {
    var handles: Dictionary<Int, ((AMapReGeocodeSearchResponse, FlutterResult) -> Void)>
    var results: Dictionary<Int, FlutterResult>
    
    override init() {
        self.handles = Dictionary<Int, ((AMapReGeocodeSearchResponse, FlutterResult) -> Void)>()
        self.results = Dictionary<Int, FlutterResult>()
    }
}

class POIHandler : NSObject {
    var handles: Dictionary<Int, ((AMapPOISearchResponse, FlutterResult) -> Void)>
    var results: Dictionary<Int, FlutterResult>
    
    override init() {
        self.handles = Dictionary<Int, ((AMapPOISearchResponse, FlutterResult) -> Void)>()
        self.results = Dictionary<Int, FlutterResult>()
    }
}
