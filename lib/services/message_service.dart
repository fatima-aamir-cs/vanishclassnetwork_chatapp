
import 'dart:async';
import 'dart:math';

import '../models/message.dart';
import 'storage_services.dart';
import 'connectivity_services.dart';
import 'websocket_relay_service.dart';


class MessageService {
  final StorageService _storage = StorageService();
  final ConnectivityService _connectivity = ConnectivityService();
  final WebSocketRelayService _relay = WebSocketRelayService();


  final List<ChatMessage> _messages = [];

  final StreamController<List<ChatMessage>> _controller =
  StreamController<List<ChatMessage>>.broadcast();

  Stream<List<ChatMessage>> get messagesStream => _controller.stream;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Timer? _expiryTimer;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<Map<String, dynamic>>? _incomingSubscription;

  bool _isConnected = false;
  bool get isConnected => _isConnected;
  bool _started = false;

  // Start message service
  Future<void> initialize(String username) async {
    if (_started) return;
    _started = true;

    await _storage.deleteExpiredMessages();

    final savedMessages = await _storage.getActiveMessages();

    _messages.addAll(savedMessages);


    _incomingSubscription = _relay.events.listen(_receiveEvent);

    _connectionSubscription =
        _relay.connectionStream.listen((connected) {
          _isConnected = connected;
          _publishMessages();

          if (connected) {
            _sendPendingMessages();
          }
        });
    await _relay.connect(username);


    _expiryTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _checkExpiry(),
    );

    _publishMessages();
  }

  // Send a new message
  Future<void> sendMessage(String sender, String text) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();

    final message = ChatMessage(
      id: '${now.microsecondsSinceEpoch}_${Random().nextInt(999999)}',
      sender: sender,
      text: text.trim(),
      createdAt: now,
      expiresAt: now.add(const Duration(seconds: 30)),
      status: MessageStatus.waiting,
    );

    _messages.add(message);
    await _storage.saveMessage(message);

    _publishMessages();

    if (_isConnected) {
      await _deliverMessage(message);
    }
  }

  // Deliver message
  Future<void> _deliverMessage(ChatMessage message) async {
    if (message.isExpired) {
      await _dropMessage(message);
      return;
    }

    _relay.sendMessage(message);

    if (message.isExpired) {
      await _dropMessage(message);
      return;
    }

    await _storage.saveMessage(message);
    _publishMessages();
  }

  // Send waiting messages
  Future<void> _sendPendingMessages() async {
    final pending = _messages
        .where((message) => message.status == MessageStatus.waiting)
        .toList();

    for (final message in pending) {
      await _deliverMessage(message);
    }
  }

  Future<void> _receiveEvent(Map<String, dynamic> data) async {
    if (data['type'] != 'message') return;

    final id = data['id']?.toString();
    final sender = data['sender']?.toString();
    final text = data['text']?.toString();

    if (id == null || sender == null || text == null) return;

    final alreadyExists = _messages.any(
          (item) => item.id == id,
    );

    if (alreadyExists) return;

    final now = DateTime.now();

    final message = ChatMessage(
      id: id,
      sender: sender,
      text: text,
      createdAt: now,
      expiresAt: now.add(const Duration(seconds: 30)),
      status: MessageStatus.delivered,
    );

    _messages.add(message);
    await _storage.saveMessage(message);

    _publishMessages();
  }

  // Expiry handling
  Future<void> _checkExpiry() async {
    final expiredMessages =
    _messages.where((message) => message.isExpired).toList();

    if (expiredMessages.isEmpty) return;

    _messages.removeWhere((message) => message.isExpired);

    await _storage.deleteExpiredMessages();

    _publishMessages();
  }

  // Drop expired pending message
  Future<void> _dropMessage(ChatMessage message) async {
    message.status = MessageStatus.dropped;

    _messages.removeWhere((item) => item.id == message.id);

    await _storage.deleteExpiredMessages();

    _publishMessages();
  }

  // Publish updated messages
  void _publishMessages() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_messages));
    }
  }

  // Cleanup
  Future<void> dispose() async {
    _expiryTimer?.cancel();

    await _connectionSubscription?.cancel();
    await _incomingSubscription?.cancel();

    _relay.dispose();

    await _controller.close();

    _started = false;
  }
}
