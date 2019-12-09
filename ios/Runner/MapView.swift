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

public class MapView : NSObject, FlutterPlatformView, AMapSearchDelegate, MAMapViewDelegate {
    
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
    let initCenter: CLLocationCoordinate2D?
    
    let _reGeoHandler: ReGeoHandler
    let _poiHandler: POIHandler
    let _tipHandler: TipHandler
    
    var _regionCenter: CLLocationCoordinate2D?
    
    init(_ frame: CGRect, viewId: Int64, methodChannel: FlutterMethodChannel, locationManager: AMapLocationManager, args: Any?) {
        
        self.frame = frame
        self.viewId = viewId
        self._channel = methodChannel
        self._locationManager = locationManager
        self._searchManager = AMapSearchAPI()
        self._view = MAMapView(frame: frame)
        self._reGeoHandler = ReGeoHandler()
        self._poiHandler = POIHandler()
        self._tipHandler = TipHandler()
        
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
            
            if let initCenterList = map["initCenter"] as? Array<NSNumber> {
                self.initCenter = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: initCenterList[0]), longitude: CLLocationDegrees(truncating: initCenterList[1]))
                NSLog("获取参数initCenter：\(self.initCenter!)")
            } else {
                self.initCenter = nil
                NSLog("使用默认的initCenter：nil")
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
            self.initCenter = nil
            NSLog("没有找到传入参数，全部使用默认参数")
        }
        
        super.init()
        
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
        if let initLocation = self.initCenter {
            self._view.centerCoordinate = initLocation
        }

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
            } else if ("searchAround" == call.method) {
                if let keyword = call.arguments as? String {
                    let coord = self._userLocation.coordinate
                    var resultMap = Dictionary<String, Dictionary<String, Any?>>()
                    let tipAction = {() in
                        self.requestTips(keyword: keyword) { (data) in
                            if let dataTips = data as? Array<Dictionary<String, Any?>> {
                                if dataTips.count > 0 {
                                    dataTips.forEach { (tip) in
                                        resultMap[tip["id"] as! String] = tip
                                    }
                                }
                            }
                            result(Array(resultMap.values))
                        }
                    }
                    let keywordAction = {() in
                        self.requestKeywordPOI(keyword: keyword) { (data) in
                            if let dataKeyword = data as? Array<Dictionary<String, Any?>> {
                                if dataKeyword.count > 0 {
                                    dataKeyword.forEach { (keywordResult) in
                                        resultMap[keywordResult["id"] as! String] = keywordResult
                                    }
                                }
                                if resultMap.count >= 5 {
                                    result(Array(resultMap.values))
                                } else {
                                    tipAction()
                                }
                            } else {
                                tipAction()
                            }
                        }
                    }
                    self.requestAroundPOI(coord: coord, keyword: keyword) { (data) in
                        if let dataAround = data as? Array<Dictionary<String, Any?>> {
                            if dataAround.count >= 5 {
                                result(dataAround)
                            } else {
                                dataAround.forEach { (around) in
                                    resultMap[around["id"] as! String] = around
                                }
                                keywordAction()
                            }
                        } else {
                            keywordAction()
                        }
                    }
                }
            } else if ("forceTriggerRegionChange" == call.method) {
                if let coord = self._regionCenter {
                    self.forceUpdateRegionInfo(centerCoord: coord)
                }
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
    
    private func calculateDistance(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> CLLocationDistance {
        let aPoint = MAMapPointForCoordinate(a)
        let bPoint = MAMapPointForCoordinate(b)
        return MAMetersBetweenMapPoints(aPoint , bPoint)
    }
    
    private func makeDictionaryFromPOI(poi: AMapPOI) -> Dictionary<String, Any?> {
        let dist: Int
        let latitude: CGFloat
        let longitude: CGFloat
        if let poiLoc = poi.location {
            latitude = poiLoc.latitude
            longitude = poiLoc.longitude
            let baseCoord = self._userLocation.coordinate
            let poiCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            dist = Int(calculateDistance(a: baseCoord , b: poiCoord))
        } else {
            dist = poi.distance
            latitude = 0.0
            longitude = 0.0
        }
        return Dictionary<String, Any?>(
            dictionaryLiteral:
            ("name", poi.name),
            ("id", poi.uid),
            ("distance", dist),
            ("address", poi.address),
            ("latitude", latitude),
            ("longitude", longitude)
        )
    }
    
    private func makeDictionaryFromTip(tip: AMapTip) -> Dictionary<String, Any?> {
        let dist: Int?
        let latitude: CGFloat
        let longitude: CGFloat
        if let tipLoc = tip.location {
            latitude = tipLoc.latitude
            longitude = tipLoc.longitude
            let baseCoord = self._userLocation.coordinate
            let poiCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            dist = Int(calculateDistance(a: baseCoord , b: poiCoord))
        } else {
            dist = nil
            latitude = 0.0
            longitude = 0.0
        }
        return Dictionary<String, Any?>(
            dictionaryLiteral:
            ("name", tip.name),
            ("id", tip.uid),
            ("distance", dist),
            ("address", tip.address),
            ("latitude", latitude),
            ("longitude", longitude)
        )
    }
    
    private func requestAroundPOI(coord: CLLocationCoordinate2D, keyword: String?, result: @escaping FlutterResult) {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coord.latitude), longitude: CGFloat(coord.longitude))
        request.requireExtension = true
        if let keyword = keyword {
            request.keywords = keyword
        }
        let invokeId = request.hash
        self._poiHandler.results[invokeId] = result
        self._poiHandler.handles[invokeId] = {(response, result) -> Void in
            result(response.pois.map(self.makeDictionaryFromPOI))
        }
        self._searchManager.aMapPOIAroundSearch(request)
    }
    
    private func requestKeywordPOI(keyword: String, result: @escaping FlutterResult) {
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = keyword
        request.requireExtension = true
        request.cityLimit = true
        request.requireSubPOIs = true
        let invokeId = request.hash
        self._poiHandler.results[invokeId] = result
        self._poiHandler.handles[invokeId] = {(response, result) -> Void in
            result(response.pois.map(self.makeDictionaryFromPOI))
        }
        self._searchManager.aMapPOIKeywordsSearch(request)
    }
    
    private func requestTips(keyword: String, result: @escaping FlutterResult) {
        let request = AMapInputTipsSearchRequest()
        request.keywords = keyword
        let location = self._userLocation.coordinate
        request.location = "\(location.latitude),\(location.longitude)"
        request.cityLimit = true
        print(request.location)
        let invokeId = request.hash
        self._tipHandler.results[invokeId] = result
        self._tipHandler.handles[invokeId] = {(response, result) -> Void in
            let list = response.tips.map(self.makeDictionaryFromTip)
            result(list)
        }
        self._searchManager.aMapInputTipsSearch(request)
    }
    
    private func updateRegionInfo() {
        let centerCoord = self._view.region.center
        if let lastCoord = _regionCenter {
            let dist = MAMetersBetweenMapPoints(MAMapPointForCoordinate(centerCoord), MAMapPointForCoordinate(lastCoord))
            if dist < 50 {
                return
            }
        }
        self._channel.invokeMethod("onRegionStartChanging", arguments: nil)
        _regionCenter = centerCoord
        forceUpdateRegionInfo(centerCoord: centerCoord)
    }
    
    private func forceUpdateRegionInfo(centerCoord: CLLocationCoordinate2D) {
        requestAroundPOI(coord: centerCoord, keyword: nil) { (data) in
            let coordList = Array(arrayLiteral: centerCoord.latitude, centerCoord.longitude)
            let resultMap = Dictionary<String, Any?>(
                dictionaryLiteral:
                ("coordinate", coordList),
                ("around", data)
            )
            self._channel.invokeMethod("onRegionChanged", arguments: resultMap)
        }
    }
    
    public func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        let resultList = Array(arrayLiteral: coordinate.latitude, coordinate.longitude)
        self._channel.invokeMethod("onMapTap", arguments: resultList)
    }
    
    public func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        if _regionCenter == nil {
            updateRegionInfo()
        }
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
    
    public func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        let _invokeId: Int = request.hash
        if let handler = self._tipHandler.handles[_invokeId] {
            if let result = self._tipHandler.results[_invokeId] {
                handler(response, result)
                self._poiHandler.handles.removeValue(forKey: _invokeId)
            }
        }
    }
    
    public func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("Error:\(String(describing: error))")
        self._channel.invokeMethod("onError", arguments: String(describing: error))
    }
    
    public func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        updateRegionInfo()
    }
    
    public func view() -> UIView {
        return _view
    }
    
}

public class MapViewFactory : NSObject, FlutterPlatformViewFactory {
    
    let _messager: FlutterBinaryMessenger
    let _locationManager: AMapLocationManager
    public let flutterId = "yide_map_view"
    
    init(messager: FlutterBinaryMessenger, locationManager: AMapLocationManager) {
        self._messager = messager
        self._locationManager = locationManager
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        
        let channel = FlutterMethodChannel(name: flutterId + "_method", binaryMessenger: _messager)
        return MapView(frame, viewId: viewId, methodChannel: channel, locationManager: _locationManager, args: args)
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

class TipHandler : NSObject {
    var handles: Dictionary<Int, ((AMapInputTipsSearchResponse, FlutterResult) -> Void)>
    var results: Dictionary<Int, FlutterResult>
    
    override init() {
        self.handles = Dictionary<Int, ((AMapInputTipsSearchResponse, FlutterResult) -> Void)>()
        self.results = Dictionary<Int, FlutterResult>()
    }
}
