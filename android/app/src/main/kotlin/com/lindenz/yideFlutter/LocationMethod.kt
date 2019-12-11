package com.lindenz.yideFlutter

import android.content.Context
import android.util.Log
import android.util.SparseArray
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.geocoder.GeocodeResult
import com.amap.api.services.geocoder.GeocodeSearch
import com.amap.api.services.geocoder.RegeocodeQuery
import com.amap.api.services.geocoder.RegeocodeResult
import com.amap.api.services.weather.*
import com.amap.api.services.weather.WeatherSearchQuery.WEATHER_TYPE_LIVE
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class LocationMethod : MethodChannel.MethodCallHandler, WeatherSearch.OnWeatherSearchListener, AMapLocationListener, GeocodeSearch.OnGeocodeSearchListener {

    private val weatherHandlers = SparseArray<(LocalWeatherLive?, MethodChannel.Result) -> Unit>()
    private val weatherResults = SparseArray<MethodChannel.Result>()

    private val reGeoHandlers = SparseArray<(RegeocodeResult?, MethodChannel.Result) -> Unit>()
    private val reGeoResults = SparseArray<MethodChannel.Result>()

    private val locationResults = ArrayList<MethodChannel.Result>()
    private val locationClients = ArrayList<AMapLocationClient>()

    private var channel: MethodChannel? = null
    private var context: Context? = null

    private lateinit var weatherSearch: WeatherSearch
    private lateinit var geocoderSearch: GeocodeSearch


    fun doInit(context: Context, binaryMessenger: BinaryMessenger) {
        this.context = context

        weatherSearch = WeatherSearch(context)
        weatherSearch.setOnWeatherSearchListener(this)

        geocoderSearch = GeocodeSearch(context)
        geocoderSearch.setOnGeocodeSearchListener(this)

        channel = MethodChannel(binaryMessenger, "amap_location_method")
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "getLocation" -> this.getLocation(result)
            "getWeather" -> (call.arguments as? String)?.let { adcode ->
                assert(this::weatherSearch.isInitialized) { "Weather search client is not initialized. run doInit() first." }
                assert(adcode.isNotBlank()) { "No city adCode passed in." }
                val query = WeatherSearchQuery(adcode, WEATHER_TYPE_LIVE)
                weatherSearch.query = query
                val invokeId = query.hashCode()
                this.weatherResults.put(invokeId, result)
                this.weatherHandlers.put(invokeId) { weatherLive, result ->
                    val map = HashMap<String, String?>().also {
                        weatherLive?.let { weatherLive ->
                            it["adcode"] = weatherLive.adCode
                            it["province"] = weatherLive.province
                            it["city"] = weatherLive.city
                            it["weather"] = weatherLive.weather
                            it["temperature"] = weatherLive.temperature
                            it["windDirection"] = weatherLive.windDirection
                            it["windPower"] = weatherLive.windPower
                            it["humidity"] = weatherLive.humidity
                            it["reportTime"] = weatherLive.reportTime
                        }
                    }
                    result.success(map)
                }
                weatherSearch.searchWeatherAsyn()
            }
            else -> result.notImplemented()
        }
    }


    private fun getLocation(result: MethodChannel.Result) {

        val client = AMapLocationClient(context)
        client.setLocationListener(this)
        val option = AMapLocationClientOption()

        option.locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
        option.isOnceLocation = true
        option.isNeedAddress = true
        option.isGpsFirst = true
        option.httpTimeOut = 8000
        client.setLocationOption(option)
        client.startLocation()

        locationResults.add(result)
        locationClients.add(client)
    }

    override fun onWeatherLiveSearched(weatherLiveResult: LocalWeatherLiveResult?, rCode: Int) {
        weatherLiveResult?.weatherLiveQuery.hashCode().let { invokeId ->
            weatherHandlers[invokeId]?.let { handler ->
                weatherResults[invokeId]?.let { result ->
                    handler(weatherLiveResult?.liveResult, result)
                    weatherHandlers.delete(invokeId)
                    weatherResults.delete(invokeId)
                }
            }
        }
    }

    override fun onLocationChanged(amapLocation: AMapLocation) {
        if (locationClients.isEmpty()) {
            return
        }

        assert(this::geocoderSearch.isInitialized) { "Geocoder search client is not initialized. run doInit() first." }
        assert(locationResults.size >= locationClients.size)

        if (amapLocation.adCode.isNullOrBlank()) {
            for (i in locationClients.indices) {
                val query = RegeocodeQuery(LatLonPoint(amapLocation.latitude, amapLocation.longitude), 200f, GeocodeSearch.AMAP)
                val invokeId = query.hashCode()
                reGeoResults.put(invokeId, locationResults[i])
                reGeoHandlers.put(invokeId) { reGeo, result ->
                    val address = reGeo?.regeocodeAddress
                    val map = HashMap<String, Any?>().also {
                        it["country"] = address?.country
                        it["province"] = address?.province
                        it["city"] = address?.city
                        it["citycode"] = address?.cityCode
                        it["district"] = address?.district
                        it["street"] = address?.streetNumber?.street
                        it["adcode"] = address?.adCode
                        it["formattedAddress"] = address?.formatAddress
                        it["latitude"] = amapLocation.latitude
                        it["longitude"] = amapLocation.longitude
                    }
                    result.success(map)
                }
                geocoderSearch.getFromLocationAsyn(query)
                locationClients[i].let {
                    it.stopLocation()
                    it.onDestroy()
                }
            }
        } else {
            val map = HashMap<String, Any?>().also {
                it["country"] = amapLocation.country
                it["province"] = amapLocation.province
                it["city"] = amapLocation.city
                it["citycode"] = amapLocation.cityCode
                it["district"] = amapLocation.district
                it["street"] = amapLocation.street
                it["adcode"] = amapLocation.adCode
                it["formattedAddress"] = amapLocation.address
                it["latitude"] = amapLocation.latitude
                it["longitude"] = amapLocation.longitude
            }
            for (i in locationClients.indices) {
                locationResults[i].success(map)
                locationClients[i].let {
                    it.stopLocation()
                    it.onDestroy()
                }
            }
        }
        locationResults.clear()
        locationClients.clear()
    }


    override fun onWeatherForecastSearched(weatherLiveResult: LocalWeatherForecastResult?, rCode: Int) {
        // do nothing.
    }

    override fun onRegeocodeSearched(searchResult: RegeocodeResult?, rCode: Int) {
        searchResult?.regeocodeQuery.hashCode().let { invokeId ->
            reGeoHandlers[invokeId]?.let { handler ->
                reGeoResults[invokeId]?.let { result ->
                    handler(searchResult, result)
                    reGeoHandlers.delete(invokeId)
                    reGeoResults.delete(invokeId)
                }
            }
        }
    }

    override fun onGeocodeSearched(searchResult: GeocodeResult?, rCode: Int) {
        // do nothing.
    }
}