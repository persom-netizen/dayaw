import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
import 'services/api_service.dart';

class AiPage extends StatefulWidget {
  final String username;
  const AiPage({super.key, required this.username});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    // Check if widget is still mounted before starting
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getChatHistory(username: widget.username);

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      if (result['success'] == true && result['chats'] != null) {
        List<Map<String, String>> loadedMessages = [];

        for (var chat in (result['chats'] as List).reversed) {
          loadedMessages.add({
            'type': 'user',
            'message': chat['user_message'] ?? '',
            'id': chat['id'].toString(),
          });
          loadedMessages.add({
            'type': 'ai',
            'message': chat['ai_response'] ?? '',
            'id': chat['id'].toString(),
          });
        }

        setState(() => _messages = loadedMessages);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading chat: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();

    if (message.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _messages.add({'type': 'user', 'message': message, 'id': ''});
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final result = await ApiService.askOpenAI(
        message,
        username: widget.username,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _messages.add({
            'type': 'ai',
            'message': result['answer'] ?? 'Walang response',
            'id': result['chat_id']?.toString() ?? '',
          });
        });
      } else {
        setState(() {
          _messages.add({
            'type': 'ai',
            'message': 'Error: ${result['error'] ?? 'Unknown error'}',
            'id': '',
          });
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({'type': 'ai', 'message': 'Error: $e', 'id': ''});
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> _deleteMessage(String chatId) async {
    if (chatId.isEmpty) return;

    try {
      await ApiService.deleteChat(int.parse(chatId));

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chat deleted')));
      _loadChatHistory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting chat: $e')));
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              // Messages List
              Expanded(
                child: _messages.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Walang mensahe pa',
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: fontProvider.descriptionSize,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Magsimula ng pag-usap sa Juan',
                              style: GoogleFonts.inter(
                                color: Colors.grey[500],
                                fontSize: fontProvider.header4Size,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['type'] == 'user';

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: !isUser && msg['id']!.isNotEmpty
                                  ? () => _deleteMessage(msg['id']!)
                                  : null,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Colors.blue[500]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: isUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg['message'] ?? '',
                                      style: GoogleFonts.inter(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: fontProvider.descriptionSize,
                                      ),
                                    ),
                                    if (!isUser && msg['id']!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Long press to delete',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey[500],
                                            fontSize: fontProvider.header4Size,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Loading Indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),

              // Input Field
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: !_isLoading,
                        style: GoogleFonts.inter(
                          fontSize: fontProvider.descriptionSize,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Magsulat ng mensahe...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey[500],
                            fontSize: fontProvider.descriptionSize,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      mini: true,
                      backgroundColor: Colors.blue[600],
                      child: Icon(
                        _isLoading ? Icons.hourglass_top : Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
