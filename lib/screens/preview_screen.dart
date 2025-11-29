import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../models/portfolio_data.dart';

class PreviewScreen extends StatelessWidget {
  final PortfolioData portfolioData;

  const PreviewScreen({
    super.key,
    required this.portfolioData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Card Data'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareData(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Code Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan to visit portfolio',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: portfolioData.website,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // vCard Preview
            _buildSection(
              title: 'vCard Format',
              content: portfolioData.toVCard(),
              icon: Icons.contact_page,
            ),
            const SizedBox(height: 16),

            // Plain Text Preview
            _buildSection(
              title: 'Plain Text Format',
              content: portfolioData.toPlainText(),
              icon: Icons.text_fields,
            ),
            const SizedBox(height: 24),

            // Share Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _shareData,
                icon: const Icon(Icons.share),
                label: const Text(
                  'Share Contact Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF0EA5E9),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF334155),
                ),
              ),
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareData() {
    Share.share(
      portfolioData.toPlainText(),
      subject: '${portfolioData.name} - Contact Information',
    );
  }
}
