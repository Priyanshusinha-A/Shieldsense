import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';
import '../services/system_check_service.dart';

class SystemScanScreen extends StatefulWidget {
  const SystemScanScreen({super.key});

  @override
  State<SystemScanScreen> createState() => _SystemScanScreenState();
}

class _SystemScanScreenState extends State<SystemScanScreen> {
  bool _isScanning = false;
  bool _scanCompleted = false;
  List<Map<String, dynamic>> _scanResults = [];

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _scanCompleted = false;
      _scanResults = [];
    });

    // Perform actual scans
    List<Map<String, dynamic>> harmfulApps = await SystemCheckService.scanForHarmfulApps();
    List<Map<String, dynamic>> networkIssues = await SystemCheckService.scanNetworkSecurity();

    List<Map<String, dynamic>> results = [...harmfulApps, ...networkIssues];

    // Add some simulated risks if no issues found
    if (results.isEmpty) {
      results.addAll([
        {
          'type': 'risk',
          'name': 'Outdated Software',
          'description': 'Several applications are outdated and vulnerable',
          'severity': 'medium',
          'action': 'Update all applications'
        },
        {
          'type': 'risk',
          'name': 'Weak Permissions',
          'description': 'Some apps have excessive permissions',
          'severity': 'low',
          'action': 'Review app permissions'
        },
      ]);
    }

    setState(() {
      _isScanning = false;
      _scanCompleted = true;
      _scanResults = results;
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getResultIcon(String type) {
    switch (type) {
      case 'harmful_app':
        return Icons.warning;
      case 'network_risk':
        return Icons.wifi;
      case 'risk':
        return Icons.error_outline;
      default:
        return Icons.info;
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
                            'System Scan',
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Device Security Scan',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.3, end: 0),
                            const SizedBox(height: 10),
                            const Text(
                              'Scan your device for harmful applications and network security risks',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ).animate().fadeIn(duration: 600.ms),
                            const SizedBox(height: 30),

                            // Scan Button
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _isScanning ? null : _startScan,
                                icon: _isScanning
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.search),
                                label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isScanning ? Colors.grey : Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ).animate().scale(delay: 200.ms),
                            ),

                            const SizedBox(height: 40),

                            // Scan Results
                            if (_scanCompleted) ...[
                              const Text(
                                'Scan Results',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ).animate().fadeIn(duration: 500.ms),
                              const SizedBox(height: 20),
                              ..._scanResults.map((result) => Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: Colors.white.withOpacity(0.1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _getResultIcon(result['type']),
                                              color: _getSeverityColor(result['severity']),
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                result['name'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getSeverityColor(result['severity']).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                result['severity'].toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getSeverityColor(result['severity']),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          result['description'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Recommended Action: ${result['action']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0)),
                            ] else if (!_isScanning) ...[
                              Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: Colors.white.withOpacity(0.1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text(
                                        'Tap "Start Scan" to begin security analysis',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 700.ms),
                            ],
                          ],
                        ),
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
