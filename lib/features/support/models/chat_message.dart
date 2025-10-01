import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  system,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String? receiverId;
  final MessageType type;
  final String? text;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.receiverId,
    required this.type,
    this.text,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'],
      type: _parseMessageType(data['type'] ?? 'text'),
      text: data['text'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'type': _messageTypeToString(type),
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  static MessageType _parseMessageType(String typeString) {
    switch (typeString) {
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.image:
        return 'image';
      case MessageType.system:
        return 'system';
      default:
        return 'text';
    }
  }

  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isSystem => type == MessageType.system;

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    MessageType? type,
    String? text,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderId: $senderId, type: $type, text: $text, createdAt: $createdAt)';
  }
}
