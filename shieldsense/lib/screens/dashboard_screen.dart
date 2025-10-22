import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../providers/user_provider.dart';
import '../providers/video_provider.dart';
import 'phishing_scanner_screen.dart';
import 'cyber_coach_screen.dart';
import 'email_input_screen.dart';
import 'system_info_screen.dart';
import 'system_scan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _antivirusLoading = true;
  bool _firewallLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatuses();
  }

  Future<void> _checkStatuses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.checkAntivirusStatus();
    if (mounted) setState(() => _antivirusLoading = false);
    await userProvider.checkFirewallStatus();
    if (mounted) setState(() => _firewallLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
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
                          Image.asset(
                            'assets/images/logo.png',
                            height: 40,
                            width: 40,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ShieldSense',
                            style:
                                Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 5.0,
                                          color: Color.fromRGBO(0, 0, 0, 0.5),
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () async {
                              final userProvider =
                                  Provider.of<UserProvider>(context, listen: false);
                              await userProvider.logout();
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              }
                            },
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
                      child: ListView(
                        children: [
                          Text(
                            'Welcome, ${user?.name ?? 'User'}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0),

                          const SizedBox(height: 20),

                          // Cyber Health Score
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            color: Colors.white.withOpacity(0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Your Cyber Health Score',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value:
                                          (user?.cyberHealthScore ?? 0) / 100,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        (user?.cyberHealthScore ?? 0) >= 70
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${user?.cyberHealthScore ?? 0}/100',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

                          const SizedBox(height: 20),

                          // Quick Stats
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  color: Colors.white.withOpacity(0.1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.3)),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.security,
                                          color: Colors.blue),
                                      title: const Text(
                                        'Phishing Detections',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        '${user?.phishingDetections ?? 0}',
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _showBadgesDialog(context, user?.badges ?? []);
                                  },
                                  child: Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    color: Colors.white.withOpacity(0.1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3)),
                                      ),
                                      child: ListTile(
                                        leading: const Icon(Icons.badge,
                                            color: Colors.green),
                                        title: const Text('Badges Earned',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        subtitle: Text(
                                          '${user?.badges.length ?? 0}',
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // System Assessments
                          // Removed Antivirus and Firewall checks for Android as requested
                          _buildPasswordStrengthCard(
                              user?.passwordStrength ?? 50),

                          _buildAssessmentCard('Backup Status',
                              user?.backupStatus ?? false, Icons.backup),
                          _buildAwarenessCard(user?.cyberAwarenessScore ?? 0),
                          _buildNetworkSafetyCard(
                              user?.networkSafety ??
                                  {'publicWifiUse': false, 'suspiciousAlerts': false}),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SystemScanScreen()),
                              );
                            },
                            child: _buildAssessmentCard(
                                'System Scan',
                                false,
                                Icons.search),
                          ),

                          const SizedBox(height: 20),

                          // Quick Actions
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PhishingScannerScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Scan Email'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CyberCoachScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.chat),
                                  label: const Text('Cyber Coach'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const EmailInputScreen()),
                              );
                            },
                            icon: const Icon(Icons.storage),
                            label: const Text('ShieldSense Drive'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
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

  Widget _buildAssessmentCard(String title, bool status, IconData icon) {
    bool isLoading = (title == 'Antivirus' && _antivirusLoading) || (title == 'Firewall' && _firewallLoading);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        leading: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, color: status ? Colors.green : Colors.red),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                status ? Icons.check_circle : Icons.cancel,
                color: status ? Colors.green : Colors.red,
              ),
      ),
    );
  }

  Widget _buildPasswordStrengthCard(int strength) {
    Color color =
        strength >= 80 ? Colors.green : strength >= 60 ? Colors.orange : Colors.red;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Password Strength',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text('$strength%',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: strength / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwarenessCard(int score) {
    Color color =
        score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cyber Awareness',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text('$score%',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkSafetyCard(Map<String, bool> safety) {
    bool publicWifiSafe = !(safety['publicWifiUse'] ?? false);
    bool suspiciousAlerts = !(safety['suspiciousAlerts'] ?? false);
    bool overallSafe = publicWifiSafe && suspiciousAlerts;
    Color color = overallSafe ? Colors.green : Colors.red;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Network Safety',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Icon(
                  overallSafe ? Icons.check_circle : Icons.cancel,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(publicWifiSafe ? Icons.wifi : Icons.wifi_off,
                          color: publicWifiSafe ? Colors.green : Colors.red),
                      const SizedBox(height: 4),
                      Text('Public WiFi',
                          style: TextStyle(
                              fontSize: 12,
                              color: publicWifiSafe ? Colors.green : Colors.red)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                          suspiciousAlerts
                              ? Icons.notifications_active
                              : Icons.warning,
                          color:
                              suspiciousAlerts ? Colors.green : Colors.red),
                      const SizedBox(height: 4),
                      Text('Alerts',
                          style: TextStyle(
                              fontSize: 12,
                              color: suspiciousAlerts ? Colors.green : Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgesDialog(BuildContext context, List<String> badges) {
    final List<Map<String, dynamic>> allBadges = [
      {'name': 'Quiz Novice', 'description': 'Answer 5 questions correctly', 'unlocked': false, 'tier': 'bronze'},
      {'name': 'Quiz Apprentice', 'description': 'Answer 10 questions correctly', 'unlocked': false, 'tier': 'silver'},
      {'name': 'Quiz Journeyman', 'description': 'Answer 20 questions correctly', 'unlocked': false, 'tier': 'gold'},
      {'name': 'Quiz Expert', 'description': 'Answer 50 questions correctly', 'unlocked': false, 'tier': 'platinum'},
      {'name': 'Quiz Master', 'description': 'Answer 100 questions correctly', 'unlocked': false, 'tier': 'diamond'},
      {'name': 'Streak Beginner', 'description': 'Get 3 consecutive correct answers', 'unlocked': false, 'tier': 'bronze'},
      {'name': 'Streak Master', 'description': 'Get 5 consecutive correct answers', 'unlocked': false, 'tier': 'silver'},
      {'name': 'Streak Champion', 'description': 'Get 10 consecutive correct answers', 'unlocked': false, 'tier': 'gold'},
      {'name': 'Streak Legend', 'description': 'Get 15 consecutive correct answers', 'unlocked': false, 'tier': 'platinum'},
      {'name': 'Streak God', 'description': 'Get 20 consecutive correct answers', 'unlocked': false, 'tier': 'diamond'},
      {'name': 'Awareness Initiate', 'description': 'Reach 60% awareness score', 'unlocked': false, 'tier': 'bronze'},
      {'name': 'Awareness Adept', 'description': 'Reach 70% awareness score', 'unlocked': false, 'tier': 'silver'},
      {'name': 'Awareness Expert', 'description': 'Reach 80% awareness score', 'unlocked': false, 'tier': 'gold'},
      {'name': 'Awareness Master', 'description': 'Reach 90% awareness score', 'unlocked': false, 'tier': 'platinum'},
      {'name': 'Awareness Guru', 'description': 'Reach 95% awareness score', 'unlocked': false, 'tier': 'diamond'},
      {'name': 'Cyber Guardian', 'description': 'Complete 10 quiz cycles', 'unlocked': false, 'tier': 'bronze'},
      {'name': 'Cyber Sentinel', 'description': 'Complete 25 quiz cycles', 'unlocked': false, 'tier': 'silver'},
      {'name': 'Cyber Warden', 'description': 'Complete 50 quiz cycles', 'unlocked': false, 'tier': 'gold'},
      {'name': 'Cyber Paladin', 'description': 'Complete 100 quiz cycles', 'unlocked': false, 'tier': 'platinum'},
      {'name': 'Cyber Archon', 'description': 'Complete 200 quiz cycles', 'unlocked': false, 'tier': 'diamond'},
    ];

    // Mark unlocked badges
    for (var badge in allBadges) {
      if (badges.contains(badge['name'])) {
        badge['unlocked'] = true;
      }
    }

    final Map<String, Color> tierColors = {
      'bronze': Colors.orange,
      'silver': Colors.grey,
      'gold': Colors.yellow,
      'platinum': Colors.lightBlue,
      'diamond': Colors.purple,
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.black.withOpacity(0.9),
          title: const Text(
            'Your Badges',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badges.isEmpty)
                    const Text(
                      'No badges earned yet. Start the Cyber Coach quiz to earn badges!',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 6.0,
                        mainAxisSpacing: 6.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: badges.length,
                      itemBuilder: (context, index) {
                        final badgeName = badges[index];
                        final badge = allBadges.firstWhere(
                          (b) => b['name'] == badgeName,
                          orElse: () => {'tier': 'bronze'},
                        );
                        final Color tierColor = tierColors[badge['tier']] ?? Colors.grey;
                        final IconData badgeIcon = _getBadgeIcon(badgeName);

                        return Container(
                          decoration: BoxDecoration(
                            color: tierColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: tierColor.withOpacity(0.5), width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  badgeIcon,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  badgeName,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  IconData _getBadgeIcon(String badgeName) {
    if (badgeName.contains('Quiz')) return Icons.quiz;
    if (badgeName.contains('Streak')) return Icons.flash_on;
    if (badgeName.contains('Awareness')) return Icons.lightbulb;
    if (badgeName.contains('Cyber')) return Icons.security;
    return Icons.star;
  }
}
