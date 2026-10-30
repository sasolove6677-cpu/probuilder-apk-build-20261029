package com.waelatef.probuilder

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "com.waelatef.probuilder/build_engine"
    private val buildExecutor = Executors.newSingleThreadExecutor()
    private var buildInProgress = false
    private var permissionPending: PendingBuild? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "buildApk") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val args = call.arguments as? Map<*, *>
                if (args == null) {
                    result.error("INVALID_ARGUMENTS", "Build arguments are missing.", null)
                    return@setMethodCallHandler
                }
                val pending = PendingBuild(
                    htmlPath = args["htmlPath"] as? String,
                    outputName = args["outputName"] as? String,
                    iconPath = args["iconPath"] as? String,
                    result = result,
                )
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q &&
                    checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                ) {
                    if (buildInProgress || permissionPending != null) {
                        result.error("BUILD_IN_PROGRESS", "Another APK build is already running.", null)
                        return@setMethodCallHandler
                    }
                    permissionPending = pending
                    requestPermissions(
                        arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                        REQUEST_WRITE_STORAGE,
                    )
                } else {
                    startBuild(pending)
                }
            }
    }

    @Suppress("DEPRECATION")
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_WRITE_STORAGE) return
        val pending = permissionPending ?: return
        permissionPending = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            startBuild(pending)
        } else {
            pending.result.success(
                mapOf(
                    "success" to false,
                    "errorCode" to "STORAGE_PERMISSION_DENIED",
                    "message" to "Storage permission is needed to save the APK in Downloads.",
                    "apkPath" to null,
                ),
            )
        }
    }

    private fun startBuild(pending: PendingBuild) {
        if (buildInProgress) {
            pending.result.error("BUILD_IN_PROGRESS", "Another APK build is already running.", null)
            return
        }
        buildInProgress = true
        buildExecutor.execute {
            val resultMap = ApkBuilderEngine(applicationContext).build(
                pending.htmlPath,
                pending.outputName,
                pending.iconPath,
            )
            runOnUiThread {
                buildInProgress = false
                pending.result.success(resultMap)
            }
        }
    }

    private data class PendingBuild(
        val htmlPath: String?,
        val outputName: String?,
        val iconPath: String?,
        val result: MethodChannel.Result,
    )

    companion object {
        private const val REQUEST_WRITE_STORAGE = 7042
    }
}
