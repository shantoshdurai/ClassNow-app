package com.example.flutter_firebase_test

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    
    private val CHANNEL = "com.example.flutter_firebase_test/notifications"
    private val REQUEST_EXACT_ALARM_PERMISSION = 1001
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleNotifications" -> {
                    try {
                        val scheduler = NotificationSchedulerService(applicationContext)
                        scheduler.scheduleAllNotifications()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                "cancelNotifications" -> {
                    try {
                        val scheduler = NotificationSchedulerService(applicationContext)
                        scheduler.cancelAllNotifications()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                "canScheduleExactAlarms" -> {
                    val canSchedule = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        alarmManager.canScheduleExactAlarms()
                    } else {
                        true // Pre-Android 12 doesn't need permission
                    }
                    result.success(canSchedule)
                }
                "requestExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.parse("package:$packageName")
                            }
                            startActivityForResult(intent, REQUEST_EXACT_ALARM_PERMISSION)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("PERMISSION_ERROR", e.message, null)
                        }
                    } else {
                        result.success(true) // No permission needed
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
