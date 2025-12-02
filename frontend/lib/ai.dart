import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';

class AiPage extends StatefulWidget {
  final String username;
  const AiPage({super.key, required this.username});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  
  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

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
    return Consumer2<FontProvider, ThemeProvider>(
      builder: (context, fontProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final bgColor = isDark ? const Color(0xFF1F1F1F) : backgroundColor;
        final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
        final textColorThemed = isDark ? Colors.white : textColor;
        
        return Scaffold(
          backgroundColor: bgColor,
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
                              color: primaryYellow,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Walang mensahe pa',
                              style: GoogleFonts.inter(
                                color: textColorThemed,
                                fontSize: fontProvider.descriptionSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Magsimula ng pag-usap sa Juan',
                              style: GoogleFonts.inter(
                                color: textColorThemed.withValues(alpha: 0.6),
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

                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Align(
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
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? primaryYellow
                                        : cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg['message'] ?? '',
                                        style: GoogleFonts.inter(
                                          color: isUser ? textColor : textColorThemed,
                                          fontSize: fontProvider.descriptionSize,
                                        ),
                                      ),
                                      if (!isUser && msg['id']!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Long press to delete',
                                            style: GoogleFonts.inter(
                                              color: textColorThemed.withValues(alpha: 0.5),
                                              fontSize: fontProvider.header4Size,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Loading Indicator
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryYellow,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Juan is typing...',
                              style: GoogleFonts.inter(
                                color: textColorThemed.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Input Field
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: !_isLoading,
                        style: GoogleFonts.inter(
                          fontSize: fontProvider.descriptionSize,
                          color: textColorThemed,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Magsulat ng mensahe...',
                          hintStyle: GoogleFonts.inter(
                            color: textColorThemed.withValues(alpha: 0.4),
                            fontSize: fontProvider.descriptionSize,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: primaryYellow.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: primaryYellow,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: bgColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryYellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryYellow.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _isLoading ? null : _sendMessage,
                        icon: Icon(
                          _isLoading ? Icons.hourglass_top : Icons.send_rounded,
                          color: textColor,
                        ),
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
