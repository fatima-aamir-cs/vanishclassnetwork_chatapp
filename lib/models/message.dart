
enum MessageStatus {
  waiting,
  sent,
  delivered,
  displayed,
  expired,
  dropped,
}

class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final DateTime createdAt;
  final DateTime expiresAt;
  MessageStatus status;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    required this.expiresAt,
    this.status = MessageStatus.sent,
  });

  int get remainingSeconds {
    final difference = expiresAt.difference(DateTime.now()).inSeconds;
    return difference > 0 ? difference : 0;
  }

  bool get isExpired {
    return !DateTime.now().isBefore(expiresAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: json['sender'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      status: MessageStatus.values.firstWhere(
            (value) => value.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }
}
