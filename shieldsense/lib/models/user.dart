class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String employeeId;
  final String password; // Note: In production, never store plain passwords
  final int cyberHealthScore;
  final List<String> badges;
  final int phishingDetections;
  final bool antivirusActive;
  final bool firewallActive;
  final int passwordStrength;
  final DateTime? lastPasswordChange;
  final bool osPatchStatus;
  final bool backupStatus;
  final int cyberAwarenessScore;
  final Map<String, bool> networkSafety;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.employeeId,
    required this.password,
    required this.cyberHealthScore,
    required this.badges,
    required this.phishingDetections,
    this.antivirusActive = false,
    this.firewallActive = false,
    this.passwordStrength = 50,
    this.lastPasswordChange,
    this.osPatchStatus = false,
    this.backupStatus = false,
    this.cyberAwarenessScore = 0,
    Map<String, bool>? networkSafety,
  }) : networkSafety = networkSafety ?? {'publicWifiUse': false, 'suspiciousAlerts': false};

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      employeeId: json['employeeId'] ?? '',
      password: json['password'] ?? '',
      cyberHealthScore: json['cyberHealthScore'],
      badges: List<String>.from(json['badges']),
      phishingDetections: json['phishingDetections'],
      antivirusActive: json['antivirusActive'] ?? false,
      firewallActive: json['firewallActive'] ?? false,
      passwordStrength: json['passwordStrength'] ?? 50,
      lastPasswordChange: json['lastPasswordChange'] != null ? DateTime.parse(json['lastPasswordChange']) : null,
      osPatchStatus: json['osPatchStatus'] ?? false,
      backupStatus: json['backupStatus'] ?? false,
      cyberAwarenessScore: json['cyberAwarenessScore'] ?? 0,
      networkSafety: Map<String, bool>.from(json['networkSafety'] ?? {'publicWifiUse': false, 'suspiciousAlerts': false}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'employeeId': employeeId,
      'password': password,
      'cyberHealthScore': cyberHealthScore,
      'badges': badges,
      'phishingDetections': phishingDetections,
      'antivirusActive': antivirusActive,
      'firewallActive': firewallActive,
      'passwordStrength': passwordStrength,
      'lastPasswordChange': lastPasswordChange?.toIso8601String(),
      'osPatchStatus': osPatchStatus,
      'backupStatus': backupStatus,
      'cyberAwarenessScore': cyberAwarenessScore,
      'networkSafety': networkSafety,
    };
  }
}
