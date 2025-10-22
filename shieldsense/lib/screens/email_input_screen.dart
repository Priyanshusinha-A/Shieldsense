import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'backup_screen.dart';

class EmailInputScreen extends StatefulWidget {
  const EmailInputScreen({super.key});

  @override
  State<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends State<EmailInputScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically proceed to backup screen since no OAuth verification needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _proceedToBackup();
    });
  }

  void _proceedToBackup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BackupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Setting up ShieldSense Drive Storage...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
