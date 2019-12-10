import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    AMapServices.shared().apiKey = "ee7d937c67b8bf8317f712fb2a5e7774"
    AMapServices.shared().enableHTTPS = true
    
    let messenger = (window?.rootViewController as! FlutterViewController).binaryMessenger
    let locationManager = AMapLocationManager()
    
    let viewFactory = MapViewFactory(messager: messenger, locationManager: locationManager)
    let mapRigister = registrar(forPlugin: viewFactory.flutterId)
    
    let locationChannel = FlutterMethodChannel(name: "amap_location_method", binaryMessenger: messenger)
    let _ = LocationMethod(channel: locationChannel, locationManager: locationManager)
    
    mapRigister.register(viewFactory, withId: viewFactory.flutterId)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
