import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let viewFactory = MapViewFactory(messager: (window?.rootViewController as! FlutterViewController).binaryMessenger)
    let mapRigister = registrar(forPlugin: "yide_map_view")
    mapRigister.register(viewFactory, withId: viewFactory.flutterId)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
