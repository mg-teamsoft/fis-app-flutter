package com.example.fis_app_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val cropExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fis_app/receipt_crop")
            .setMethodCallHandler { call, result ->
                if (call.method != "cropDocument") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                if (path.isNullOrBlank()) {
                    result.error("invalid_image", "Image path is required", null)
                    return@setMethodCallHandler
                }
                cropExecutor.execute {
                    try {
                        val bytes = ReceiptDocumentCropper.crop(path)
                        runOnUiThread { result.success(bytes) }
                    } catch (error: Exception) {
                        runOnUiThread { result.error("crop_failed", error.message, null) }
                    }
                }
            }
    }

    override fun onDestroy() {
        cropExecutor.shutdown()
        super.onDestroy()
    }
}
