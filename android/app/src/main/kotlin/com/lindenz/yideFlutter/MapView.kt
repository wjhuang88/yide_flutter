package com.lindenz.yideFlutter

import android.content.Context
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.location.Location
import android.os.Bundle
import android.util.Log
import android.util.TypedValue
import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.AMapUtils
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.MapView
import com.amap.api.maps.model.*
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.core.PoiItem
import com.amap.api.services.poisearch.PoiResult
import com.amap.api.services.poisearch.PoiSearch
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class MapPlatformView(private val viewId: Int, private val context: Context, savedInstanceState: Bundle?, height: Int, width: Int, private val channel: MethodChannel, args: Any?) : PlatformView, MethodChannel.MethodCallHandler, AMap.OnMyLocationChangeListener, AMap.OnMapClickListener, AMap.OnCameraChangeListener {

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

    private var isUpdating: Boolean = false

    private lateinit var initCenter: Pair<Double, Double>
    private lateinit var regionCenter: LatLng

    private val aMap: AMap

    init {
        val map = args as? Map<*, *>
        if (map != null) {
            cameraDegree = map["cameraDegree"] as? Float ?: 30.0f
            Log.d("AMapView", "获取参数 cameraDegree: $cameraDegree")

            zoomLevel = map["zoomLevel"] as? Float ?: 16.0f
            Log.d("AMapView", "获取参数 zoomLevel: $zoomLevel")

            showsUserLocation = map["showsUserLocation"] as? Boolean ?: true
            Log.d("AMapView", "获取参数 showsUserLocation: $showsUserLocation")

            showsCompass = map["showsCompass"] as? Boolean ?: true
            Log.d("AMapView", "获取参数 showsCompass: $showsCompass")

            showsScale = map["showsScale"] as? Boolean ?: true
            Log.d("AMapView", "获取参数 showsScale: $showsScale")

            centerOffset = (map["centerOffset"] as? List<*>)?.let { centerOffsetValue ->
                (centerOffsetValue[0] as? Double
                        ?: 0.0).toFloat() to (centerOffsetValue[1] as? Double ?: 0.0).toFloat()
            } ?: (0.0f to 0.0f)
            Log.d("AMapView", "获取参数 centerOffset: $centerOffset")

            logoOffset = (map["logoOffset"] as? List<*>)?.let { logoOffsetValue ->
                (logoOffsetValue[0] as? Double ?: 0.0) to (logoOffsetValue[1] as? Double ?: 0.0)
            } ?: (0.0 to 0.0)
            Log.d("AMapView", "获取参数 logoOffset: $logoOffset")

            compassOffset = (map["compassOffset"] as? List<*>)?.let { compassOffsetValue ->
                Pair(compassOffsetValue[0] as? Double
                        ?: 0.0, compassOffsetValue[1] as? Double ?: 0.0)
            } ?: (0.0 to 0.0)
            Log.d("AMapView", "获取参数 compassOffset: $compassOffset")

            scaleOffset = (map["scaleOffset"] as? List<*>)?.let { scaleOffsetValue ->
                (scaleOffsetValue[0] as? Double ?: 0.0) to (scaleOffsetValue[1] as? Double ?: 0.0)
            } ?: (0.0 to 0.0)
            Log.d("AMapView", "获取参数 scaleOffset: $scaleOffset")

            (map["initCenter"] as? List<*>)?.let { initCenterValue ->
                initCenter = Pair(initCenterValue[0] as? Double
                        ?: 0.0, initCenterValue[1] as? Double
                        ?: 0.0)
                Log.d("AMapView", "获取参数 initCenter: $initCenter")
            }
        } else {
            cameraDegree = 30.0f
            zoomLevel = 16.0f
            logoOffset = 0.0 to 0.0
            compassOffset = 0.0 to 0.0
            scaleOffset = 0.0 to 0.0
            showsUserLocation = true
            showsCompass = true
            showsScale = true
            centerOffset = 0.0f to 0.0f
            Log.d("AMapView", "没有找到传入参数，全部使用默认参数")
        }

        mapView = MapView(context)
        mapView.onCreate(savedInstanceState)
        aMap = mapView.map
        aMap.setOnCameraChangeListener(this)
        aMap.setOnMapClickListener(this)
        aMap.setOnMyLocationChangeListener(this)

        val ui = aMap.uiSettings
        ui.isCompassEnabled = false
        ui.isScaleControlsEnabled = false
        ui.isZoomControlsEnabled = false

        val myLocationStyle = MyLocationStyle()
        myLocationStyle.interval(5000)
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW_NO_CENTER)
        myLocationStyle.strokeColor(0)
        myLocationStyle.radiusFillColor(0)//0xFFFAB807
        myLocationStyle.myLocationIcon(BitmapDescriptorFactory.fromBitmap(makeMapDot(12f, 3f)))
        myLocationStyle.anchor(centerOffset.first, centerOffset.second)

        aMap.myLocationStyle = myLocationStyle
        aMap.isMyLocationEnabled = true

        val pointX = centerOffset.first * width
        val pointY = centerOffset.second * height

        aMap.setPointToCenter(pointX.toInt(), pointY.toInt())
    }

    @Suppress("SameParameterValue")
    private fun makeMapDot(radius: Float, stroke: Float): Bitmap {
        val radiusPx = dp2px(radius)
        val radiusPxFloat = radiusPx.toFloat()

        val paint = Paint()
        val bitmap = Bitmap.createBitmap(radiusPx * 2 + 20, radiusPx * 2 + 20, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        paint.color = Color.WHITE
        paint.setShadowLayer(5f, 0f, 0f, Color.GRAY)
        canvas.drawCircle(radiusPxFloat + 10, radiusPxFloat + 10, radiusPxFloat, paint)
        paint.color = 0xFFFAB807.toInt()
        paint.setShadowLayer(0f, 0f, 0f, Color.GRAY)
        canvas.drawCircle(radiusPxFloat + 10, radiusPxFloat + 10, radiusPxFloat - dp2px(stroke), paint)

        return bitmap
    }

    private fun dp2px(dpValue: Float): Int {
        val scale = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dpValue
                , Resources.getSystem().displayMetrics)
        return (scale + 0.5f).toInt()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "backToUserLocation" -> aMap.myLocation.let {
                val mCameraUpdate = CameraUpdateFactory.newLatLng(LatLng(it.latitude, it.longitude))
                aMap.animateCamera(mCameraUpdate)
                result.success(null)
            }
            "getUserLocation" -> {
                val resultMap = HashMap<String, Double>()
                resultMap["latitude"] = aMap.myLocation.latitude
                resultMap["longitude"] = aMap.myLocation.longitude
                result.success(resultMap)
            }
            "getUserAddress" -> Unit
            "searchAround" -> (call.arguments as? String)?.let { keyword ->
                val location = if (this::regionCenter.isInitialized) {
                    regionCenter
                } else {
                    LatLng(aMap.myLocation.latitude, aMap.myLocation.longitude)
                }
                requestAroundPOI(location, keyword) { data ->
                    val dataAround = data as? List<Map<String, Any?>>
                    if (dataAround != null) {
                        result.success(dataAround)
                    } else {
                        result.success(emptyList<Map<String, Any?>>())
                    }
                }
            }
            "forceTriggerRegionChange" -> if (this::regionCenter.isInitialized) {
                forceUpdateRegionInfo(centerCoord = LatLng(regionCenter.latitude, regionCenter.longitude))
            }
        }
    }

    override fun getView(): View = mapView

    override fun dispose() = mapView.onDestroy()

//    override fun onFlutterViewAttached(flutterView: View) = mapView.onResume()
//
//    override fun onFlutterViewDetached() = mapView.onPause()

    private fun makeDictionaryFromPOI(poi: PoiItem): Map<String, Any?> {
        val poiCoord = poi.latLonPoint
        val userCoord = aMap.myLocation
        val dist = AMapUtils.calculateLineDistance(LatLng(poiCoord.latitude, poiCoord.longitude), LatLng(userCoord.latitude, userCoord.longitude))
        val map = HashMap<String, Any?>()
        map["name"] = poi.title
        map["id"] = poi.poiId
        map["distance"] = dist.toInt()
        map["address"] = poi.snippet
        map["latitude"] = poi.latLonPoint.latitude
        map["longitude"] = poi.latLonPoint.longitude

        return map
    }

    private fun requestAroundPOI(coor: LatLng, keyword: String?, result: (List<Map<String, Any?>>) -> Unit) {
        val query = PoiSearch.Query(keyword, "010000|020000|030000|040000|010000|020000|030000|040000|050000|060000|070000|080000|090000|100000|110000|120000|130000|140000|150000")
        val search = PoiSearch(context, query)
        search.bound = PoiSearch.SearchBound(LatLonPoint(coor.latitude, coor.longitude), 10000)
        search.setOnPoiSearchListener(object : PoiSearch.OnPoiSearchListener {
            override fun onPoiItemSearched(item: PoiItem?, rCode: Int) {
                // do nothing
            }

            override fun onPoiSearched(poiResult: PoiResult?, rCode: Int) {
                if (poiResult != null) {
                    val resultList = poiResult.pois.map(this@MapPlatformView::makeDictionaryFromPOI)
                    result(resultList)
                } else {
                    result(emptyList())
                }
            }
        })
        search.searchPOIAsyn()
    }

    private fun updateRegionInfo(centerCoord: LatLng) {
        if (this::regionCenter.isInitialized) {
            val dist = AMapUtils.calculateLineDistance(centerCoord, regionCenter)
            if (dist < 50) {
                return
            }
        }
        channel.invokeMethod("onRegionStartChanging", null)
        regionCenter = centerCoord
        forceUpdateRegionInfo(centerCoord)
    }

    private fun forceUpdateRegionInfo(centerCoord: LatLng) {
        if (isUpdating) {
            return
        } else {
            isUpdating = true
            requestAroundPOI(centerCoord, null) { data ->
                val coordList = listOf(centerCoord.latitude, centerCoord.longitude)
                val resultMap = HashMap<String, Any?>()
                resultMap["coordinate"] = coordList
                resultMap["around"] = data
                channel.invokeMethod("onRegionChanged", resultMap)
                isUpdating = false
            }
        }
    }

    override fun onMyLocationChange(location: Location?) {
        if (!this::regionCenter.isInitialized) {
            val center = when {
                this::initCenter.isInitialized -> LatLng(initCenter.first, initCenter.second)
                location != null -> LatLng(location.latitude, location.longitude)
                else -> LatLng(0.0, 0.0)
            }
            aMap.moveCamera(CameraUpdateFactory.newCameraPosition(CameraPosition(center, zoomLevel, cameraDegree, 0.0f)))
            updateRegionInfo(center)
        }
    }

    override fun onMapClick(coordinate: LatLng?) {
        val resultList = ArrayList<Double>()
        coordinate?.let {
            resultList.add(it.latitude)
            resultList.add(it.longitude)
        }
        channel.invokeMethod("onMapTap", resultList)
    }

    override fun onCameraChange(position: CameraPosition) {

    }

    override fun onCameraChangeFinish(position: CameraPosition) {
        updateRegionInfo(position.target)
    }
}

class MapViewFactory(private val messenger: BinaryMessenger, private val savedInstanceState: Bundle?, private val height: Int, private val width: Int) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    val flutterId = "yide_map_view"

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val channel = MethodChannel(messenger, flutterId + "_method")
        val mapView = MapPlatformView(viewId, context!!, savedInstanceState, height, width, channel, args)
        channel.setMethodCallHandler(mapView)
        return mapView
    }

}