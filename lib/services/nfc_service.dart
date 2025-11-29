import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import '../models/portfolio_data.dart';

class NFCService {
  static const platform = MethodChannel('nfc_hce_channel');
  static Future<bool> isNFCAvailable() async {
    final availability = await NfcManager.instance.checkAvailability();
    return availability == NfcAvailability.enabled;
  }

  // Read URL from another NFC-enabled phone
  static Future<String?> readNFC() async {
    bool isAvailable = await isNFCAvailable();
    if (!isAvailable) {
      throw Exception('NFC is not available on this device');
    }

    String? detectedUrl;

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          var ndef = Ndef.from(tag);

          if (ndef != null && ndef.cachedMessage != null) {
            for (var record in ndef.cachedMessage!.records) {
              // Check for URI record
              if (record.typeNameFormat == TypeNameFormat.wellKnown &&
                  record.type.isNotEmpty &&
                  record.type[0] == 85) {
                // 'U' = 85 in ASCII
                detectedUrl = _decodeUriRecord(record);
                break;
              }
            }
          }

          await NfcManager.instance.stopSession();
        } catch (e) {
          await NfcManager.instance.stopSession();
          rethrow;
        }
      },
    );

    return detectedUrl;
  }

  // Write portfolio data to NFC tag (for NFC cards/stickers)
  static Future<String> writeToNFC(PortfolioData portfolioData) async {
    bool isAvailable = await isNFCAvailable();
    if (!isAvailable) {
      return 'NFC is not available on this device';
    }

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          try {
            var ndef = Ndef.from(tag);

            if (ndef == null) {
              await NfcManager.instance.stopSession();
              throw Exception('Tag is not NDEF compatible');
            }

            if (!ndef.isWritable) {
              await NfcManager.instance.stopSession();
              throw Exception('Tag is not writable');
            }

            // Create vCard format
            String vCard = _createVCard(portfolioData);

            // Create NDEF records
            List<NdefRecord> records = [_createTextRecord(vCard)];

            // Add website URL if available
            if (portfolioData.website.isNotEmpty) {
              records.add(_createUriRecord(portfolioData.website));
            }

            // Write to tag
            await ndef.write(message: NdefMessage(records: records));
            await NfcManager.instance.stopSession();
          } catch (e) {
            await NfcManager.instance.stopSession();
            rethrow;
          }
        },
      );
      return 'success';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // Check if HCE (Host Card Emulation) is supported
  static Future<bool> isHCESupported() async {
    try {
      final bool result = await platform.invokeMethod('isHCESupported');
      return result;
    } catch (e) {
      return false;
    }
  }

  // Share URL via HCE - makes your phone act as an NFC tag
  // Works with ANY phone (no app needed on receiver)
  static Future<void> pushURL(String url) async {
    bool isAvailable = await isNFCAvailable();
    if (!isAvailable) {
      throw Exception('NFC is not available on this device');
    }

    bool hceSupported = await isHCESupported();
    if (!hceSupported) {
      throw Exception(
        'HCE (Host Card Emulation) is not supported on this device',
      );
    }

    try {
      // Start HCE mode - your phone becomes an NFC tag
      await platform.invokeMethod('startHCE', {'url': url});

      // Keep the HCE service active
      // It will automatically respond when another phone taps
    } catch (e) {
      rethrow;
    }
  }

  // Stop HCE mode
  static Future<void> stopHCE() async {
    try {
      await platform.invokeMethod('stopHCE');
    } catch (e) {
      // Ignore errors when stopping
    }
  }

  // Decode URI record from NFC tag
  static String _decodeUriRecord(NdefRecord record) {
    if (record.payload.isEmpty) return '';

    final uriPrefixes = [
      '',
      'http://www.',
      'https://www.',
      'http://',
      'https://',
      'tel:',
      'mailto:',
      'ftp://anonymous:anonymous@',
      'ftp://ftp.',
      'ftps://',
      'sftp://',
      'smb://',
      'nfs://',
      'ftp://',
      'dav://',
      'news:',
      'telnet://',
      'imap:',
      'rtsp://',
      'urn:',
      'pop:',
      'sip:',
      'sips:',
      'tftp:',
      'btspp://',
      'btl2cap://',
      'btgoep://',
      'tcpobex://',
      'irdaobex://',
      'file://',
      'urn:epc:id:',
      'urn:epc:tag:',
      'urn:epc:pat:',
      'urn:epc:raw:',
      'urn:epc:',
      'urn:nfc:',
    ];

    final prefixCode = record.payload[0];
    final prefix = prefixCode < uriPrefixes.length
        ? uriPrefixes[prefixCode]
        : '';
    final uriBytes = record.payload.sublist(1);
    final uri = utf8.decode(uriBytes);

    return '$prefix$uri';
  }

  // Create a text NDEF record
  static NdefRecord _createTextRecord(String text) {
    final languageCodeBytes = utf8.encode('en');
    final textBytes = utf8.encode(text);
    final payload = Uint8List.fromList([
      languageCodeBytes.length,
      ...languageCodeBytes,
      ...textBytes,
    ]);

    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList(utf8.encode('T')), // 'T' for text
      identifier: Uint8List(0),
      payload: payload,
    );
  }

  // Create a URI NDEF record
  static NdefRecord _createUriRecord(String uri) {
    // URI identifier codes as per NDEF spec
    final uriPrefixes = {
      'http://www.': 0x01,
      'https://www.': 0x02,
      'http://': 0x03,
      'https://': 0x04,
    };

    int prefixCode = 0x00; // No prefix
    String remainingUri = uri;

    // Find matching prefix
    for (var entry in uriPrefixes.entries) {
      if (uri.startsWith(entry.key)) {
        prefixCode = entry.value;
        remainingUri = uri.substring(entry.key.length);
        break;
      }
    }

    final uriBytes = utf8.encode(remainingUri);
    final payload = Uint8List.fromList([prefixCode, ...uriBytes]);

    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList(utf8.encode('U')), // 'U' for URI
      identifier: Uint8List(0),
      payload: payload,
    );
  }

  // Create vCard format string
  static String _createVCard(PortfolioData data) {
    return '''BEGIN:VCARD
VERSION:3.0
FN:${data.name}
TITLE:${data.title}
EMAIL:${data.email}
TEL:${data.phone}
URL:${data.website}
${data.linkedin.isNotEmpty ? 'X-SOCIALPROFILE;TYPE=linkedin:${data.linkedin}\n' : ''}${data.github.isNotEmpty ? 'X-SOCIALPROFILE;TYPE=github:${data.github}\n' : ''}${data.bio.isNotEmpty ? 'NOTE:${data.bio}\n' : ''}END:VCARD''';
  }

  // Stop any active NFC session
  static Future<void> stopSession() async {
    await NfcManager.instance.stopSession();
  }
}
