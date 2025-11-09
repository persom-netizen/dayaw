// frontend/lib/pages/ai.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AIPage extends StatefulWidget {
  final String username;
  const AIPage({super.key, required this.username});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  List<dynamic> _chatSessions = [];
  int? _currentSessionId;
  List<dynamic> _messages = [];
  bool _isLoading = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await ApiService.getChatSessions(widget.username);
      setState(() => _chatSessions = sessions);

      if (sessions.isNotEmpty) {
        await _selectSession(sessions[0]['id']);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading sessions: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewSession() async {
    try {
      final result = await ApiService.createChatSession(widget.username);
      if (result['success']) {
        await _loadSessions();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating session: $e')));
    }
  }

  Future<void> _selectSession(int sessionId) async {
    setState(() {
      _currentSessionId = sessionId;
      _isLoading = true;
    });
    try {
      final messages = await ApiService.getChatMessages(sessionId);
      setState(() => _messages = messages);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading messages: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _currentSessionId == null) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.sendChatMessage(
        _currentSessionId!,
        userMessage,
      );
      if (result['success']) {
        // Reload messages to show both user and AI response
        await _selectSession(_currentSessionId!);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSession(int sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text(
          'Are you sure you want to delete this chat session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteChatSession(sessionId);
        await _loadSessions();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting session: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kausapin si Juan'), centerTitle: true),
      body: _isLoading && _chatSessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Sidebar with sessions
                Container(
                  width: 250,
                  color: Colors.grey[200],
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: _createNewSession,
                          icon: const Icon(Icons.add),
                          label: const Text('New Chat'),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _chatSessions.length,
                          itemBuilder: (context, index) {
                            final session = _chatSessions[index];
                            final isSelected =
                                session['id'] == _currentSessionId;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: Colors.blue[100],
                              title: Text(
                                session['title'] ?? 'Chat ${session['id']}',
                              ),
                              onTap: () => _selectSession(session['id']),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Delete'),
                                    onTap: () => _deleteSession(session['id']),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat area
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _currentSessionId == null
                            ? const Center(
                                child: Text(
                                  'Select a chat or create a new one',
                                ),
                              )
                            : ListView.builder(
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final msg = _messages[index];
                                  final isUser = msg['role'] == 'user';
                                  return Align(
                                    alignment: isUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isUser
                                            ? Colors.blue
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        msg['content'],
                                        style: TextStyle(
                                          color: isUser
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      // Input area
                      if (_currentSessionId != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  enabled: !_isLoading,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FloatingActionButton(
                                onPressed: _isLoading ? null : _sendMessage,
                                child: const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
