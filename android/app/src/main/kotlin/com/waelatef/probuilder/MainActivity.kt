package com.waelatef.probuilder

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.waelatef.probuilder/build_engine"

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

                val outcome = ApkBuilderEngine().build(
                    htmlPath = args["htmlPath"] as? String,
                    appName = args["appName"] as? String,
                    packageName = args["packageName"] as? String,
                    iconPath = args["iconPath"] as? String,
                )
                result.success(outcome)
            }
    }
}
