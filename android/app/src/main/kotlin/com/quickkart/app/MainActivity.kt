package com.quickkart.app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val linksChannel = "quickkart/links"
    private val storageChannel = "quickkart/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, linksChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "open") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val url = call.argument<String>("url")
                if (url.isNullOrBlank()) {
                    result.error("invalid_url", "A non-empty url is required.", null)
                    return@setMethodCallHandler
                }

                try {
                    val uri = Uri.parse(url)
                    val intent = if (uri.scheme == "tel") {
                        Intent(Intent.ACTION_DIAL, uri)
                    } else {
                        Intent(Intent.ACTION_VIEW, uri)
                    }
                    startActivity(intent)
                    result.success(true)
                } catch (error: ActivityNotFoundException) {
                    result.success(false)
                } catch (error: Exception) {
                    result.success(false)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, storageChannel)
            .setMethodCallHandler { call, result ->
                val name = call.argument<String>("name")
                if (name.isNullOrBlank() || !name.matches(Regex("[A-Za-z0-9_.-]+"))) {
                    result.error("invalid_name", "A simple file name is required.", null)
                    return@setMethodCallHandler
                }

                val file = File(filesDir, name)
                when (call.method) {
                    "read" -> result.success(if (file.exists()) file.readText() else null)
                    "write" -> {
                        val content = call.argument<String>("content") ?: ""
                        try {
                            file.writeText(content)
                            result.success(true)
                        } catch (error: Exception) {
                            result.error("write_failed", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
