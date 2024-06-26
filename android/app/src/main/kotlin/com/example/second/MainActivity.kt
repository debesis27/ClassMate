package com.example.ClassMate

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.os.Build
import android.widget.Toast
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.ParcelUuid
import java.nio.charset.Charset

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ClassMate/advertise"
    private var advertiser: BluetoothLeAdvertiser? = null
    private var advertiseCallback: AdvertiseCallback? = null

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startAdvertising" -> {
                    val id = call.argument<String>("id") ?: "defaultId"
                    startAdvertising(id)
                    result.success(null)
                }
                "stopAdvertising" -> {
                    stopAdvertising()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun startAdvertising(id: String) {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val bluetoothAdapter = bluetoothManager.adapter
        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
            Toast.makeText(this, "Bluetooth is not enabled or not available", Toast.LENGTH_SHORT).show()
            return
        }

        advertiser = bluetoothAdapter.bluetoothLeAdvertiser
        if (advertiser == null) {
            Toast.makeText(this, "BLE Advertising not supported on this device", Toast.LENGTH_SHORT).show()
            return
        }

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_POWER)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .setConnectable(true)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .setIncludeTxPowerLevel(false)
            .addServiceUuid(ParcelUuid.fromString("00000000-0000-1000-8000-00805F9B34FB"))
            .addServiceData(ParcelUuid.fromString("00000000-0000-1000-8000-00805F9B34FB"), id.toByteArray(Charset.forName("UTF-8")))
            .build()

        advertiseCallback = object : AdvertiseCallback() {
            override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
                Toast.makeText(applicationContext, "Advertising started successfully", Toast.LENGTH_SHORT).show()
            }

            override fun onStartFailure(errorCode: Int) {
                val errorMessage = when (errorCode) {
                    AdvertiseCallback.ADVERTISE_FAILED_DATA_TOO_LARGE -> "Data too large"
                    AdvertiseCallback.ADVERTISE_FAILED_TOO_MANY_ADVERTISERS -> "Too many advertisers"
                    AdvertiseCallback.ADVERTISE_FAILED_ALREADY_STARTED -> "Already started"
                    AdvertiseCallback.ADVERTISE_FAILED_INTERNAL_ERROR -> "Internal error"
                    AdvertiseCallback.ADVERTISE_FAILED_FEATURE_UNSUPPORTED -> "Feature unsupported"
                    else -> "Unknown error"
                }
                Toast.makeText(applicationContext, "Advertising failed: $errorMessage", Toast.LENGTH_SHORT).show()
            }
        }

        advertiser?.startAdvertising(settings, data, advertiseCallback)
    }

    private fun stopAdvertising() {
        advertiseCallback?.let {
            advertiser?.stopAdvertising(it)
            Toast.makeText(applicationContext, "Advertising stopped", Toast.LENGTH_SHORT).show()
        }
    }
}
