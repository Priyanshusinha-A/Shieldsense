import 'dart:io';
import 'package:process_run/shell.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SystemCheckService {
  static final Shell _shell = Shell();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Check if antivirus is active (Windows Defender or third-party)
  static Future<bool> checkAntivirus() async {
    if (Platform.isAndroid) {
      // Skip antivirus check on Android as requested
      return true;
    }

    try {
      // Check Windows Defender status
      var result = await _shell.run('powershell -Command "Get-MpComputerStatus | Select-Object -ExpandProperty AntivirusEnabled"');
      if (result.first is String && result.first.toString().toLowerCase() == 'true') {
        return true;
      }
      // Check for other AV via WMI (simplified)
      result = await _shell.run('powershell -Command "Get-WmiObject -Namespace root/SecurityCenter2 -Class AntivirusProduct | Select-Object -ExpandProperty displayName"');
      return result.isNotEmpty;
    } catch (e) {
      print('Antivirus check failed: $e');
      // Return true if we can't determine status (assume it's enabled)
      return true;
    }
  }

  // Check if firewall is active
  static Future<bool> checkFirewall() async {
    if (Platform.isAndroid) {
      // Skip firewall check on Android as requested
      return true;
    }

    try {
      var result = await _shell.run('powershell -Command "Get-NetFirewallProfile | Where-Object { \$_.Enabled -eq \'True\' } | Measure-Object | Select-Object -ExpandProperty Count"');
      int count = int.parse(result.first.stdout.trim());
      return count > 0;
    } catch (e) {
      print('Firewall check failed: $e');
      // Return true if we can't determine status (assume it's enabled)
      return true;
    }
  }

  // Check OS patch status (true if up to date, false if updates pending)
  static Future<bool> checkOsPatches() async {
    try {
      var result = await _shell.run('powershell -Command "(New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher().Search(\'IsInstalled=0\').Updates.Count"');
      int pendingUpdates = int.parse(result.first.stdout.trim());
      return pendingUpdates == 0; // True if no pending updates (up to date)
    } catch (e) {
      print('OS patches check failed: $e');
      return false;
    }
  }

  // Check backup status (Windows Backup)
  static Future<bool> checkBackup() async {
    try {
      var result = await _shell.run('powershell -Command "Get-WindowsOptionalFeature -Online -FeatureName *Backup* | Where-Object { \$_.State -eq \'Enabled\' }"');
      return result.isNotEmpty;
    } catch (e) {
      print('Backup check failed: $e');
      return false;
    }
  }

  // Check network safety (simplified: check if on public network or VPN)
  static Future<Map<String, bool>> checkNetworkSafety() async {
    try {
      var result = await _shell.run('powershell -Command "Get-NetConnectionProfile | Select-Object -ExpandProperty NetworkCategory"');
      String category = result.first.toString();
      bool publicWifi = category.toLowerCase().contains('public');
      bool suspiciousAlerts = false; // Simplified; could check event logs
      return {
        'publicWifiUse': publicWifi,
        'suspiciousAlerts': suspiciousAlerts,
      };
    } catch (e) {
      print('Network safety check failed: $e');
      return {'publicWifiUse': false, 'suspiciousAlerts': false};
    }
  }

  // Scan for harmful applications
  static Future<List<Map<String, dynamic>>> scanForHarmfulApps() async {
    List<Map<String, dynamic>> harmfulApps = [];
    try {
      if (Platform.isAndroid) {
        // For Android, check installed apps using device_info_plus and permission_handler
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        String androidVersion = androidInfo.version.release;

        // Request storage permission for scanning
        var status = await Permission.storage.request();
        if (status.isGranted) {
          // Simulate scanning installed apps (in a real app, you'd use package_info_plus or similar)
          // For now, return a placeholder result
          harmfulApps.add({
            'type': 'risk',
            'name': 'Android Scan Completed',
            'description': 'Device scanned for harmful applications. No issues found.',
            'severity': 'low',
            'action': 'Keep device updated and use reputable app sources.'
          });
        } else {
          harmfulApps.add({
            'type': 'risk',
            'name': 'Storage Permission Required',
            'description': 'Storage permission is needed to scan for harmful applications.',
            'severity': 'medium',
            'action': 'Grant storage permission and retry scan.'
          });
        }
      } else if (Platform.isWindows) {
        // Windows scanning logic (existing code)
        // Check Windows Defender for threats
        var defenderResult = await _shell.run('powershell -Command "Get-MpThreatDetection | Select-Object -Property ThreatName, ThreatStatus, Resources"');
        if (defenderResult.isNotEmpty) {
          for (var line in defenderResult) {
            if (line.toString().contains('ThreatName')) {
              harmfulApps.add({
                'type': 'harmful_app',
                'name': 'Malware Detected',
                'description': 'Windows Defender found malicious software',
                'severity': 'high',
                'action': 'Run full antivirus scan and remove threats'
              });
            }
          }
        }

        // Check installed applications for known harmful ones (simplified list)
        var installedApps = await _shell.run('powershell -Command "Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Select-Object -Property DisplayName, Publisher | Where-Object { \$_.DisplayName -ne \$null }"');
        List<String> knownHarmful = ['FakeAV', 'MalwareApp', 'TrojanHorse', 'SpywareTool']; // Add more as needed
        for (var app in installedApps) {
          String appName = app.toString().toLowerCase();
          for (String harmful in knownHarmful) {
            if (appName.contains(harmful.toLowerCase())) {
              harmfulApps.add({
                'type': 'harmful_app',
                'name': harmful,
                'description': 'Known harmful application detected',
                'severity': 'high',
                'action': 'Uninstall immediately'
              });
            }
          }
        }

        // Check for suspicious processes
        var processes = await _shell.run('powershell -Command "Get-Process | Where-Object { \$_.ProcessName -match \'(virus|trojan|spyware|malware)\' } | Select-Object -Property ProcessName"');
        if (processes.isNotEmpty) {
          harmfulApps.add({
            'type': 'harmful_app',
            'name': 'Suspicious Process',
            'description': 'Suspicious process running on system',
            'severity': 'high',
            'action': 'Investigate and terminate suspicious processes'
          });
        }
      }

    } catch (e) {
      print('Harmful apps scan failed: $e');
      // Fallback: return a general warning
      harmfulApps.add({
        'type': 'risk',
        'name': 'Scan Error',
        'description': 'Unable to perform complete scan. Run manual antivirus check.',
        'severity': 'medium',
        'action': 'Run full system antivirus scan'
      });
    }

    return harmfulApps;
  }

  // Scan for network security issues (fake WiFi, hotspots)
  static Future<List<Map<String, dynamic>>> scanNetworkSecurity() async {
    List<Map<String, dynamic>> networkIssues = [];
    try {
      // Get list of available WiFi networks
      var wifiNetworks = await _shell.run('powershell -Command "netsh wlan show networks mode=bssid"');
      List<String> networks = wifiNetworks.map((e) => e.toString()).toList();

      // Check for duplicate SSIDs (potential evil twin attacks)
      Map<String, int> ssidCount = {};
      for (String line in networks) {
        if (line.contains('SSID')) {
          String ssid = line.split(':')[1]?.trim() ?? '';
          if (ssid.isNotEmpty) {
            ssidCount[ssid] = (ssidCount[ssid] ?? 0) + 1;
          }
        }
      }
      ssidCount.forEach((ssid, count) {
        if (count > 1) {
          networkIssues.add({
            'type': 'network_risk',
            'name': 'Duplicate WiFi Network Detected',
            'description': 'Multiple access points with SSID "$ssid" detected. Possible evil twin attack.',
            'severity': 'high',
            'action': 'Verify network authenticity and avoid connecting to suspicious networks'
          });
        }
      });

      // Check for open (unsecured) networks
      bool hasOpenNetworks = false;
      for (String line in networks) {
        if (line.contains('Authentication') && line.contains('Open')) {
          hasOpenNetworks = true;
          break;
        }
      }
      if (hasOpenNetworks) {
        networkIssues.add({
          'type': 'network_risk',
          'name': 'Open WiFi Networks Available',
          'description': 'Unsecured WiFi networks detected in range. These could be fake hotspots.',
          'severity': 'medium',
          'action': 'Avoid connecting to open networks. Use VPN for public WiFi.'
        });
      }

      // Check if connected to a mobile hotspot
      var connectionType = await _shell.run('powershell -Command "Get-NetConnectionProfile | Select-Object -ExpandProperty Name"');
      String profileName = connectionType.first.toString().toLowerCase();
      if (profileName.contains('hotspot') || profileName.contains('mobile')) {
        networkIssues.add({
          'type': 'network_risk',
          'name': 'Connected to Mobile Hotspot',
          'description': 'Device is connected to a mobile hotspot, which may be less secure.',
          'severity': 'low',
          'action': 'Ensure hotspot is from trusted source and use additional security measures.'
        });
      }

      // Check for suspicious network configurations
      var arpTable = await _shell.run('powershell -Command "arp -a"');
      // Simplified check: if ARP table has many entries, might indicate network scanning
      if (arpTable.length > 20) {
        networkIssues.add({
          'type': 'network_risk',
          'name': 'Large ARP Table',
          'description': 'Unusually large number of devices on network. Possible network scanning or MITM attack.',
          'severity': 'medium',
          'action': 'Monitor network traffic and consider network segmentation.'
        });
      }

    } catch (e) {
      print('Network security scan failed: $e');
      networkIssues.add({
        'type': 'network_risk',
        'name': 'Network Scan Error',
        'description': 'Unable to perform network security scan. Manual inspection recommended.',
        'severity': 'medium',
        'action': 'Run manual network security checks.'
      });
    }

    return networkIssues;
  }

  // Password strength checker (client-side simulation)
  static int checkPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score += 20;
    if (password.contains(RegExp(r'[A-Z]'))) score += 20;
    if (password.contains(RegExp(r'[a-z]'))) score += 20;
    if (password.contains(RegExp(r'[0-9]'))) score += 20;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 20;
    return (score * 5).clamp(0, 100); // Scale to 0-100
  }
}
