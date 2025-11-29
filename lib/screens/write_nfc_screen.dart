import 'package:flutter/material.dart';
import '../models/portfolio_data.dart';
import '../services/nfc_service.dart';

class WriteNFCScreen extends StatefulWidget {
  final PortfolioData portfolioData;

  const WriteNFCScreen({
    super.key,
    required this.portfolioData,
  });

  @override
  State<WriteNFCScreen> createState() => _WriteNFCScreenState();
}

class _WriteNFCScreenState extends State<WriteNFCScreen>
    with SingleTickerProviderStateMixin {
  bool _isWriting = false;
  String _status = 'Ready to write';
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

  Future<void> _writeToNFC() async {
    setState(() {
      _isWriting = true;
      _status = 'Hold your phone near the NFC tag...';
    });

    final result = await NFCService.writeToNFC(widget.portfolioData);

    setState(() {
      _isWriting = false;
      if (result == 'success') {
        _status = 'Successfully written to NFC tag! ✅';
        _showSuccessDialog();
      } else {
        _status = result;
        _showErrorDialog(result);
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Success!'),
          ],
        ),
        content: const Text(
          'Your portfolio data has been written to the NFC tag successfully!\n\nYou can now share this tag with others.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _writeToNFC(); // Write another tag
            },
            child: const Text('Write Another'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _writeToNFC();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write to NFC Tag'),
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
                      Icons.info_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Tap the "Start Writing" button below\n'
                      '2. Hold your phone close to the NFC tag\n'
                      '3. Keep them together until writing completes\n'
                      '4. You\'ll see a success message when done',
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

            // Animation Area
            if (_isWriting) ...[
              Expanded(
                child: Center(
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
                      Text(
                        _status,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Preview Card
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data to be written:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDataRow(Icons.person, 'Name', widget.portfolioData.name),
                          _buildDataRow(Icons.work, 'Title', widget.portfolioData.title),
                          _buildDataRow(Icons.email, 'Email', widget.portfolioData.email),
                          _buildDataRow(Icons.phone, 'Phone', widget.portfolioData.phone),
                          _buildDataRow(Icons.language, 'Website', widget.portfolioData.website),
                          if (widget.portfolioData.linkedin.isNotEmpty)
                            _buildDataRow(Icons.work_outline, 'LinkedIn', widget.portfolioData.linkedin),
                          if (widget.portfolioData.github.isNotEmpty)
                            _buildDataRow(Icons.code, 'GitHub', widget.portfolioData.github),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            if (!_isWriting) ...[
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _writeToNFC,
                  icon: const Icon(Icons.nfc, size: 24),
                  label: const Text(
                    'Start Writing',
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
                child: const Text('Cancel'),
              ),
            ] else ...[
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    NFCService.stopSession();
                    Navigator.pop(context);
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

  Widget _buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
