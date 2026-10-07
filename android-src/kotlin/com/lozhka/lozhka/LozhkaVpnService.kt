package com.lozhka.lozhka

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.File
import java.io.FileOutputStream

class LozhkaVpnService : VpnService() {

    companion object {
        const val TAG = "LozhkaVPN"
        const val NOTIFICATION_ID = 1
        const val CHANNEL_ID = "lozhka_vpn"
        var isRunning = false
        private var process: Process? = null
    }

    private var tunFd: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START" -> {
                val config = intent.getStringExtra("config") ?: return START_NOT_STICKY
                startVpn(config)
            }
            "STOP" -> stopVpn()
        }
        return START_STICKY
    }

    private fun startVpn(config: String) {
        createNotificationChannel()
        val notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("ложка")
            .setContentText("тоннель активен")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .build()
        startForeground(NOTIFICATION_ID, notification)

        // write config
        val configFile = File(filesDir, "config.json")
        FileOutputStream(configFile).use { it.write(config.toByteArray()) }

        // setup TUN
        val builder = Builder()
            .setSession("ложка")
            .addAddress("172.19.0.1", 30)
            .addRoute("0.0.0.0", 0)
            .addRoute("::", 0)
            .addDnsServer("1.1.1.1")
            .addDnsServer("8.8.8.8")
            .setMtu(9000)
            .setBlocking(false)

        tunFd = builder.establish()

        if (tunFd == null) {
            Log.e(TAG, "failed to establish tun")
            stopSelf()
            return
        }

        // start sing-box with tun fd
        val singboxPath = extractSingbox()
        if (singboxPath == null) {
            Log.e(TAG, "sing-box binary not found")
            stopSelf()
            return
        }

        try {
            val pb = ProcessBuilder(singboxPath, "run", "-c", configFile.absolutePath)
            pb.environment()["TUN_FD"] = tunFd!!.fd.toString()
            pb.redirectErrorStream(true)
            process = pb.start()
            isRunning = true

            Thread {
                process?.inputStream?.bufferedReader()?.forEachLine {
                    Log.d(TAG, it)
                }
            }.start()

            Log.i(TAG, "sing-box started")
        } catch (e: Exception) {
            Log.e(TAG, "failed to start sing-box", e)
            stopVpn()
        }
    }

    private fun stopVpn() {
        process?.destroy()
        process = null
        tunFd?.close()
        tunFd = null
        isRunning = false
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun extractSingbox(): String? {
        // sing-box binary should be in lib/ as a native library
        val nativeDir = applicationInfo.nativeLibraryDir
        val singbox = File(nativeDir, "libsingbox.so")
        if (singbox.exists()) return singbox.absolutePath

        // fallback: check assets
        val extracted = File(filesDir, "sing-box")
        if (extracted.exists()) return extracted.absolutePath

        try {
            assets.open("sing-box").use { input ->
                FileOutputStream(extracted).use { output ->
                    input.copyTo(output)
                }
            }
            extracted.setExecutable(true)
            return extracted.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "cannot extract sing-box", e)
            return null
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "ложка", NotificationManager.IMPORTANCE_LOW
            )
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        stopVpn()
        super.onDestroy()
    }
}
