import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';

class PreferencesState extends ChangeNotifier {
  final AIService _ai = AIService();
  final DatabaseService _db = DatabaseService();

  bool _isDarkMode = false;
  String _apiKey = '';
  String _apiType = 'gemini';

  bool get isDarkMode => _isDarkMode;
  String get apiKey => _apiKey;
  String get apiType => _apiType;

  PreferencesState() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadFromPrefs();
    await _loadApiFromDb();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading preferences: $e');
      _isDarkMode = false;
      notifyListeners();
    }
  }

  Future<void> _loadApiFromDb() async {
    try {
      final config = await _db.loadApiConfig();
      _apiKey = config['apiKey'] ?? '';
      _apiType = config['apiType'] ?? 'gemini';
      if (_apiKey.isNotEmpty) {
        _ai.updateApiKey(_apiKey);
        _ai.updateApiType(_apiType);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading API config: $e');

      _apiKey = '';
      _apiType = 'gemini';
      notifyListeners();
    }
  }

  void toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setApiConfig(String apiKey, String apiType) async {
    _apiKey = apiKey;
    _apiType = apiType;
    await _ai.saveConfig(apiKey, apiType);
    notifyListeners();
  }
}
