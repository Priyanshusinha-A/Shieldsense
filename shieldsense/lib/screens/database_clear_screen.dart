import 'package:flutter/material.dart';
import '../services/database_service.dart';

class DatabaseClearScreen extends StatefulWidget {
  const DatabaseClearScreen({super.key});

  @override
  _DatabaseClearScreenState createState() => _DatabaseClearScreenState();
}

class _DatabaseClearScreenState extends State<DatabaseClearScreen> {
  bool _isClearing = false;
  String _statusMessage = '';

  Future<void> _clearDatabase() async {
    setState(() {
      _isClearing = true;
      _statusMessage = 'Clearing database...';
    });

    try {
      await DatabaseService.clearAllUsers();
      setState(() {
        _statusMessage = 'Database cleared successfully! All users have been deleted.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error clearing database: $e';
      });
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Management'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Clear All User Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This action will permanently delete all user accounts from the database. This cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isClearing ? null : _clearDatabase,
              icon: _isClearing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.delete_forever),
              label: Text(_isClearing ? 'Clearing...' : 'Clear All Users'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('Error') ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.contains('Error') ? Colors.red : Colors.green,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _statusMessage.contains('Error') ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to App'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
