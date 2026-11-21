
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';

class WebSocketRelayService {
  static const String serverUrl =
      'wss://vanish-relay-sawaira.bonto.page/ws';

  final _eventController =
  StreamController<Map<String, dynamic>>.broadcast();

  final _connectionController =
  StreamController<bool>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  String _username = '';
  String _deviceId = '';

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _manuallyClosed = false;

  int _retryIndex = 0;
  int? serverTimeOffsetMs;
  int? _lastPongAt;

  final List<int> _retryDelays = [1, 2, 4, 8];

  Stream<Map<String, dynamic>> get events =>
      _eventController.stream;

  Stream<bool> get connectionStream =>
      _connectionController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect(String username) async {
    _username = username.trim();

    if (_username.isEmpty || _isConnecting) return;

    _manuallyClosed = false;

    _deviceId =
    '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}';

    await _connectToServer();
  }

  Future<void> _connectToServer() async {
    if (_isConnecting || _manuallyClosed) return;

    _isConnecting = true;

    try {
      final channel =
      WebSocketChannel.connect(Uri.parse(serverUrl));

      _channel = channel;

      await channel.ready;

      _subscription = channel.stream.listen(
            (frame) => _handleFrame(frame, channel),
        onError: (error) {
          print('WEBSOCKET ERROR: $error');
          _handleDisconnect(channel);
        },
        onDone: () {
          print('WEBSOCKET CLOSED');
          _handleDisconnect(channel);
        },
      );

      channel.sink.add(jsonEncode({
        'type': 'join',
        'protocol': 1,
        'device_id': _deviceId,
        'name': _username,
      }));
    } catch (error, stackTrace) {
      print('SERVER CONNECTION ERROR: $error');
      print(stackTrace);
      _handleDisconnect(_channel);
    } finally {
      _isConnecting = false;
    }
  }

  void _handleFrame(dynamic frame, WebSocketChannel channel) {
    if (!identical(_channel, channel)) return;

    try {
      if (frame is! String) return;

      final decoded = jsonDecode(frame);

      if (decoded is! Map) return;

      final data = Map<String, dynamic>.from(decoded);
      final type = data['type'];

      if (type == 'welcome') {
        serverTimeOffsetMs =
            (data['server_time'] as num).toInt() -
                DateTime.now().millisecondsSinceEpoch;

        _retryIndex = 0;
        _setConnected(true);
        _startHeartbeat();
      }

      if (type == 'pong') {
        _lastPongAt = DateTime.now().millisecondsSinceEpoch;
      }

      _eventController.add(data);
    } catch (error) {
      // Ignore invalid server frames.
    }
  }

  bool sendMessage(ChatMessage message) {
    if (!_isConnected || _channel == null) {
      return false;
    }

    if (message.isExpired) {
      return false;
    }

    try {
      _channel!.sink.add(jsonEncode({
        'type': 'message',
        'id': message.id,
        'sender': _username,
        'text': message.text,
      }));

      return true;
    } catch (error) {
      return false;
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _lastPongAt = DateTime.now().millisecondsSinceEpoch;

    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 15),
          (_) {
        if (!_isConnected || _channel == null) return;

        final now = DateTime.now().millisecondsSinceEpoch;

        if (now - (_lastPongAt ?? now) > 30000) {
          _channel?.sink.close();
          return;
        }

        _channel?.sink.add(jsonEncode({
          'type': 'ping',
        }));
      },
    );
  }

  void _handleDisconnect(WebSocketChannel? channel) {
    if (channel != null && !identical(_channel, channel)) {
      return;
    }

    _setConnected(false);

    _heartbeatTimer?.cancel();

    _subscription?.cancel();
    _subscription = null;

    _channel = null;

    _scheduleReconnect();
  }

  void _setConnected(bool value) {
    if (_isConnected == value) return;

    _isConnected = value;

    if (!_connectionController.isClosed) {
      _connectionController.add(value);
    }
  }

  void _scheduleReconnect() {
    if (_manuallyClosed || _reconnectTimer != null) return;

    final delay = _retryDelays[
    min(_retryIndex, _retryDelays.length - 1)];

    if (_retryIndex < _retryDelays.length - 1) {
      _retryIndex++;
    }

    _reconnectTimer = Timer(
      Duration(seconds: delay),
          () {
        _reconnectTimer = null;
        _connectToServer();
      },
    );
  }

  Future<void> dispose() async {
    _manuallyClosed = true;

    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    await _subscription?.cancel();

    await _channel?.sink.close();

    _channel = null;
    _setConnected(false);

    await _eventController.close();
    await _connectionController.close();
  }
}
