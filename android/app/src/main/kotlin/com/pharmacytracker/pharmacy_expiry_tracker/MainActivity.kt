package com.pharmacytracker.pharmacy_expiry_tracker

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Small helpers for the Alert health screen. Scheduling itself is done by the
 * local-notifications plugin; this only reports conditions that can silently
 * stop alerts and opens the matching system settings pages.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "conditions" -> {
                        val power = getSystemService(POWER_SERVICE) as PowerManager
                        result.success(
                            mapOf(
                                "ignoringBatteryOptimizations" to
                                    power.isIgnoringBatteryOptimizations(packageName),
                                "manufacturer" to Build.MANUFACTURER,
                            )
                        )
                    }
                    "openNotificationSettings" -> {
                        startSettings(
                            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        )
                        result.success(null)
                    }
                    "openBatterySettings" -> {
                        startSettings(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startSettings(intent: Intent) {
        try {
            startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        } catch (e: Exception) {
            // Some devices lack a dedicated page; fall back to the app's details.
            startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    .setData(Uri.parse("package:$packageName"))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            )
        }
    }

    companion object {
        const val CHANNEL = "com.pharmacytracker/alert_settings"
    }
}
