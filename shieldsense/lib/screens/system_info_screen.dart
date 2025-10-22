import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SystemInfoScreen extends StatefulWidget {
  const SystemInfoScreen({super.key});

  @override
  State<SystemInfoScreen> createState() => _SystemInfoScreenState();
}

class _SystemInfoScreenState extends State<SystemInfoScreen> {
  Map<String, dynamic> _systemInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> info = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        info = {
          'Device Model': androidInfo.model,
          'Android Version': androidInfo.version.release,
          'API Level': androidInfo.version.sdkInt.toString(),
          'Manufacturer': androidInfo.manufacturer,
          'Brand': androidInfo.brand,
          'Security Patch': androidInfo.version.securityPatch,
          'Supported ABIs': androidInfo.supportedAbis.join(', '),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info = {
          'Device Model': iosInfo.model,
          'System Name': iosInfo.systemName,
          'System Version': iosInfo.systemVersion,
          'Device Name': iosInfo.name,
          'Localized Model': iosInfo.localizedModel,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        info = {
          'Computer Name': windowsInfo.computerName,
          'Number of Cores': windowsInfo.numberOfCores.toString(),
          'System Memory': '${(windowsInfo.systemMemoryInMegabytes / 1024).round()} GB',
          'Edition': windowsInfo.editionId,
          'Build Number': windowsInfo.buildNumber.toString(),
          'Platform ID': windowsInfo.platformId.toString(),
        };
      } else if (Platform.isMacOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        info = {
          'Computer Name': macOsInfo.computerName,
          'Host Name': macOsInfo.hostName,
          'Arch': macOsInfo.arch,
          'Model': macOsInfo.model,
          'Kernel Version': macOsInfo.kernelVersion,
          'OS Release': macOsInfo.osRelease,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        info = {
          'Name': linuxInfo.name,
          'Version': linuxInfo.version,
          'ID': linuxInfo.id,
          'Pretty Name': linuxInfo.prettyName,
          'Build ID': linuxInfo.buildId,
          'Variant': linuxInfo.variant,
        };
      }

      // Get IP addresses
      final ipv4 = await _getIPAddress(InternetAddressType.IPv4);
      final ipv6 = await _getIPAddress(InternetAddressType.IPv6);

      info['IPv4 Address'] = ipv4 ?? 'Not available';
      info['IPv6 Address'] = ipv6 ?? 'Not available';

      // Get security health (simplified)
      info['Security Health'] = await _getSecurityHealth();

      setState(() {
        _systemInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _systemInfo = {'Error': 'Failed to load system information: $e'};
        _isLoading = false;
      });
    }
  }

  Future<String?> _getIPAddress(InternetAddressType type) async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == type && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting IP address: $e');
    }
    return null;
  }

  Future<String> _getSecurityHealth() async {
    // Simplified security health check
    List<String> issues = [];

    // Check if running as admin/root (basic check)
    if (Platform.isWindows) {
      try {
        final result = await Process.run('net', ['session'], runInShell: true);
        if (result.exitCode != 0) {
          issues.add('Not running with administrator privileges');
        }
      } catch (e) {
        issues.add('Unable to verify administrator privileges');
      }
    }

    // Check for common security issues
    if (_systemInfo['Security Patch'] != null) {
      final patchDate = DateTime.tryParse(_systemInfo['Security Patch']);
      if (patchDate != null && patchDate.isBefore(DateTime.now().subtract(const Duration(days: 90)))) {
        issues.add('Security patch is outdated');
      }
    }

    if (issues.isEmpty) {
      return 'Good - No immediate security issues detected';
    } else {
      return 'Needs Attention: ${issues.join(', ')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Information'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    'Device & System Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._systemInfo.entries.map((entry) => Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 6,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Recommendations',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Keep your operating system and applications updated\n'
                            '• Use strong, unique passwords\n'
                            '• Enable firewall and antivirus protection\n'
                            '• Be cautious with email attachments and links\n'
                            '• Use VPN on public networks\n'
                            '• Regularly backup your data',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
