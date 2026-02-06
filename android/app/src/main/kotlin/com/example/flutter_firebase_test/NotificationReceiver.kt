package com.example.flutter_firebase_test

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

class NotificationReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "NotificationReceiver"
        private const val CHANNEL_ID = "classnow_classes"
        private const val CHANNEL_NAME = "Class Reminders"
        private const val CHANNEL_DESCRIPTION = "Notifications for upcoming classes"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Received alarm broadcast")
        
        val subject = intent.getStringExtra("subject") ?: "Class"
        val room = intent.getStringExtra("room") ?: "Unknown Room"
        val leadTime = intent.getIntExtra("leadTime", 15)
        val dayOfWeek = intent.getStringExtra("dayOfWeek") ?: ""
        val startTime = intent.getStringExtra("startTime") ?: ""
        
        // Show the notification
        showNotification(context, subject, room, leadTime)
        
        // Reschedule for next week
        rescheduleForNextWeek(context, intent, dayOfWeek, startTime)
    }
    
    private fun showNotification(context: Context, subject: String, room: String, leadTime: Int) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create notification channel (required for Android 8.0+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = CHANNEL_DESCRIPTION
                enableVibration(true)
                enableLights(true)
            }
            notificationManager.createNotificationChannel(channel)
        }
        
        // Create intent to open the app when notification is tapped
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build the notification
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Class Starting Soon: $subject")
            .setContentText("Room: $room starts in $leadTime minutes.")
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText("Your $subject class in Room $room starts in $leadTime minutes. Get ready!"))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setVibrate(longArrayOf(0, 500, 200, 500))
            .build()
        
        // Use a unique notification ID based on subject and time
        val notificationId = (subject + room).hashCode()
        notificationManager.notify(notificationId, notification)
        
        Log.d(TAG, "Notification shown for $subject in $room")
    }
    
    private fun rescheduleForNextWeek(context: Context, originalIntent: Intent, dayOfWeek: String, startTime: String) {
        try {
            // Get the class ID from the original intent to maintain the same request code
            val subject = originalIntent.getStringExtra("subject") ?: return
            val room = originalIntent.getStringExtra("room") ?: return
            val leadTime = originalIntent.getIntExtra("leadTime", 15)
            
            // Create a new intent for next week
            val newIntent = Intent(context, NotificationReceiver::class.java).apply {
                putExtra("subject", subject)
                putExtra("room", room)
                putExtra("leadTime", leadTime)
                putExtra("dayOfWeek", dayOfWeek)
                putExtra("startTime", startTime)
            }
            
            // Calculate next week's time
            val timeParts = startTime.split(":")
            if (timeParts.size != 2) return
            
            val hour = timeParts[0].toInt()
            val minute = timeParts[1].toInt()
            
            val calendar = java.util.Calendar.getInstance()
            calendar.set(java.util.Calendar.HOUR_OF_DAY, hour)
            calendar.set(java.util.Calendar.MINUTE, minute)
            calendar.set(java.util.Calendar.SECOND, 0)
            calendar.set(java.util.Calendar.MILLISECOND, 0)
            calendar.add(java.util.Calendar.MINUTE, -leadTime)
            calendar.add(java.util.Calendar.DAY_OF_WEEK, 7) // Next week
            
            val requestCode = (subject + room + dayOfWeek).hashCode()
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                requestCode,
                newIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        android.app.AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                    )
                    Log.d(TAG, "Rescheduled notification for next week")
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    android.app.AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
                Log.d(TAG, "Rescheduled notification for next week")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error rescheduling notification", e)
        }
    }
}
