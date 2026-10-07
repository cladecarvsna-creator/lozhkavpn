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
        var instance: LozhkaVpnService? = null
    }

    private var process: Process? = null
    private var tunFd: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START" -> {
                val config = intent.getStringExtra("config") ?: return START_NOT_STICKY
                startTunnel(config)
            }
            "STOP" -> stopTunnel()
        }
        return START_STICKY
    }

    private fun startTunnel(config: String) {
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

        // write config — remove tun inbound, use redirect/tproxy instead for non-root
        val configDir = File(filesDir, "singbox")
        configDir.mkdirs()
        val configFile = File(configDir, "config.json")

        // modify config: replace tun with mixed inbound for proxy mode
        val modifiedConfig = config
            .replace("\"type\": \"tun\"", "\"type\": \"mixed\"")
            .replace("\"tag\": \"tun-in\"", "\"tag\": \"mixed-in\"")

        // build proxy-mode config with socks/http inbound
        val proxyConfig = """
        {
            "log": {"level": "info", "timestamp": true},
            "dns": {
                "servers": [
                    {"tag": "dns-remote", "address": "https://1.1.1.1/dns-query", "detour": "proxy"},
                    {"tag": "dns-direct", "address": "https://77.88.8.8/dns-query", "detour": "direct"}
                ],
                "strategy": "prefer_ipv4"
            },
            "inbounds": [
                {
                    "type": "mixed",
                    "tag": "mixed-in",
                    "listen": "127.0.0.1",
                    "listen_port": 2080,
                    "sniff": true,
                    "sniff_override_destination": true
                }
            ],
            ${extractOutboundsAndRoute(config)}
        }
        """.trimIndent()

        configFile.writeText(proxyConfig)

        // Setup VPN to redirect traffic through local proxy
        val builder = Builder()
            .setSession("ложка")
            .setMtu(1500)
            .addAddress("172.19.0.1", 30)
            .addRoute("0.0.0.0", 0)
            .addRoute("::", 0)
            .addDnsServer("1.1.1.1")
            .addDnsServer("8.8.8.8")

        // exclude our own app to prevent loops
        try {
            builder.addDisallowedApplication(packageName)
        } catch (_: Exception) {}

        tunFd = builder.establish()
        if (tunFd == null) {
            Log.e(TAG, "failed to establish VPN")
            stopSelf()
            return
        }

        // extract and run sing-box binary
        val singboxBin = extractBinary()
        if (singboxBin == null) {
            Log.e(TAG, "sing-box binary not found")
            stopTunnel()
            return
        }

        try {
            val pb = ProcessBuilder(singboxBin, "run", "-c", configFile.absolutePath, "-D", configDir.absolutePath)
            pb.directory(configDir)
            pb.redirectErrorStream(true)
            process = pb.start()

            // protect the sing-box process sockets
            Thread {
                process?.inputStream?.bufferedReader()?.forEachLine { line ->
                    Log.d(TAG, line)
                    if (line.contains("started") || line.contains("inbound")) {
                        isRunning = true
                    }
                }
            }.start()

            isRunning = true
            Log.i(TAG, "sing-box started")
        } catch (e: Exception) {
            Log.e(TAG, "failed to start sing-box", e)
            stopTunnel()
        }
    }

    private fun extractOutboundsAndRoute(originalConfig: String): String {
        // extract outbounds and route sections from original config
        try {
            val org = org.json.JSONObject(originalConfig)
            val outbounds = org.optJSONArray("outbounds") ?: return ""
            val route = org.optJSONObject("route")
            val sb = StringBuilder()
            sb.append("\"outbounds\": ${outbounds}")
            if (route != null) {
                sb.append(",\n\"route\": ${route}")
            }
            return sb.toString()
        } catch (e: Exception) {
            Log.e(TAG, "failed to parse config", e)
            return "\"outbounds\": [{\"type\": \"direct\", \"tag\": \"proxy\"}, {\"type\": \"direct\", \"tag\": \"direct\"}, {\"type\": \"block\", \"tag\": \"block\"}, {\"type\": \"dns\", \"tag\": \"dns-out\"}]"
        }
    }

    private fun extractBinary(): String? {
        val extracted = File(filesDir, "sing-box")
        if (extracted.exists() && extracted.canExecute()) return extracted.absolutePath

        try {
            assets.open("sing-box").use { input ->
                FileOutputStream(extracted).use { output ->
                    input.copyTo(output)
                }
            }
            extracted.setExecutable(true, false)
            return extracted.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "cannot extract sing-box binary", e)
            return null
        }
    }

    private fun stopTunnel() {
        try {
            process?.destroy()
            process?.waitFor()
        } catch (_: Exception) {}
        process = null

        try { tunFd?.close() } catch (_: Exception) {}
        tunFd = null

        isRunning = false
        instance = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
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

    override fun onRevoke() {
        stopTunnel()
        super.onRevoke()
    }

    override fun onDestroy() {
        stopTunnel()
        super.onDestroy()
    }
}
