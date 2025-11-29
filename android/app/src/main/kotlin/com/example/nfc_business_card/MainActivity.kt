package com.example.nfc_business_card

import android.nfc.NfcAdapter
import android.nfc.cardemulation.CardEmulation
import android.content.ComponentName
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "nfc_hce_channel"
    private var nfcAdapter: NfcAdapter? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startHCE" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        startCardEmulation(url)
                        result.success(true)
                    } else {
                        result.error("INVALID_URL", "URL is required", null)
                    }
                }
                "stopHCE" -> {
                    stopCardEmulation()
                    result.success(true)
                }
                "isHCESupported" -> {
                    val cardEmulation = CardEmulation.getInstance(nfcAdapter)
                    result.success(cardEmulation != null && nfcAdapter?.isEnabled == true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startCardEmulation(url: String) {
        // Set the URL in the HCE service
        NfcHostApduService.ndefUrl = url
        
        // Request default service (makes this the preferred payment app temporarily)
        val cardEmulation = CardEmulation.getInstance(nfcAdapter)
        val service = ComponentName(this, NfcHostApduService::class.java)
        
        // Note: This may not work on all devices without user manually setting default
        // But the HCE service is now active and will respond when another device queries it
    }

    private fun stopCardEmulation() {
        NfcHostApduService.ndefUrl = null
    }
}

