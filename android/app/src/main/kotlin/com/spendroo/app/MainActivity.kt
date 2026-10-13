package com.spendroo.app

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Puts a report the app downloaded where the user's other downloads are
        // (lib/features/reports/report_repository.dart)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "spendroo/downloads")
            .setMethodCallHandler { call, result ->
                if (call.method != "save") return@setMethodCallHandler result.notImplemented()
                val path = call.argument<String>("path")
                val name = call.argument<String>("name")
                val mime = call.argument<String>("mime")
                if (path == null || name == null || mime == null) {
                    return@setMethodCallHandler result.error("bad_arguments", "path, name and mime are required", null)
                }
                val main = Handler(Looper.getMainLooper())
                thread {
                    try {
                        val saved = saveToDownloads(File(path), name, mime)
                        main.post { result.success(saved) }
                    } catch (error: Exception) {
                        main.post { result.error("save_failed", error.message, null) }
                    }
                }
            }
    }

    /**
     * Copies the file into Downloads/Spendroo and returns where it ended up,
     * as the Files app shows it. Null before Android 10, where the shared
     * Downloads folder cannot be written without a storage permission.
     */
    private fun saveToDownloads(source: File, name: String, mime: String): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
        val folder = Environment.DIRECTORY_DOWNLOADS + "/" + FOLDER
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, name)
            put(MediaStore.Downloads.MIME_TYPE, mime)
            put(MediaStore.Downloads.RELATIVE_PATH, folder)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val resolver = applicationContext.contentResolver
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("The Downloads folder is not available.")
        try {
            resolver.openOutputStream(uri).use { output ->
                checkNotNull(output) { "The file could not be opened for writing." }
                source.inputStream().use { input -> input.copyTo(output) }
            }
            resolver.update(uri, ContentValues().apply { put(MediaStore.Downloads.IS_PENDING, 0) }, null, null)
        } catch (error: Exception) {
            // Nothing half-written is left behind
            resolver.delete(uri, null, null)
            throw error
        }
        // A second download of the same report is renamed by the system: "name (1).pdf"
        val stored = resolver.query(uri, arrayOf(MediaStore.Downloads.DISPLAY_NAME), null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) cursor.getString(0) else null
        } ?: name
        return "$folder/$stored"
    }

    companion object {
        private const val FOLDER = "Spendroo"
    }
}
