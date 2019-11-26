import UIKit
import Flutter
import AMapFoundationKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let viewFactory = MapViewFactory()
    registrar(forPlugin: "yide_map_view").register(viewFactory, withId: "yide_map_view")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

public class MapView : NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    
    init(_ frame: CGRect, viewId: Int64, args: Any?) {
        self.frame = frame
        self.viewId = viewId
    }
    
    public func view() -> UIView {
        let view = MAMapView(frame: frame)
        view.showsUserLocation = true
        view.userTrackingMode = .follow
        view.isRotateCameraEnabled = true
        view.setCameraDegree(30, animated: true, duration: 300)
        view.setZoomLevel(16, animated: true)
        
        let options = MAMapCustomStyleOptions.init()
        options.styleId = "73fd5a56e6563049df0a36730c21529d"
        view.setCustomMapStyleOptions(options)
        view.customMapStyleEnabled = true
        return view
    }
}

public class MapViewFactory : NSObject, FlutterPlatformViewFactory {
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        AMapServices.shared().apiKey = "ee7d937c67b8bf8317f712fb2a5e7774"
        AMapServices.shared().enableHTTPS = true
        return MapView(frame, viewId: viewId, args: args)
    }
}
