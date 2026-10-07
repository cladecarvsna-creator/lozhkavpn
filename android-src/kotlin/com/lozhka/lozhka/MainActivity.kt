package com.lozhka.lozhka

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.VpnService
import android.os.IBinder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.lozhka/singbox"
    private var methodChannel: MethodChannel? = null
    private var pendingConfig: String? = null

    companion object {
        const val VPN_PERMISSION_REQUEST = 1001
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val config = call.argument<String>("config") ?: ""
                    startTunnel(config)
                    result.success(null)
                }
                "stop" -> {
                    stopTunnel()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startTunnel(config: String) {
        val intent = VpnService.prepare(this)
        if (intent != null) {
            pendingConfig = config
            startActivityForResult(intent, VPN_PERMISSION_REQUEST)
        } else {
            launchService(config)
        }
    }

    private fun launchService(config: String) {
        val intent = Intent(this, LozhkaVpnService::class.java).apply {
            action = "START"
            putExtra("config", config)
        }
        startForegroundService(intent)
        methodChannel?.invokeMethod("onStatusChanged", "starting")

        // listen for status via broadcast
        android.os.Handler(mainLooper).postDelayed({
            if (LozhkaVpnService.isRunning) {
                methodChannel?.invokeMethod("onStatusChanged", "running")
            }
        }, 2000)
    }

    private fun stopTunnel() {
        val intent = Intent(this, LozhkaVpnService::class.java).apply {
            action = "STOP"
        }
        startService(intent)
        methodChannel?.invokeMethod("onStatusChanged", "stopped")
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_PERMISSION_REQUEST && resultCode == Activity.RESULT_OK) {
            pendingConfig?.let { launchService(it) }
            pendingConfig = null
        }
    }
}
