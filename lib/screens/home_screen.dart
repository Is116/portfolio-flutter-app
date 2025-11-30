import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/nfc_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isNFCAvailable = false;
  bool _isWriting = false;
  bool _isSharingWhatsApp = false;
  bool _isSharingContact = false;
  bool _isSharingVCard = false;
  String? _message;

  late AnimationController _nfcAnimationController;
  late Animation<double> _nfcPulseAnimation;

  // Text editing controllers for editable fields
  late TextEditingController _portfolioUrlController;
  late TextEditingController _whatsappUrlController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _portfolioUrlController = TextEditingController();
    _whatsappUrlController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    // NFC animation setup
    _nfcAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _nfcPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _nfcAnimationController, curve: Curves.easeOut),
    );

    _loadData();
    _checkNFC();
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadData();
    _nameController.text = data['name'] ?? 'Isuru Pathirathna';
    _emailController.text = data['email'] ?? 'isuru2002@gmail.com';
    _phoneNumberController.text = data['phone'] ?? '+358 41 367 1742';
    _portfolioUrlController.text = data['portfolio'] ?? 'https://isuru-portfolio-ten.vercel.app/';
    _whatsappUrlController.text = data['whatsapp'] ?? 'https://wa.me/358413671742';
    setState(() {});
  }

  @override
  void dispose() {
    _portfolioUrlController.dispose();
    _whatsappUrlController.dispose();
    _phoneNumberController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _nfcAnimationController.dispose();
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
      _isSharingVCard = false;
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
      _isSharingVCard = false;
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
      _isSharingVCard = false;
      _message =
          'Ready to share contact! Have someone tap their phone to the back.';
    });

    try {
      // Share phone number as a simple vCard for NFC compatibility
      // Full vCard is more reliable via NFC than tel: URI
      final phoneNumber = _phoneNumberController.text.replaceAll(' ', '');
      final contactVCard =
          '''BEGIN:VCARD
VERSION:3.0
FN:${_nameController.text}
TEL:$phoneNumber
END:VCARD''';
      await NFCService.pushURL(contactVCard);

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

  Future<void> _pushVCardToNFC() async {
    setState(() {
      _isSharingVCard = true;
      _isWriting = false;
      _isSharingWhatsApp = false;
      _isSharingContact = false;
      _message =
          'Ready to share full contact! Have someone tap their phone to the back.';
    });

    try {
      // Create vCard format
      final phoneNumber = _phoneNumberController.text.replaceAll(' ', '');
      final vCard =
          '''BEGIN:VCARD
VERSION:3.0
FN:${_nameController.text}
TEL:$phoneNumber
EMAIL:${_emailController.text}
URL:${_portfolioUrlController.text}
END:VCARD''';

      await NFCService.pushURL(vCard);

      await Future.delayed(const Duration(seconds: 60));

      setState(() {
        _isSharingVCard = false;
        _message = 'vCard sharing ended.';
      });
    } catch (e) {
      setState(() {
        _isSharingVCard = false;
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  void _stopSharing() async {
    if (_isWriting ||
        _isSharingWhatsApp ||
        _isSharingContact ||
        _isSharingVCard) {
      await NFCService.stopHCE();
      setState(() {
        _isWriting = false;
        _isSharingWhatsApp = false;
        _isSharingContact = false;
        _isSharingVCard = false;
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

  Future<void> _saveSettings() async {
    final data = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneNumberController.text,
      'portfolio': _portfolioUrlController.text,
      'whatsapp': _whatsappUrlController.text,
    };
    
    final success = await StorageService.saveData(data);
    
    if (mounted) {
      setState(() {}); // Refresh UI with updated values
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Settings saved successfully!' : 'Failed to save settings'),
          backgroundColor: success ? Theme.of(context).colorScheme.primary : Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildNFCAnimation() {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: _nfcPulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer expanding ring
              if (_nfcPulseAnimation.value > 0.2)
                Container(
                  width: 24 * _nfcPulseAnimation.value,
                  height: 24 * _nfcPulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        (1 - _nfcPulseAnimation.value) * 0.8,
                      ),
                      width: 2,
                    ),
                  ),
                ),
              // Middle expanding ring
              if (_nfcPulseAnimation.value > 0.1)
                Container(
                  width: 20 * (_nfcPulseAnimation.value * 0.7),
                  height: 20 * (_nfcPulseAnimation.value * 0.7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        (1 - _nfcPulseAnimation.value * 0.7) * 0.6,
                      ),
                      width: 2,
                    ),
                  ),
                ),
              // Center NFC icon
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.nfc,
                  size: 8,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          );
        },
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
      length: 3,
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
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildNFCTab(), _buildQRTab(), _buildSettingsTab()]),
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
              Text(
                _nameController.text.isNotEmpty ? _nameController.text : 'Your Name',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                        ? _buildNFCAnimation()
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
                        ? _buildNFCAnimation()
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
                        ? _buildNFCAnimation()
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
                const SizedBox(height: 12),

                // Share vCard Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSharingVCard ? _stopSharing : _pushVCardToNFC,
                    icon: _isSharingVCard
                        ? _buildNFCAnimation()
                        : const Icon(Icons.contact_mail, size: 24),
                    label: Text(
                      _isSharingVCard
                          ? 'Stop Sharing vCard'
                          : 'Share Full Contact (vCard)',
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

              const SizedBox(height: 32),

              // Made by footer
              Text(
                'Made by ${_nameController.text}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // Header
              const Text(
                'Settings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Edit your information for NFC and QR sharing',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              const SizedBox(height: 32),

              // Settings Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _buildSettingField(
                      label: 'Name',
                      controller: _nameController,
                      icon: Icons.person,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _buildSettingField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number
                    _buildSettingField(
                      label: 'Phone Number',
                      controller: _phoneNumberController,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      hint: '+358 41 367 1742',
                    ),
                    const SizedBox(height: 20),

                    // Portfolio URL
                    _buildSettingField(
                      label: 'Portfolio URL',
                      controller: _portfolioUrlController,
                      icon: Icons.web,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 20),

                    // WhatsApp URL
                    _buildSettingField(
                      label: 'WhatsApp URL',
                      controller: _whatsappUrlController,
                      icon: Icons.chat,
                      keyboardType: TextInputType.url,
                      hint: 'https://wa.me/358413671742',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text(
                    'Save Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Changes will be applied to both NFC and QR code sharing',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
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
                data: 'tel:${_phoneNumberController.text.replaceAll(' ', '')}',
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),

              // vCard QR Code
              _buildQRCard(
                title: 'Full Contact (vCard)',
                data:
                    '''BEGIN:VCARD
VERSION:3.0
FN:${_nameController.text}
TEL:${_phoneNumberController.text.replaceAll(' ', '')}
EMAIL:${_emailController.text}
URL:${_portfolioUrlController.text}
END:VCARD''',
                icon: Icons.contact_mail,
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
