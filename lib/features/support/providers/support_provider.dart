import 'package:flutter/material.dart';
import '../services/support_service.dart';
import '../models/chat_message.dart';

class SupportProvider extends ChangeNotifier {
  final SupportService _supportService = SupportService();
  
  List<ChatMessage> _messages = [];
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _faqItems = [];
  bool _isLoading = false;
  String _error = '';
  int _unreadCount = 0;

  List<ChatMessage> get messages => _messages;
  List<Map<String, dynamic>> get tickets => _tickets;
  List<Map<String, dynamic>> get faqItems => _faqItems;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get unreadCount => _unreadCount;

  SupportProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSupportChat();
    _listenToUnreadCount();
  }

  Future<void> _loadSupportChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load initial messages
      _listenToMessages();
      
      // Load tickets
      _listenToTickets();
      
      // Load FAQ items
      await _loadFaqItems();
      
      _error = '';
    } catch (e) {
      _error = 'Failed to load support data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToMessages() {
    _supportService.getSupportChatMessages().listen(
      (messages) {
        _messages = messages;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load messages: $error';
        notifyListeners();
      },
    );
  }

  void _listenToTickets() {
    _supportService.getUserSupportTickets().listen(
      (tickets) {
        _tickets = tickets;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load tickets: $error';
        notifyListeners();
      },
    );
  }

  void _listenToUnreadCount() {
    _supportService.getUnreadMessageCount().listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load unread count: $error';
        notifyListeners();
      },
    );
  }

  Future<void> _loadFaqItems() async {
    try {
      _faqItems = await _supportService.getFaqItems();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load FAQ items: $e';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      await _supportService.sendMessageToSupport(message: message);
      _error = '';
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  Future<void> markMessagesAsRead(List<String> messageIds) async {
    try {
      await _supportService.markMessagesAsRead(messageIds);
      _error = '';
    } catch (e) {
      _error = 'Failed to mark messages as read: $e';
      notifyListeners();
    }
  }

  Future<void> createSupportTicket({
    required String title,
    required String description,
    String? category,
    String? priority,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supportService.createSupportTicket(
        title: title,
        description: description,
        category: category,
        priority: priority,
      );
      _error = '';
    } catch (e) {
      _error = 'Failed to create support ticket: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFaq(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _faqItems = await _supportService.searchFaq(query);
      _error = '';
    } catch (e) {
      _error = 'Failed to search FAQ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadSupportChat();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
