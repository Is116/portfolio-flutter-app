import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/nfc_service.dart';

class ReadNFCScreen extends StatefulWidget {
  const ReadNFCScreen({super.key});

  @override
  State<ReadNFCScreen> createState() => _ReadNFCScreenState();
}

class _ReadNFCScreenState extends State<ReadNFCScreen>
    with SingleTickerProviderStateMixin {
  bool _isReading = false;
  Map<String, dynamic>? _readData;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    NFCService.stopSession();
    super.dispose();
  }

  Future<void> _readNFC() async {
    setState(() {
      _isReading = true;
      _readData = null;
    });

    try {
      final url = await NFCService.readNFC();
      
      final result = {
        'success': url != null && url.isNotEmpty,
        'url': url,
        'recordCount': url != null && url.isNotEmpty ? 1 : 0,
        'data': url != null && url.isNotEmpty ? [url] : [],
        'message': url == null || url.isEmpty ? 'No URL found on tag' : null,
      };

      setState(() {
        _isReading = false;
        _readData = result;
      });

      if (result['success'] == true) {
        _showReadDataDialog(result);
      }
    } catch (e) {
      setState(() {
        _isReading = false;
        _readData = {
          'success': false,
          'message': e.toString(),
        };
      });
    }
  }

  void _showReadDataDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Tag Read!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data['url'] != null) ...[
                const Text(
                  'Website:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _launchURL(data['url']),
                  child: Text(
                    data['url'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Records found: ${data['recordCount'] ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (data['data'] != null && (data['data'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                ...((data['data'] as List).map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ))),
              ],
            ],
          ),
        ),
        actions: [
          if (data['url'] != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _launchURL(data['url']);
              },
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open Website'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read NFC Tag'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instruction Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.nfc,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Read NFC Tag',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap "Start Reading" and hold your phone near an NFC tag to read its contents.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reading Status / Results
            Expanded(
              child: _isReading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RotationTransition(
                            turns: _animationController,
                            child: Icon(
                              Icons.nfc,
                              size: 120,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Hold your phone near the NFC tag...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(),
                        ],
                      ),
                    )
                  : _readData != null
                      ? _buildResultCard()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 80,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Ready to scan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (!_isReading) ...[
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _readNFC,
                  icon: const Icon(Icons.nfc, size: 24),
                  label: const Text(
                    'Start Reading',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ] else ...[
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    NFCService.stopSession();
                    setState(() => _isReading = false);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_readData == null) return const SizedBox.shrink();

    final success = _readData!['success'] == true;

    return Card(
      color: success ? const Color(0xFF064E3B) : const Color(0xFF7C2D12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      success ? 'Tag Read Successfully' : 'Read Failed',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (success) ...[
                if (_readData!['url'] != null) ...[
                  const Text(
                    'Website:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _launchURL(_readData!['url']),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _readData!['url'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Icon(Icons.open_in_new, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Records: ${_readData!['recordCount'] ?? 0}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (_readData!['data'] != null &&
                    (_readData!['data'] as List).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Data:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(_readData!['data'] as List).map((text) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      )),
                ],
              ] else ...[
                Text(
                  _readData!['message'] ?? 'Unknown error',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
