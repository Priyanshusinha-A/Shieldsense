import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatDialog extends StatefulWidget {
  final Map<String, String> cyberTerms;

  const ChatDialog({required this.cyberTerms});

  @override
  _ChatDialogState createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  List<Map<String, dynamic>> _chatMessages = [];
  TextEditingController _chatController = TextEditingController();
  bool _isSearching = false;

  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _chatMessages.add({'sender': 'user', 'message': message});
      _isSearching = true;
    });

    String response = await _generateResponse(message.trim().toLowerCase());
    setState(() {
      _chatMessages.add({'sender': 'bot', 'message': response});
      _isSearching = false;
    });

    _chatController.clear();
  }

  Future<String> _generateResponse(String query) async {
    for (var entry in widget.cyberTerms.entries) {
      if (query.contains(entry.key.toLowerCase())) {
        return '${entry.key.toUpperCase()}: ${entry.value}';
      }
    }
    // Perform Google search for non-matching queries
    return await _performGoogleSearch(query);
  }

  Future<String> _performGoogleSearch(String query) async {
    const String apiKey = 'AIzaSyCWcwTHvFaGj8WYIisrJVF7jK1VTxRtxms';
    const String cx = '1022fffc1074b4398';
    final String url = 'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$query&num=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          final title = item['title'] ?? 'No title';
          final snippet = item['snippet'] ?? 'No description';
          return '$title\n$snippet';
        } else {
          return "Sorry, I couldn't find information on that.";
        }
      } else {
        return "Sorry, I couldn't find information on that.";
      }
    } catch (e) {
      return "Sorry, I couldn't find information on that.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cyber Chatbot'),
      content: Container(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _chatMessages.length + (_isSearching ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _chatMessages.length) {
                    final msg = _chatMessages[index];
                    return ListTile(
                      title: Text(msg['message']),
                      subtitle: Text(msg['sender'] == 'user' ? 'You' : 'Bot'),
                    );
                  } else {
                    return ListTile(
                      title: Text('Searching...'),
                      subtitle: Text('Bot'),
                    );
                  }
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(hintText: 'Ask about cybersecurity...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_chatController.text),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
