import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/nfc_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isNFCAvailable = false;
  bool _isWriting = false;
  bool _isReading = false;
  String? _message;
  final String portfolioUrl = 'https://isuru-portfolio-ten.vercel.app/';

  @override
  void initState() {
    super.initState();
    _checkNFC();
  }

  Future<void> _checkNFC() async {
    final isAvailable = await NFCService.isNFCAvailable();
    setState(() {
      _isNFCAvailable = isAvailable;
    });
  }

  Future<void> _pushToNFC() async {
    setState(() {
      _isWriting = true;
      _message = 'Phone is now acting as an NFC tag. Hold another phone near yours to share...';
    });

    try {
      await NFCService.pushURL(portfolioUrl);
      
      // Keep the message showing - HCE is now active
      setState(() {
        _message = '📡 Your phone is now an NFC tag! Another phone can tap to get your URL.\n\nTap again to stop.';
      });
      
      // Wait for 30 seconds or until user stops
      await Future.delayed(const Duration(seconds: 30));
      
      await NFCService.stopHCE();
      setState(() {
        _isWriting = false;
        _message = '✓ NFC sharing session ended.';
      });
    } catch (e) {
      await NFCService.stopHCE();
      setState(() {
        _isWriting = false;
        final errorMsg = e.toString();
        
        if (errorMsg.contains('not available')) {
          _message = '⚠️ NFC not available. Enable it in Settings.';
        } else if (errorMsg.contains('not supported')) {
          _message = '⚠️ Your phone doesn\'t support HCE (Host Card Emulation).';
        } else {
          _message = '⚠️ ${errorMsg.replaceAll('Exception: ', '')}';
        }
      });
    }
  }

  void _stopSharing() async {
    if (_isWriting) {
      await NFCService.stopHCE();
      setState(() {
        _isWriting = false;
        _message = 'Stopped sharing.';
      });
    }
  }

  Future<void> _readFromNFC() async {
    setState(() {
      _isReading = true;
      _message = 'Hold your phone near another NFC phone or tag...';
    });

    try {
      final url = await NFCService.readNFC();
      setState(() {
        _isReading = false;
        if (url != null && url.isNotEmpty) {
          _message = '✓ Received URL: $url';
          // Auto-launch the URL
          _launchReceivedURL(url);
        } else {
          _message = '⚠️ No URL found on the NFC source. Make sure the other phone is in share mode.';
        }
      });
    } catch (e) {
      setState(() {
        _isReading = false;
        final errorMsg = e.toString();
        
        if (errorMsg.contains('not available')) {
          _message = '⚠️ NFC is not available. Enable NFC in your phone settings.';
        } else {
          _message = '⚠️ ${errorMsg.replaceAll('Exception: ', '')}';
        }
      });
    }
  }

  Future<void> _launchURL() async {
    final uri = Uri.parse(portfolioUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchReceivedURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      setState(() {
        _message = 'Cannot open URL: $url';
      });
    }
  }

  void _showHowToUse() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, size: 28),
            SizedBox(width: 12),
            Text('How to Use'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '📱 How HCE (Host Card Emulation) Works:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Tap "Share via NFC (Be a Tag)"\n'
                '2. Your phone acts as an NFC tag\n'
                '3. Another person taps their phone to yours\n'
                '4. Their phone reads the URL (no app needed!)\n'
                '5. Browser opens automatically',
                style: TextStyle(color: Colors.grey[300], height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No app needed on the receiving phone! Works with any NFC-enabled Android phone.',
                        style: TextStyle(color: Colors.grey[300], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                '📱 Phone-to-Phone (For Testing):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'If both phones have this app:\n\n'
                '1. Phone A: Tap "Receive from Another Phone"\n'
                '2. Phone B: Tap "Share via NFC (Be a Tag)"\n'
                '3. Hold phones back-to-back for 2-3 seconds',
                style: TextStyle(color: Colors.grey[300], height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.nfc,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Isuru Pathirathna',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Portfolio NFC Card',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // NFC Status
                if (!_isNFCAvailable)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'NFC is not available on this device',
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isNFCAvailable) ...[
                  // Share Button (HCE Mode)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isReading ? null : (_isWriting ? _stopSharing : _pushToNFC),
                      icon: _isWriting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.share, size: 24),
                      label: Text(
                        _isWriting ? 'Stop Sharing' : 'Share via NFC (Be a Tag)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Receive Button (for testing with another phone that has the app)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: (_isWriting || _isReading) ? null : _readFromNFC,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      icon: _isReading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : const Icon(Icons.phonelink_ring, size: 24),
                      label: Text(
                        _isReading ? 'Ready to Receive...' : 'Receive from Another Phone',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // How to Use Button
                  TextButton.icon(
                    onPressed: _showHowToUse,
                    icon: const Icon(Icons.help_outline),
                    label: const Text('How to Use'),
                  ),

                  // Message
                  if (_message != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _message!.contains('Error')
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _message!.contains('Error')
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _message!.contains('Error')
                                ? Icons.error
                                : Icons.check_circle,
                            color: _message!.contains('Error')
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _message!,
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                const SizedBox(height: 32),

                // Preview Button
                OutlinedButton.icon(
                  onPressed: _launchURL,
                  icon: const Icon(Icons.open_in_new, size: 20),
                  label: const Text('Preview Portfolio'),
                ),

                const SizedBox(height: 48),

                // URL Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Portfolio URL',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        portfolioUrl,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
