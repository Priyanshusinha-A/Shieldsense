import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../services/phishing_service.dart';
import '../models/phishing_scan.dart';
import '../providers/user_provider.dart';
import '../providers/video_provider.dart';

class PhishingScannerScreen extends StatefulWidget {
  const PhishingScannerScreen({super.key});

  @override
  _PhishingScannerScreenState createState() => _PhishingScannerScreenState();
}

class _PhishingScannerScreenState extends State<PhishingScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isScanning = false;
  PhishingScan? _scanResult;

  Future<void> _scanContent() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isScanning = true;
      _scanResult = null;
    });

    final service = PhishingService();
    final result = await service.scanContent(_controller.text);

    setState(() {
      _scanResult = result;
      _isScanning = false;
    });

    // Update user stats if suspicious/dangerous
    if (result.riskLevel != 'Safe') {
      Provider.of<UserProvider>(context, listen: false).incrementDetections();
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Safe':
        return Colors.green;
      case 'Suspicious':
        return Colors.orange;
      case 'Dangerous':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background video
          videoProvider.isVideoInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: videoProvider.controller.value.size.width,
                      height: videoProvider.controller.value.size.height,
                      child: VideoPlayer(videoProvider.controller),
                    ),
                  ),
                )
              : Container(color: Colors.black),

          // Overlay gradient and content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.only(
                      top: 50, left: 16, right: 16, bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Phishing Scanner',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Body content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paste suspicious email or link here:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.3, end: 0),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _controller,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'Enter email content or URL...',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                            ),
                          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isScanning ? null : _scanContent,
                              icon: _isScanning ? const SizedBox.shrink() : const Icon(Icons.search),
                              label: _isScanning
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Scan for Phishing'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: Colors.blue.withOpacity(0.3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ).animate().fadeIn(duration: 700.ms).scale(delay: 100.ms),
                          const SizedBox(height: 20),
                          if (_scanResult != null) ...[
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: Colors.white.withOpacity(0.1),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Risk Level: ',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          Text(
                                            _scanResult!.riskLevel,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _getRiskColor(_scanResult!.riskLevel),
                                            ),
                                          ).animate().shake(duration: 500.ms),
                                        ],
                                      ).animate().fadeIn(duration: 800.ms),
                                      const SizedBox(height: 10),
                                      if (_scanResult!.reasons.isNotEmpty) ...[
                                        const Text(
                                          'Reasons:',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ).animate().fadeIn(duration: 900.ms),
                                        ..._scanResult!.reasons.map((reason) => Text('• $reason', style: const TextStyle(color: Colors.white)).animate().fadeIn(duration: 1000.ms, delay: 100.ms)),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
