package me.filleduchaos.venetiangallery

import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.facade.Flutter
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.Manifest.permission
import android.annotation.TargetApi
import android.content.pm.PackageManager
import android.os.Build
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.view.View
import android.widget.Toast

class MainActivity : AppCompatActivity() {
    private val channel = "me.filleduchaos/images"
    private var imageList: ArrayList<String> = ArrayList()
    private val readRequestStorage = 31415

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        if (hasStoragePermission()) {
            venetianSetup()
        } else {
            requestStoragePermission()
        }
    }

    private fun hasStoragePermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true

        val permissionStatus = ContextCompat.checkSelfPermission(this, permission.READ_EXTERNAL_STORAGE)
        return permissionStatus == PackageManager.PERMISSION_GRANTED
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private fun requestStoragePermission() {
        ActivityCompat.requestPermissions(this,
                arrayOf(permission.READ_EXTERNAL_STORAGE),
                readRequestStorage)
    }

    private fun venetianSetup() {
        loadFirstTenImages()

        val venetianView = Flutter.createView(this, lifecycle, getImage())

        GeneratedPluginRegistrant.registerWith(venetianView.pluginRegistry)

        MethodChannel(venetianView, channel).setMethodCallHandler { call, result ->
            if (call.method == "getImage") {
                result.success(getImage())
            } else {
                result.notImplemented()
            }
        }

        val layout = findViewById<View>(R.id.venetian_view_container)
        addContentView(venetianView, layout.layoutParams)
    }

    private fun loadFirstTenImages() {
        val columns = arrayOf(MediaStore.Images.ImageColumns.DATA)
        val dateTaken = MediaStore.Images.ImageColumns.DATE_TAKEN
        val cursor = contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                columns,
                null,
                null,
                "$dateTaken desc limit 10"
        )

        if (cursor.moveToFirst()) {
            val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            do {
                val data = cursor.getString(dataColumn)
                imageList.add(data)
            } while (cursor.moveToNext())
        }
        cursor.close()
    }

    private fun getImage(): String? {
        if (imageList.isEmpty()) {
            return null
        }

        return imageList.shuffled().first()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        when (requestCode) {
            readRequestStorage -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    venetianSetup()
                } else {
                    Toast.makeText(this, R.string.permissions_explanation, Toast.LENGTH_LONG).show()
                    requestStoragePermission()
                }
            }
            else -> {
                super.onRequestPermissionsResult(requestCode, permissions, grantResults)
            }
        }
    }
}
