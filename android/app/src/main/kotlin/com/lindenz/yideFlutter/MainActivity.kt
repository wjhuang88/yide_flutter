package com.lindenz.yideFlutter

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    LocationMethod(applicationContext, flutterView)

    GeneratedPluginRegistrant.registerWith(this)
  }
}
