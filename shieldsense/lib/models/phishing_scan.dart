class PhishingScan {
  final String id;
  final String content;
  final String riskLevel; // 'Safe', 'Suspicious', 'Dangerous'
  final List<String> reasons;
  final DateTime timestamp;

  PhishingScan({
    required this.id,
    required this.content,
    required this.riskLevel,
    required this.reasons,
    required this.timestamp,
  });

  factory PhishingScan.fromJson(Map<String, dynamic> json) {
    return PhishingScan(
      id: json['id'],
      content: json['content'],
      riskLevel: json['riskLevel'],
      reasons: List<String>.from(json['reasons']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'riskLevel': riskLevel,
      'reasons': reasons,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
