package com.lindenz.yideFlutter

import android.Manifest.permission.*
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Bundle
import android.util.DisplayMetrics
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {

  private val locationMethod = LocationMethod()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    val outMetrics = DisplayMetrics()
    windowManager.defaultDisplay.getMetrics(outMetrics)

    val viewFactory = MapViewFactory(flutterView, savedInstanceState, outMetrics.heightPixels, outMetrics.widthPixels)
    val mapRegister = registrarFor(viewFactory.flutterId)
    mapRegister.platformViewRegistry().registerViewFactory(viewFactory.flutterId, viewFactory)

    checkPermission()
  }

  private fun checkPermission() {
    val acl = ContextCompat.checkSelfPermission(this, ACCESS_COARSE_LOCATION) != PERMISSION_GRANTED
    val afl = ContextCompat.checkSelfPermission(this, ACCESS_FINE_LOCATION) != PERMISSION_GRANTED
    val wes = ContextCompat.checkSelfPermission(this, WRITE_EXTERNAL_STORAGE) != PERMISSION_GRANTED
    val res = ContextCompat.checkSelfPermission(this, READ_EXTERNAL_STORAGE) != PERMISSION_GRANTED
    val rps = ContextCompat.checkSelfPermission(this, READ_PHONE_STATE) != PERMISSION_GRANTED
    val net = ContextCompat.checkSelfPermission(this, INTERNET) != PERMISSION_GRANTED
    val permissions = ArrayList<String>(6)
    var isNeedRequest = false
    if (acl) {
      permissions.add(ACCESS_COARSE_LOCATION)
      isNeedRequest = true
    }
    if (afl) {
      permissions.add(ACCESS_FINE_LOCATION)
      isNeedRequest = true
    }
    if (wes) {
      permissions.add(WRITE_EXTERNAL_STORAGE)
      isNeedRequest = true
    }
    if (res) {
      permissions.add(READ_EXTERNAL_STORAGE)
      isNeedRequest = true
    }
    if (rps) {
      permissions.add(READ_PHONE_STATE)
      isNeedRequest = true
    }
    if (net) {
      permissions.add(INTERNET)
      isNeedRequest = true
    }
    if (isNeedRequest) {
      ActivityCompat.requestPermissions(this, permissions.toTypedArray(), 0)
    } else {
      locationMethod.doInit(applicationContext, flutterView)
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    locationMethod.doInit(applicationContext, flutterView)
  }
}
