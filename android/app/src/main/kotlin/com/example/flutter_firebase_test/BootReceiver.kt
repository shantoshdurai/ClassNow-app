package com.example.flutter_firebase_test

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "BootReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Device boot completed, rescheduling notifications")
            
            // Reschedule all notifications after device reboot
            val scheduler = NotificationSchedulerService(context)
            scheduler.scheduleAllNotifications()
            
            Log.d(TAG, "Notifications rescheduled after boot")
        }
    }
}
