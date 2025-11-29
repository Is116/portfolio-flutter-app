import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/nfc_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isNFCAvailable = false;
  bool _isWriting = false;
  bool _isSharingWhatsApp = false;
  bool _isSharingContact = false;
  String? _message;

  // Text editing controllers for editable fields
  late TextEditingController _portfolioUrlController;
  late TextEditingController _whatsappUrlController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _portfolioUrlController = TextEditingController(
      text: 'https://isuru-portfolio-ten.vercel.app/',
    );
    _whatsappUrlController = TextEditingController(
      text: 'https://wa.me/358413671742',
    );
    _phoneNumberController = TextEditingController(text: '+358413671742');
    _checkNFC();
  }

  @override
  void dispose() {
    _portfolioUrlController.dispose();
    _whatsappUrlController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
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
      _isSharingWhatsApp = false;
      _isSharingContact = false;
      _message =
          'Ready! Hold your phone steady and have someone tap their phone to the back.';
    });

    try {
      await NFCService.pushURL(_portfolioUrlController.text);

      // Keep the session active for 60 seconds to allow multiple taps
      await Future.delayed(const Duration(seconds: 60));

      setState(() {
        _isWriting = false;
        _message = 'Session ended. Tap the button again to share.';
      });
    } catch (e) {
      setState(() {
        _isWriting = false;
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _pushWhatsAppToNFC() async {
    setState(() {
      _isSharingWhatsApp = true;
      _isWriting = false;
      _isSharingContact = false;
      _message =
          'Ready to share WhatsApp! Have someone tap their phone to the back.';
    });

    try {
      await NFCService.pushURL(_whatsappUrlController.text);

      await Future.delayed(const Duration(seconds: 60));

      setState(() {
        _isSharingWhatsApp = false;
        _message = 'WhatsApp sharing ended.';
      });
    } catch (e) {
      setState(() {
        _isSharingWhatsApp = false;
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _pushContactToNFC() async {
    setState(() {
      _isSharingContact = true;
      _isWriting = false;
      _isSharingWhatsApp = false;
      _message =
          'Ready to share contact! Have someone tap their phone to the back.';
    });

    try {
      // Share a tel: URL that will open in contacts app
      await NFCService.pushURL('tel:${_phoneNumberController.text}');

      await Future.delayed(const Duration(seconds: 60));

      setState(() {
        _isSharingContact = false;
        _message = 'Contact sharing ended.';
      });
    } catch (e) {
      setState(() {
        _isSharingContact = false;
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  void _stopSharing() async {
    if (_isWriting || _isSharingWhatsApp || _isSharingContact) {
      await NFCService.stopHCE();
      setState(() {
        _isWriting = false;
        _isSharingWhatsApp = false;
        _isSharingContact = false;
        _message = 'Stopped sharing.';
      });
    }
  }

  Future<void> _launchURL() async {
    final uri = Uri.parse(_portfolioUrlController.text);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
                '3. Hold phones back-to-back (near cameras)\n'
                '4. Keep steady for 2-3 seconds\n'
                '5. Other phone reads URL (no app needed!)\n'
                '6. Browser opens automatically\n\n'
                '💡 Tip: If it doesn\'t work, try adjusting the position slightly. The NFC antenna is usually near the camera.',
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
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.nfc), text: 'NFC Share'),
              Tab(icon: Icon(Icons.qr_code), text: 'QR Codes'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildNFCTab(), _buildQRTab()]),
      ),
    );
  }

  Widget _buildNFCTab() {
    return SafeArea(
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
                child: const Icon(Icons.nfc, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Isuru Pathirathna',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Portfolio NFC Card',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
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
                // Share Portfolio Button (HCE Mode)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isWriting ? _stopSharing : _pushToNFC,
                    icon: _isWriting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.web, size: 24),
                    label: Text(
                      _isWriting
                          ? 'Stop Sharing Portfolio'
                          : 'Share Portfolio via NFC',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Share WhatsApp Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSharingWhatsApp
                        ? _stopSharing
                        : _pushWhatsAppToNFC,
                    icon: _isSharingWhatsApp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.chat, size: 24),
                    label: Text(
                      _isSharingWhatsApp
                          ? 'Stop Sharing WhatsApp'
                          : 'Share WhatsApp via NFC',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Share Contact Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSharingContact
                        ? _stopSharing
                        : _pushContactToNFC,
                    icon: _isSharingContact
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.contact_page, size: 24),
                    label: Text(
                      _isSharingContact
                          ? 'Stop Sharing Contact'
                          : 'Share Contact via NFC',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

              // Information Display Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portfolio URL
                    Text(
                      'Portfolio URL',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _portfolioUrlController,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.link,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // WhatsApp Link
                    Text(
                      'WhatsApp Link',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _whatsappUrlController,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.chat,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save, size: 20),
                        label: const Text('Save Settings'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Made by footer
              Text(
                'Made by Isuru Pathirathna',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Title
              const Text(
                'QR Codes',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan to access instantly',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Portfolio QR Code
              _buildQRCard(
                title: 'Portfolio Website',
                data: _portfolioUrlController.text,
                icon: Icons.web,
              ),
              const SizedBox(height: 24),

              // WhatsApp QR Code
              _buildQRCard(
                title: 'WhatsApp Chat',
                data: _whatsappUrlController.text,
                icon: Icons.chat,
              ),
              const SizedBox(height: 24),

              // Phone QR Code
              _buildQRCard(
                title: 'Phone Number',
                data: 'tel:${_phoneNumberController.text}',
                icon: Icons.phone,
              ),
              const SizedBox(height: 48),

              // Made by footer
              Text(
                'Made by Isuru Pathirathna',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCard({
    required String title,
    required String data,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Theme.of(context).colorScheme.primary,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
