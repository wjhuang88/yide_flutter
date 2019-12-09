package com.lindenz.yideFlutter

import android.content.Context
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

class LocationMethod(private val context: Context, binaryMessenger: BinaryMessenger) : MethodChannel.MethodCallHandler, WeatherSearch.OnWeatherSearchListener, AMapLocationListener {

    private val weatherHandlers = SparseArray<(LocalWeatherLive, MethodChannel.Result) -> Unit>()
    private val weatherResults = SparseArray<MethodChannel.Result>()

    private val locationResults = ArrayList<MethodChannel.Result>()
    private val locationClients = ArrayList<AMapLocationClient>()

    init {
        MethodChannel(binaryMessenger, "amap_location_method").let {
            it.setMethodCallHandler(this)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "getLocation" -> this.getLocation(result)
            "getWeather" -> (call.arguments as? String)?.let { adcode ->
                val query = WeatherSearchQuery(adcode, WEATHER_TYPE_LIVE)
                val weatherSearch = WeatherSearch(context)
                weatherSearch.setOnWeatherSearchListener(this)
                weatherSearch.query = query
                val invokeId = query.hashCode()
                this.weatherResults.put(invokeId, result)
                this.weatherHandlers.put(invokeId) { weatherLive, result ->
                    val map = HashMap<String, String>().let {
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
                    result.success(map)
                }
                weatherSearch.searchWeatherAsyn()
            }
        }
    }

    private fun getLocation(result: MethodChannel.Result) {
        val client = AMapLocationClient(context)
        client.setLocationListener(this)
        val option = AMapLocationClientOption()

        print("start")

        option.locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
        option.isOnceLocation = true
        client.setLocationOption(option)
        client.startLocation()

        locationResults.add(result)
        locationClients.add(client)
    }

    override fun onWeatherLiveSearched(weatherLiveResult: LocalWeatherLiveResult, rCode: Int) {
        weatherLiveResult.weatherLiveQuery.hashCode().let { invokeId ->
            weatherHandlers[invokeId]?.let { handler ->
                weatherResults[invokeId]?.let { result ->
                    handler(weatherLiveResult.liveResult, result)
                    weatherHandlers.delete(invokeId)
                    weatherResults.delete(invokeId)
                }
            }
        }
    }

    override fun onLocationChanged(amapLocation: AMapLocation) {
        print("result")
        assert(locationResults.size == locationClients.size)
        val map = HashMap<String, Any?>().let {
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


    override fun onWeatherForecastSearched(weatherLiveResult: LocalWeatherForecastResult?, rCode: Int) {
        // do nothing.
    }
}