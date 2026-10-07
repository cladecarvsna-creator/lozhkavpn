package com.lozhka.lozhka

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import io.nekohasekai.libbox.BoxService
import io.nekohasekai.libbox.CommandServer
import io.nekohasekai.libbox.CommandServerHandler
import io.nekohasekai.libbox.InterfaceUpdateListener
import io.nekohasekai.libbox.Libbox
import io.nekohasekai.libbox.PlatformInterface
import io.nekohasekai.libbox.StatusMessage
import java.io.File

class LozhkaVpnService : VpnService(), PlatformInterface, CommandServerHandler {

    companion object {
        const val TAG = "LozhkaVPN"
        const val NOTIFICATION_ID = 1
        const val CHANNEL_ID = "lozhka_vpn"
        var isRunning = false
        var instance: LozhkaVpnService? = null
    }

    private var boxService: BoxService? = null
    private var commandServer: CommandServer? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START" -> {
                val config = intent.getStringExtra("config") ?: return START_NOT_STICKY
                startBox(config)
            }
            "STOP" -> stopBox()
        }
        return START_STICKY
    }

    private fun startBox(config: String) {
        if (isRunning) return
        instance = this

        createNotificationChannel()
        val notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("ложка")
            .setContentText("тоннель активен")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setOngoing(true)
            .build()
        startForeground(NOTIFICATION_ID, notification)

        try {
            val configDir = File(filesDir, "sing-box")
            configDir.mkdirs()
            File(configDir, "config.json").writeText(config)

            Libbox.setup(configDir.absolutePath, configDir.absolutePath, configDir.absolutePath, false)

            boxService = BoxService(config, this)
            boxService?.start()

            isRunning = true
            Log.i(TAG, "sing-box started via libbox")
        } catch (e: Exception) {
            Log.e(TAG, "failed to start sing-box", e)
            isRunning = false
            stopSelf()
        }
    }

    private fun stopBox() {
        try {
            boxService?.close()
        } catch (e: Exception) {
            Log.e(TAG, "error stopping", e)
        }
        boxService = null
        isRunning = false
        instance = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    // PlatformInterface implementation
    override fun autoDetectInterfaceControl(fd: Int) {
        protect(fd)
    }

    override fun openTun(options: String): Int {
        val builder = Builder()
            .setSession("ложка")
            .setMtu(9000)
            .addAddress("172.19.0.1", 30)
            .addRoute("0.0.0.0", 0)
            .addRoute("::", 0)
            .addDnsServer("1.1.1.1")
            .addDnsServer("8.8.8.8")

        val fd = builder.establish() ?: throw Exception("failed to establish tun")
        return fd.detachFd()
    }

    override fun useProcFS(): Boolean = false

    override fun findConnectionOwner(ipProtocol: Int, sourceAddress: String, sourcePort: Int, destinationAddress: String, destinationPort: Int): Int = -1

    override fun packageNameByUid(uid: Int): String = ""

    override fun uidByPackageName(packageName: String): Int = 0

    override fun usePlatformDefaultInterfaceMonitor(): Boolean = true

    override fun startDefaultInterfaceMonitor(listener: InterfaceUpdateListener?) {}

    override fun closeDefaultInterfaceMonitor(listener: InterfaceUpdateListener?) {}

    override fun usePlatformInterfaceGetter(): Boolean = false

    override fun getInterfaces(): String = ""

    override fun underNetworkExtension(): Boolean = false

    override fun includeAllNetworks(): Boolean = false

    override fun readWIFIState(): String = ""

    override fun clearDNSCache() {}

    // CommandServerHandler
    override fun serviceReload() {}

    override fun getSystemProxyStatus(): StatusMessage = StatusMessage()

    override fun setSystemProxyEnabled(enabled: Boolean) {}

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
        stopBox()
        super.onDestroy()
    }
}
