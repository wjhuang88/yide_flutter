package com.lindenz.yideFlutter

import android.content.Context
import android.location.Location
import android.os.Bundle
import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.AMapOptions
import com.amap.api.maps.MapView
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.CustomMapStyleOptions
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.MyLocationStyle
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class MapPlatformView(private val viewId: Int, context: Context, savedInstanceState: Bundle?, height: Int, width: Int, args: Any?) : PlatformView, MethodChannel.MethodCallHandler, AMap.OnMyLocationChangeListener {

    private val mapView: MapView

    private val cameraDegree: Float
    private val zoomLevel: Float
    private val logoOffset: Pair<Double, Double>
    private val compassOffset: Pair<Double, Double>
    private val scaleOffset: Pair<Double, Double>
    private val showsUserLocation: Boolean
    private val showsCompass: Boolean
    private val showsScale: Boolean
    private val centerOffset: Pair<Float, Float>

    private lateinit var initCenter: Pair<Double, Double>
    private lateinit var _regionCenter: Pair<Double, Double>

    private var userLocation: Location? = null

    private val aMap: AMap

    init {
        val map = args as? Map<*, *>
        if (map != null) {
            cameraDegree = map["cameraDegree"] as? Float ?: 30.0f
            zoomLevel = map["zoomLevel"] as? Float ?: 16.0f
            showsUserLocation = map["showsUserLocation"] as? Boolean ?: true
            showsCompass = map["showsCompass"] as? Boolean ?: true
            showsScale = map["showsScale"] as? Boolean ?: true

            centerOffset = (map["centerOffset"] as? List<*>)?.let { centerOffsetValue ->
                Pair(centerOffsetValue[0] as? Float
                        ?: 0.0f, centerOffsetValue[1] as? Float ?: 0.0f)
            } ?: Pair(0.0f, 0.0f)

            logoOffset = (map["logoOffset"] as? List<*>)?.let { logoOffsetValue ->
                Pair(logoOffsetValue[0] as? Double ?: 0.0, logoOffsetValue[1] as? Double
                        ?: 0.0)
            } ?: Pair(0.0, 0.0)

            compassOffset = (map["compassOffset"] as? List<*>)?.let { compassOffsetValue ->
                Pair(compassOffsetValue[0] as? Double
                        ?: 0.0, compassOffsetValue[1] as? Double ?: 0.0)
            } ?: Pair(0.0, 0.0)

            scaleOffset = (map["scaleOffset"] as? List<*>)?.let { scaleOffsetValue ->
                Pair(scaleOffsetValue[0] as? Double
                        ?: 0.0, scaleOffsetValue[1] as? Double ?: 0.0)
            } ?: Pair(0.0, 0.0)

            (map["initCenter"] as? List<*>)?.let { initCenterValue ->
                initCenter = Pair(initCenterValue[0] as? Double
                        ?: 0.0, initCenterValue[1] as? Double
                        ?: 0.0)
            }
        } else {
            cameraDegree = 30.0f
            zoomLevel = 16.0f
            logoOffset = Pair(0.0, 0.0)
            compassOffset = Pair(0.0, 0.0)
            scaleOffset = Pair(0.0, 0.0)
            showsUserLocation = true
            showsCompass = true
            showsScale = true
            centerOffset = Pair(0.0f, 0.0f)
        }

        val mapOptions = AMapOptions()
        val userLoc = userLocation
        val center = when {
            this::initCenter.isInitialized -> LatLng(initCenter.first, initCenter.second)
            userLoc != null -> LatLng(userLoc.latitude, userLoc.longitude)
            else -> LatLng(0.0, 0.0)
        }
        mapOptions.camera(CameraPosition(center, zoomLevel, cameraDegree, 0.0f))

        mapView = MapView(context, mapOptions)
        mapView.onCreate(savedInstanceState)
        aMap = mapView.map

        val styleData = context.resources.openRawResource(R.raw.style).readBytes()
        val styleExtra = context.resources.openRawResource(R.raw.style_extra).readBytes()
        aMap.setCustomMapStyle(CustomMapStyleOptions().setEnable(true).setStyleData(styleData).setStyleExtraData(styleExtra))

        val ui = aMap.uiSettings
        ui.isCompassEnabled = false
        ui.isScaleControlsEnabled = false
        ui.isZoomControlsEnabled = false

        val myLocationStyle = MyLocationStyle()
        myLocationStyle.interval(2000)
        if (this::initCenter.isInitialized) {
            myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW_NO_CENTER)
        } else {
            myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW)
        }
        myLocationStyle.anchor(centerOffset.first, centerOffset.second)
        aMap.myLocationStyle = myLocationStyle
        aMap.isMyLocationEnabled = true


        val pointX = centerOffset.first * width
        val pointY = centerOffset.second * height
        aMap.setPointToCenter(pointX.toInt(), pointY.toInt())
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun getView(): View = mapView

    override fun dispose() = mapView.onDestroy()

    override fun onFlutterViewAttached(flutterView: View) = mapView.onResume()

    override fun onFlutterViewDetached() = mapView.onPause()

    override fun onMyLocationChange(location: Location?) {
        userLocation = location
    }
}

class MapViewFactory(private val messenger: BinaryMessenger, private val savedInstanceState: Bundle?, private val height: Int, private val width: Int) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    val flutterId = "yide_map_view"

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val mapView = MapPlatformView(viewId, context!!, savedInstanceState, height, width, args)
        val channel = MethodChannel(messenger, flutterId + "_method")
        channel.setMethodCallHandler(mapView)
        return mapView
    }

}