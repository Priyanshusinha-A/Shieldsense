import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/phishing_scan.dart';

class PhishingService {
  static const String _baseUrl = 'https://phishtank.org/api/info.php';

  Future<PhishingScan> scanContent(String content) async {
    // For demo purposes, simulate scanning
    // In real app, integrate with PhishTank API or OpenPhish
    await Future.delayed(const Duration(seconds: 2));

    // Enhanced heuristic-based detection
    List<String> reasons = [];
    String riskLevel = 'Safe';
    int riskScore = 0;

    // Convert to lowercase for case-insensitive matching
    String lowerContent = content.toLowerCase();

    // Check for suspicious URLs
    RegExp urlRegex = RegExp(r'https?://[^\s]+');
    Iterable<RegExpMatch> urlMatches = urlRegex.allMatches(content);

    for (var match in urlMatches) {
      String url = match.group(0)!;
      String lowerUrl = url.toLowerCase();

      // Check for known phishing domains or patterns
      if (lowerUrl.contains('paypa1.com') ||
          lowerUrl.contains('bankofamerica-support.com') ||
          lowerUrl.contains('amazon-security-alert') ||
          lowerUrl.contains('netflix-account-update') ||
          lowerUrl.contains('microsoft-support-help') ||
          lowerUrl.contains('free-iphone-giveaway') ||
          lowerUrl.contains('secure-chase.com') ||
          lowerUrl.contains('login-microsoft-support') ||
          lowerUrl.contains('best-antivirus-download')) {
        riskScore += 50;
        reasons.add('Contains known suspicious URL: $url');
      }

      // Check for typo-squatting (common phishing technique)
      if (lowerUrl.contains('paypa') && !lowerUrl.contains('paypal.com')) {
        riskScore += 30;
        reasons.add('Possible typo-squatting in URL: $url');
      }

      // Check for suspicious TLDs or subdomains
      if (lowerUrl.contains('.com') && (lowerUrl.contains('-support') || lowerUrl.contains('-security') || lowerUrl.contains('-login'))) {
        riskScore += 20;
        reasons.add('Suspicious URL structure: $url');
      }
    }

    // Check for urgent language
    if (lowerContent.contains('urgent') || lowerContent.contains('immediate') || lowerContent.contains('act now') || lowerContent.contains('limited time')) {
      riskScore += 15;
      reasons.add('Contains urgent language');
    }

    // Check for action verbs
    if (lowerContent.contains('click here') || lowerContent.contains('click below') || lowerContent.contains('download now') || lowerContent.contains('verify now')) {
      riskScore += 15;
      reasons.add('Contains suspicious action prompts');
    }

    // Check for sensitive information requests
    if ((lowerContent.contains('password') || lowerContent.contains('login') || lowerContent.contains('account')) &&
        (lowerContent.contains('bank') || lowerContent.contains('credit') || lowerContent.contains('card'))) {
      riskScore += 40;
      reasons.add('Requests sensitive financial information');
    }

    // Check for tech support scams
    if (lowerContent.contains('microsoft') && (lowerContent.contains('support') || lowerContent.contains('technical'))) {
      riskScore += 25;
      reasons.add('Potential tech support scam');
    }

    // Check for prize/giveaway scams
    if (lowerContent.contains('won') || lowerContent.contains('prize') || lowerContent.contains('giveaway') || lowerContent.contains('free') && lowerContent.contains('iphone')) {
      riskScore += 20;
      reasons.add('Potential prize/giveaway scam');
    }

    // Determine risk level based on score
    if (riskScore >= 50) {
      riskLevel = 'Dangerous';
    } else if (riskScore >= 20) {
      riskLevel = 'Suspicious';
    } else {
      riskLevel = 'Safe';
    }

    return PhishingScan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      riskLevel: riskLevel,
      reasons: reasons,
      timestamp: DateTime.now(),
    );
  }

  // Placeholder for real API integration
  Future<List<String>> getPhishingUrls() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Parse PhishTank data
        return [];
      }
    } catch (e) {
      print('Error fetching phishing data: $e');
    }
    return [];
  }
}
