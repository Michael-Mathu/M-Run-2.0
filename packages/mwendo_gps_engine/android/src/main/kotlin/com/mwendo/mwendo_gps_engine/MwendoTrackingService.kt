package com.mwendo.mwendo_gps_engine

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.location.Location
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import java.util.UUID

/**
 * Foreground service that owns the GPS subscription so a run keeps recording
 * after the app is backgrounded or the screen is locked. The plugin binds to
 * this service and forwards location updates to Flutter via the EventChannel.
 */
class MwendoTrackingService : Service() {

    interface LocationListener {
        fun onLocation(point: Map<String, Any?>)
    }

    private val binder = LocalBinder()
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var locationCallback: LocationCallback? = null
    private var listener: LocationListener? = null

    var activityId = ""
    private var startTime = 0L
    // True once the service has successfully entered the foreground. If this
    // stays false the run must not be treated as recording (see onStartCommand).
    var foregroundReady = false

    inner class LocalBinder : Binder() {
        fun getService(): MwendoTrackingService = this@MwendoTrackingService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        foregroundReady = startInForeground()
        if (!foregroundReady) {
            // Cannot run as a foreground service (e.g. notification policy).
            // Tear down immediately so the system never fires
            // RemoteServiceException for a service that entered foreground mode
            // but never called startForeground() successfully (C2).
            stopSelf()
            return START_NOT_STICKY
        }
        return START_STICKY
    }

    fun start(profile: String) {
        activityId = UUID.randomUUID().toString()
        startTime = System.currentTimeMillis()

        val interval = when (profile) {
            "powerSaver" -> 20000L
            "ultraSaver" -> 30000L
            else -> 5000L
        }
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                for (loc in result.locations) processLocation(loc)
            }
        }
        val request = LocationRequest.Builder(interval).apply {
            setPriority(Priority.PRIORITY_HIGH_ACCURACY)
            setWaitForAccurateLocation(false)
            if (profile == "standard") setMinUpdateDistanceMeters(3f)
        }.build()
        
        requestLocationUpdatesWithRetry(request, locationCallback!!, 3, 250L)
    }

    fun resume() {
        val request = LocationRequest.Builder(5000L)
            .setPriority(Priority.PRIORITY_HIGH_ACCURACY)
            .build()
        locationCallback?.let {
            requestLocationUpdatesWithRetry(request, it, 3, 250L)
        }
    }

    private fun requestLocationUpdatesWithRetry(
        request: LocationRequest,
        callback: LocationCallback,
        maxRetries: Int,
        delayMs: Long
    ) {
        val executor = ContextCompat.getMainExecutor(this)
        var retries = 0
        
        fun attempt() {
            try {
                fusedLocationClient.requestLocationUpdates(
                    request,
                    executor,
                    callback
                )
            } catch (e: SecurityException) {
                if (retries < maxRetries) {
                    retries++
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        attempt()
                    }, delayMs)
                } else {
                    e.printStackTrace()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        
        attempt()
    }

    fun pause() {
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
    }

    fun stop(): Map<String, Any?> {
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
        val duration = (System.currentTimeMillis() - startTime).toInt()
        return mapOf(
            "activity_id" to activityId,
            "duration_ms" to duration,
        )
    }

    fun setListener(l: LocationListener?) {
        listener = l
    }

    private fun processLocation(location: Location) {
        val speedMps = maxOf(0.0, location.speed.toDouble())
        
        try {
            listener?.onLocation(
                mapOf(
                    "lat" to location.latitude,
                    "lng" to location.longitude,
                    "elevation" to location.altitude,
                    "timestamp" to location.time,
                    "speed" to speedMps,
                    "accuracy" to location.accuracy.toDouble(),
                    "verticalAccuracy" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && location.hasVerticalAccuracy()) location.verticalAccuracyMeters.toDouble() else null,
                    "hdop" to null, // Android Location API doesn't expose HDOP directly
                    "satelliteCount" to location.extras?.getInt("satellites"),
                    "provider" to location.provider,
                    "isMocked" to location.isFromMockProvider,
                    "fixType" to "unknown", // Not exposed directly
                    "bearing" to if (location.hasBearing()) location.bearing.toDouble() else null,
                    "bearingAccuracy" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && location.hasBearingAccuracy()) location.bearingAccuracyDegrees.toDouble() else null,
                ),
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startInForeground(): Boolean {
        val channelId = "mwendo_tracking"
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Run tracking",
                NotificationManager.IMPORTANCE_LOW,
            )
            channel.setShowBadge(false)
            manager.createNotificationChannel(channel)
        }
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val contentIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Mwendo is tracking your run")
            .setContentText("Your location is recorded in the background.")
            .setSmallIcon(R.drawable.ic_run_notification)
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceCompat.startForeground(
                    this,
                    1,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION,
                )
            } else {
                startForeground(1, notification)
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback: start foreground without location type to satisfy the OS 10-second 
            // requirement, preventing a fatal RemoteServiceException crash before stopSelf() is called.
            try {
                startForeground(1, notification)
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
            false
        }
    }

    override fun onDestroy() {
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
        super.onDestroy()
    }
}
