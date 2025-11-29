package com.example.nfc_business_card

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.util.Log
import java.nio.charset.StandardCharsets

class NfcHostApduService : HostApduService() {
    
    companion object {
        private const val TAG = "NfcHostApduService"
        private const val SELECT_APDU_HEADER = "00A40400"
        private const val NDEF_SELECT_AID = "D2760000850101"
        private const val STATUS_SUCCESS = "9000"
        private const val STATUS_FAILED = "6F00"
        private const val CC_FILE = "E103"
        private const val NDEF_FILE = "E104"
        
        // Shared storage for the URL to emulate
        @Volatile
        var ndefUrl: String? = null
        
        // Cached NDEF message and CC
        private var cachedNdefMessage: ByteArray? = null
        private var cachedCC: ByteArray? = null
        
        // Track current selected file for context
        @Volatile
        private var currentFileId: String? = null
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        if (commandApdu == null) {
            Log.w(TAG, "Null APDU received")
            return hexStringToByteArray(STATUS_FAILED)
        }

        val hexCommandApdu = bytesToHex(commandApdu)
        Log.d(TAG, "Received APDU: $hexCommandApdu")

        // Update cached messages if URL changed or cache is empty
        val url = ndefUrl
        if (url != null) {
            if (cachedNdefMessage == null) {
                cachedNdefMessage = createNdefMessage(url)
                Log.d(TAG, "Created NDEF message for: $url")
            }
            if (cachedCC == null) {
                cachedCC = createCapabilityContainer()
                Log.d(TAG, "Created Capability Container")
            }
        } else {
            Log.w(TAG, "No URL set for HCE")
            return hexStringToByteArray(STATUS_FAILED)
        }

        // SELECT application (00A40400)
        if (hexCommandApdu.startsWith(SELECT_APDU_HEADER)) {
            val aid = hexCommandApdu.substring(10, hexCommandApdu.length - 2)
            if (aid == NDEF_SELECT_AID) {
                Log.d(TAG, "NDEF Application selected")
                return hexStringToByteArray(STATUS_SUCCESS)
            }
        }

        // SELECT file (00A4)
        if (commandApdu.size >= 5 && commandApdu[0] == 0x00.toByte() && commandApdu[1] == 0xA4.toByte()) {
            // Extract file ID from command
            val fileId = if (commandApdu.size >= 7) {
                bytesToHex(byteArrayOf(commandApdu[5], commandApdu[6]))
            } else ""
            
            Log.d(TAG, "SELECT file: $fileId")
            
            when (fileId) {
                CC_FILE -> {
                    currentFileId = CC_FILE
                    Log.d(TAG, "Capability Container selected")
                    return hexStringToByteArray(STATUS_SUCCESS)
                }
                NDEF_FILE -> {
                    currentFileId = NDEF_FILE
                    Log.d(TAG, "NDEF file selected")
                    return hexStringToByteArray(STATUS_SUCCESS)
                }
                else -> {
                    Log.d(TAG, "File select success (generic): $fileId")
                    return hexStringToByteArray(STATUS_SUCCESS)
                }
            }
        }

        // READ BINARY (00B0)
        if (commandApdu.size >= 5 && commandApdu[0] == 0x00.toByte() && commandApdu[1] == 0xB0.toByte()) {
            val offset = ((commandApdu[2].toInt() and 0xFF) shl 8) or (commandApdu[3].toInt() and 0xFF)
            val length = commandApdu[4].toInt() and 0xFF
            
            Log.d(TAG, "READ BINARY offset=$offset length=$length currentFile=$currentFileId")
            
            // Return Capability Container if CC file is selected or offset suggests CC read
            if (currentFileId == CC_FILE || (offset == 0 && length == 15)) {
                val cc = cachedCC ?: createCapabilityContainer()
                Log.d(TAG, "Returning CC: ${bytesToHex(cc)}")
                return cc + hexStringToByteArray(STATUS_SUCCESS)
            }
            
            // Return NDEF message for NDEF file or other reads
            val ndef = cachedNdefMessage
            if (ndef != null) {
                val end = minOf(offset + length, ndef.size)
                if (offset < ndef.size) {
                    val chunk = ndef.copyOfRange(offset, end)
                    Log.d(TAG, "Returning NDEF chunk: offset=$offset size=${chunk.size} of ${ndef.size}")
                    return chunk + hexStringToByteArray(STATUS_SUCCESS)
                } else {
                    Log.w(TAG, "Read offset $offset beyond NDEF size ${ndef.size}")
                    return hexStringToByteArray(STATUS_FAILED)
                }
            } else {
                Log.w(TAG, "No NDEF message cached")
                return hexStringToByteArray(STATUS_FAILED)
            }
        }

        Log.d(TAG, "Unhandled or failed command")
        return hexStringToByteArray(STATUS_FAILED)
    }

    private fun createCapabilityContainer(): ByteArray {
        // NDEF Type 4 Tag Capability Container
        // Format: [Length MSB, Length LSB, Mapping Version, MLe MSB, MLe LSB, MLc MSB, MLc LSB, 
        //          NDEF File Control TLV (Type, Length, File ID MSB, File ID LSB, Max Size MSB, Max Size LSB, Read Access, Write Access)]
        return byteArrayOf(
            0x00, 0x0F,  // CCLEN (15 bytes)
            0x20,        // Mapping version 2.0
            0x00, 0xFF.toByte(),  // MLe (255 bytes max)
            0x00, 0xFF.toByte(),  // MLc (255 bytes max)
            0x04,        // NDEF File Control TLV - Type
            0x06,        // Length (6 bytes)
            0xE1.toByte(), 0x04,  // NDEF File ID
            0x00, 0xFF.toByte(),  // NDEF file max size (255 bytes)
            0x00,        // Read access (always)
            0x00         // Write access (always)
        )
    }

    override fun onDeactivated(reason: Int) {
        Log.d(TAG, "HCE deactivated. Reason: $reason")
        // Reset file selection but keep cached messages for next tap
        currentFileId = null
    }

    private fun createNdefMessage(url: String): ByteArray {
        // Determine URI prefix code
        val (prefixCode, remainingUrl) = when {
            url.startsWith("https://www.") -> Pair(0x02.toByte(), url.substring(12))
            url.startsWith("http://www.") -> Pair(0x01.toByte(), url.substring(11))
            url.startsWith("https://") -> Pair(0x04.toByte(), url.substring(8))
            url.startsWith("http://") -> Pair(0x03.toByte(), url.substring(7))
            else -> Pair(0x00.toByte(), url)
        }

        val uriBytes = remainingUrl.toByteArray(StandardCharsets.UTF_8)
        
        // NDEF Record: TNF=0x01 (Well Known), Type='U' (URI)
        val recordHeader = 0xD1.toByte() // MB=1, ME=1, CF=0, SR=1, IL=0, TNF=0x01
        val typeLength = 0x01.toByte()
        val payloadLength = (uriBytes.size + 1).toByte()
        val recordType = 0x55.toByte() // 'U'
        
        // Build NDEF record
        val record = byteArrayOf(recordHeader, typeLength, payloadLength, recordType, prefixCode) + uriBytes
        
        // NDEF message with length prefix
        val messageLength = record.size
        val lengthBytes = byteArrayOf((messageLength shr 8).toByte(), messageLength.toByte())
        
        return lengthBytes + record
    }

    private fun bytesToHex(bytes: ByteArray): String {
        val hexArray = "0123456789ABCDEF"
        val hexChars = CharArray(bytes.size * 2)
        for (i in bytes.indices) {
            val v = bytes[i].toInt() and 0xFF
            hexChars[i * 2] = hexArray[v ushr 4]
            hexChars[i * 2 + 1] = hexArray[v and 0x0F]
        }
        return String(hexChars)
    }

    private fun hexStringToByteArray(hex: String): ByteArray {
        val len = hex.length
        val data = ByteArray(len / 2)
        var i = 0
        while (i < len) {
            data[i / 2] = ((Character.digit(hex[i], 16) shl 4) + Character.digit(hex[i + 1], 16)).toByte()
            i += 2
        }
        return data
    }
}
