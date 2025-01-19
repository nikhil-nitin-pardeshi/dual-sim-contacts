package com.example.dual_sim_info

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SIM_CHANNEL = "com.example.dual_sim_info/sim_details"
    private val CONTACT_CHANNEL = "com.example.dual_sim_info/contact_details"
    private val TAG = "MainActivity"
    private val PERMISSION_REQUEST_CODE = 1

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Sim details method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SIM_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSimDetails") {
                val simDetails = SimUtils.getSimDetails(this)
                result.success(simDetails)
            } else {
                result.notImplemented()
            }
        }

        // Contact details method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTACT_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getContacts") {
                val contacts = ContactUtils.getContacts(this)
                result.success(contacts)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestPhonePermissions()
    }

    private fun requestPhonePermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_NUMBERS) != PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_PHONE_STATE, Manifest.permission.READ_PHONE_NUMBERS, Manifest.permission.READ_CONTACTS), PERMISSION_REQUEST_CODE)
        }
    }
}
