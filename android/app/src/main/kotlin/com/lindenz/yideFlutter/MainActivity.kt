package com.lindenz.yideFlutter

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

  private val locationMethod = LocationMethod()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    locationMethod.doInit(applicationContext, flutterView)
    GeneratedPluginRegistrant.registerWith(this)
  }
}
