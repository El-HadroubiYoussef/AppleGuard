import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String? _analysisContext;

  int get currentIndex => _currentIndex;
  String? get analysisContext => _analysisContext;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void switchToChatWithContext(String context) {
    _analysisContext = context;
    _currentIndex = 1;
    notifyListeners();
  }

  void clearAnalysisContext() {
    _analysisContext = null;
  }

  void switchToChat() {
    _analysisContext = null;
    _currentIndex = 1;
    notifyListeners();
  }
}
