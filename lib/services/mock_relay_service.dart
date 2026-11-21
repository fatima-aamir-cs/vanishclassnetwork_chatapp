
import 'dart:async';
import 'dart:math';

import '../models/message.dart';

class MockRelayService {
  final StreamController<ChatMessage> _messageController =
  StreamController<ChatMessage>.broadcast();

  final Random _random = Random();

  // Listen for incoming demo messages
  Stream<ChatMessage> get incomingMessages =>
      _messageController.stream;

  // Simulate sending a message
  Future<void> sendMessage(ChatMessage message) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Simulate successful demo delivery
    message.status = MessageStatus.delivered;
  }

  // Generate demo messages
  void startDemoMessages(String currentUser) {
    Timer.periodic(const Duration(seconds: 12), (timer) {
      final names = ['Ali', 'Sara', 'Ahmed', 'Ayesha'];

      final demoMessages = [
        'Hello everyone!',
        'How is your project going?',
        'Anyone working on Flutter?',
        'Good work everyone!',
        'See you in class!',
      ];

      final sender = names[_random.nextInt(names.length)];

      final message = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: sender,
        text: demoMessages[_random.nextInt(demoMessages.length)],
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(seconds: 30)),
        status: MessageStatus.delivered,
      );

      if (sender != currentUser && !_messageController.isClosed) {
        _messageController.add(message);
      }
    });
  }

  void dispose() {
    _messageController.close();
  }
}
