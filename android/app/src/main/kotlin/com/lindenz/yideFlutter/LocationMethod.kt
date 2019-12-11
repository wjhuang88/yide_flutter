package com.lindenz.yideFlutter

import android.content.Context
import android.util.Log
import android.util.SparseArray
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.services.weather.*
import com.amap.api.services.weather.WeatherSearchQuery.WEATHER_TYPE_LIVE
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class LocationMethod : MethodChannel.MethodCallHandler, WeatherSearch.OnWeatherSearchListener, AMapLocationListener {

    private val weatherHandlers = SparseArray<(LocalWeatherLive?, MethodChannel.Result) -> Unit>()
    private val weatherResults = SparseArray<MethodChannel.Result>()

    private val locationResults = ArrayList<MethodChannel.Result>()
    private val locationClients = ArrayList<AMapLocationClient>()

    private var channel: MethodChannel? = null
    private var context: Context? = null


    fun doInit(context: Context, binaryMessenger: BinaryMessenger) {
        this.context = context
        channel = MethodChannel(binaryMessenger, "amap_location_method")
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "getLocation" -> this.getLocation(result)
            "getWeather" -> (call.arguments as? String)?.let { adcode ->
                if (adcode.isBlank()) {
                    result.error("x", "No city adCode passed in.", "No city adCode passed in.")
                    return
                }
                val query = WeatherSearchQuery(adcode, WEATHER_TYPE_LIVE)
                val weatherSearch = WeatherSearch(context)
                weatherSearch.setOnWeatherSearchListener(this)
                weatherSearch.query = query
                val invokeId = query.hashCode()
                this.weatherResults.put(invokeId, result)
                this.weatherHandlers.put(invokeId) { weatherLive, result ->
                    val map = HashMap<String, String>().also {
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
        assert(locationResults.size == locationClients.size)
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
        locationResults.clear()
        locationClients.clear()
    }


    override fun onWeatherForecastSearched(weatherLiveResult: LocalWeatherForecastResult?, rCode: Int) {
        // do nothing.
    }
}