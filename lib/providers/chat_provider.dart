import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/chat_model.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;

  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;

  final AIService _ai = AIService();
  final DatabaseService _db = DatabaseService();

  ChatProvider() {
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      _sessions = await _db.getChatSessions();
      notifyListeners();
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  Future<void> startNewSession() async {
    _currentSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Chat',
      startTime: DateTime.now(),
      lastMessageTime: DateTime.now(),
      messages: [],
    );

    try {
      await _db.insertChatSession(_currentSession!);
      _sessions.insert(0, _currentSession!);
      notifyListeners();
    } catch (e) {
      print('Error starting new session: $e');
    }
  }

  Future<void> sendMessage(BuildContext context, String text) async {
    if (_currentSession == null) {
      await startNewSession();
    }
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _currentSession!.messages.add(userMsg);
    _currentSession!.lastMessageTime = DateTime.now();

    await _db.updateChatSession(_currentSession!);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      if (!_ai.hasValidKey) {
        final l10n = AppLocalizations.of(context);
        final errorMsg = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              '⚠️ ${l10n?.apiKeyRequired ?? 'Please configure your API key in Settings first.'}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _currentSession!.messages.add(errorMsg);
        await _db.updateChatSession(_currentSession!);
        notifyListeners();
        return;
      }

      final response = await _ai.chat(
        context: context,
        message: text,
        contextMessages: _currentSession!.messages,
      );

      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _currentSession!.messages.add(aiMsg);

      if (_currentSession!.messages.length == 2) {
        _currentSession!.title = text.length > 30
            ? '${text.substring(0, 30)}...'
            : text;
      }

      _currentSession!.lastMessageTime = DateTime.now();
      await _db.updateChatSession(_currentSession!);

      final index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (index != -1) {
        _sessions[index] = _currentSession!;
      }
    } catch (e) {
      print('Chat failed: $e');
      final l10n = AppLocalizations.of(context);
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '${l10n?.somethingWentWrong ?? 'Error'}: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _currentSession!.messages.add(errorMsg);
      await _db.updateChatSession(_currentSession!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSession(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _db.getChatSession(sessionId);
      if (session != null) {
        _currentSession = session;

        final index = _sessions.indexWhere((s) => s.id == sessionId);
        if (index != -1) {
          _sessions[index] = session;
        }
      } else {
        print('Session not found: $sessionId');
      }
    } catch (e) {
      print('Error loading session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _db.deleteChatSession(sessionId);
      _sessions.removeWhere((s) => s.id == sessionId);

      if (_currentSession?.id == sessionId) {
        _currentSession = null;
      }

      notifyListeners();
    } catch (e) {
      print('Error deleting session: $e');
    }
  }

  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }
}
