package com.freshhen.app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Opens a saved PDF (a MediaStore content:// link) in the phone's PDF viewer.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.freshhen.app/files")
            .setMethodCallHandler { call, result ->
                if (call.method != "openPdf") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val uri = call.argument<String>("uri")
                if (uri == null) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(Uri.parse(uri), "application/pdf")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                try {
                    startActivity(intent)
                    result.success(true)
                } catch (e: ActivityNotFoundException) {
                    result.success(false)
                }
            }
    }
}
