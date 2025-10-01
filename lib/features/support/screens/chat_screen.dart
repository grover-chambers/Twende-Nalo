import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final String type;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.createdAt,
    required this.type,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      type: data['type'] ?? 'text',
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String otherUserId; // user ID of chat partner
  final String currentUserId;

  const ChatScreen({super.key, required this.otherUserId, required this.currentUserId});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String chatId;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatId = getChatId(widget.currentUserId, widget.otherUserId);
    fetchMessages();
  }

  // Fetch messages and listen for real-time updates
  void fetchMessages() {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      List<ChatMessage> msgs = [];
      for (var doc in snapshot.docs) {
        msgs.add(ChatMessage.fromFirestore(doc));
      }
      setState(() {
        _messages = msgs;
      });
      _scrollToBottom();
    });
  }

  // Utility function to scroll to bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Generate chat id
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // Send text message
  Future<void> _sendTextMessage(String text) async {
    if (text.isEmpty) return; // Prevent sending empty messages
    final messageId = const Uuid().v4();
    final data = {
      'text': text,
      'senderId': widget.currentUserId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'type': 'text',
    };
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set(data);
    _messageController.clear();
  }

  // Send image message
  Future<void> _sendImageMessage(String imageUrl) async {
    final messageId = const Uuid().v4();
    final data = {
      'imageUrl': imageUrl,
      'senderId': widget.currentUserId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'type': 'image',
    };
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set(data);
  }

  // Pick image and upload
  Future<String?> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return null;

    final ref = FirebaseStorage.instance.ref().child('chat_images').child('${const Uuid().v4()}.jpg');
    await ref.putFile(File(pickedImage.path));
    return await ref.getDownloadURL();
  }

  void _onImageSend() async {
    final imageUrl = await _pickAndUploadImage();
    if (imageUrl != null) {
      _sendImageMessage(imageUrl);
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isCurrentUser = message.senderId == widget.currentUserId;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == 'text')
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                    ),
                  ),
                if (message.type == 'image' && message.imageUrl != null)
                  Image.network(
                    message.imageUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 4),
                Text(
                  '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserId}'),
        actions: [
          IconButton(
            key: const ValueKey('sendImageButton'),
            icon: const Icon(Icons.camera_alt),
            onPressed: _onImageSend,
            tooltip: 'Send Image',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _sendTextMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendTextMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
