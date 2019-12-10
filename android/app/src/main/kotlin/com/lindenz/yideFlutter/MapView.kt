package com.lindenz.yideFlutter

import android.content.Context
import android.location.Location
import android.os.Bundle
import android.view.View
import com.amap.api.maps.*
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.CustomMapStyleOptions
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.MyLocationStyle
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

    private lateinit var initCenter: Pair<Double, Double>
    private lateinit var regionCenter: LatLng

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

        mapView = MapView(context)
        mapView.onCreate(savedInstanceState)
        aMap = mapView.map

        val userLoc = aMap.myLocation
        val center = when {
            this::initCenter.isInitialized -> LatLng(initCenter.first, initCenter.second)
            else -> LatLng(userLoc.latitude, userLoc.longitude)
        }
        aMap.moveCamera(CameraUpdateFactory.newCameraPosition(CameraPosition(center, zoomLevel, cameraDegree, 0.0f)))

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
                requestAroundPOI(LatLng(aMap.myLocation.latitude, aMap.myLocation.longitude), keyword) { data ->
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

    override fun onFlutterViewAttached(flutterView: View) = mapView.onResume()

    override fun onFlutterViewDetached() = mapView.onPause()

    private fun makeDictionaryFromPOI(poi: PoiItem): Map<String, Any?> {
        val poiCoord = poi.latLonPoint
        val userCoord = aMap.myLocation
        val dist = AMapUtils.calculateLineDistance(LatLng(poiCoord.latitude, poiCoord.longitude), LatLng(userCoord.latitude, userCoord.longitude))
        val map = HashMap<String, Any?>()
        map["name"] = poi.cityName
        map["id"] = poi.poiId
        map["distance"] = dist
        map["address"] = poi.snippet
        map["latitude"] = poi.latLonPoint.latitude
        map["longitude"] = poi.latLonPoint.longitude
        return map
    }

    private fun requestAroundPOI(coor: LatLng, keyword: String?, result: (List<Map<String, Any?>>) -> Unit) {
        val query = PoiSearch.Query(keyword, "010000|020000|030000|040000|010000|020000|030000|040000|050000|060000|070000|080000|090000|")
        val search = PoiSearch(context, query)
        search.bound = PoiSearch.SearchBound(LatLonPoint(coor.latitude, coor.longitude), 10000)
        search.setOnPoiSearchListener(object : PoiSearch.OnPoiSearchListener {
            override fun onPoiItemSearched(item: PoiItem?, rCode: Int) {
                // do nothing
            }

            override fun onPoiSearched(poiResult: PoiResult?, rCode: Int) {
                if (poiResult != null) {
                    result(poiResult.pois.map(this@MapPlatformView::makeDictionaryFromPOI))
                } else {
                    result(emptyList())
                }
            }
        })
    }

    private fun updateRegionInfo() {
        val centerCoord = LatLng(aMap.myLocation.latitude, aMap.myLocation.longitude)
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
        requestAroundPOI(centerCoord, null) { data ->
            val coordList = listOf(centerCoord.latitude, centerCoord.longitude)
            val resultMap = HashMap<String, Any?>()
            resultMap["coordinate"] = coordList
            resultMap["around"] = data
            channel.invokeMethod("onRegionChanged", resultMap)
        }
    }

    override fun onMyLocationChange(location: Location?) {
        if (!this::regionCenter.isInitialized) {
            updateRegionInfo()
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
        // do nothing
    }

    override fun onCameraChangeFinish(position: CameraPosition) {
        updateRegionInfo()
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