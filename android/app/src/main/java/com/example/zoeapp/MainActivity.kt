package com.example.zoeapp

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.intozon.zon/kiosk"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Iniciar servicio SIMPLE
        val intent = Intent(this, KioskAccessibilityService::class.java)
        startService(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setKioskActive" -> {
                    val active = call.argument<Boolean>("active") ?: false
                    KioskAccessibilityService.setKioskModeState(this, active)
                    result.success(true)
                }
                "isKioskActive" -> {
                    val isActive = KioskAccessibilityService.isKioskModeActive(this)
                    result.success(isActive)
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}