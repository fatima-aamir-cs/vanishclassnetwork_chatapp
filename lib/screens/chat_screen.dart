
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/message.dart';
import '../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final String username;

  const ChatScreen({
    super.key,
    required this.username,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
  TextEditingController();

  late final MessageService _messageService;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _messageService = MessageService();
    _messageService.initialize(widget.username);

    // Refresh countdown and connection status.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || text.length > 500) return;

    _messageController.clear();

    await _messageService.sendMessage(
      widget.username,
      text,
    );
  }

  String get connectionStatus {
    final pending = _messageService.messages.any(
          (message) =>
      message.status == MessageStatus.waiting ||
          message.status == MessageStatus.sent,
    );

    if (!_messageService.isConnected) {
      return pending
          ? 'Waiting in queue...'
          : 'Connecting to server...';
    }

    return pending
        ? 'Online • Sending...'
        : 'Online • All messages sent';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    unawaited(_messageService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101426),

      appBar: AppBar(
        backgroundColor: const Color(0xFF202941),
        foregroundColor: Colors.white,
        title: const Text('VANISH CLASS CHAT'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Welcome ${widget.username}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messageService.messagesStream,
              initialData: _messageService.messages,
              builder: (context, snapshot) {
                final messages =
                    snapshot.data ?? _messageService.messages;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final message = messages[index];

                    final isMine =
                        message.sender == widget.username;

                    final seconds = message.remainingSeconds;

                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.78,
                        ),

                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),

                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: isMine
                              ? const Color(0xFF8B7CF6)
                              : const Color(0xFF202941),

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Text(
                              message.sender,
                              style: const TextStyle(
                                color: Color(0xFFD5CCFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              message.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Disappears in ${seconds}s',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Text(
              connectionStatus,
              style: const TextStyle(
                color: Color(0xFFB8AEFF),
                fontSize: 12,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLength: 500,
                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF202941),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    onSubmitted: (_) => sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF9B8CFF),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
