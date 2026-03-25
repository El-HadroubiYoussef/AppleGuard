import 'package:flutter_test/flutter_test.dart';
import 'package:apple_guard/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider Tests', () {
    late NavigationProvider provider;

    setUp(() {
      provider = NavigationProvider();
    });

    test('Initial index is 0', () {
      expect(provider.currentIndex, 0);
      expect(provider.analysisContext, null);
    });

    test('setIndex changes current page', () {
      provider.setIndex(1);
      expect(provider.currentIndex, 1);

      provider.setIndex(2);
      expect(provider.currentIndex, 2);
    });

    test('switchToChatWithContext stores context', () {
      provider.switchToChatWithContext('Test context');
      expect(provider.currentIndex, 1);
      expect(provider.analysisContext, 'Test context');
    });

    test('clearAnalysisContext removes context', () {
      provider.switchToChatWithContext('Test context');
      provider.clearAnalysisContext();
      expect(provider.analysisContext, null);
    });

    test('switchToChat clears context', () {
      provider.switchToChatWithContext('Test context');
      provider.switchToChat();
      expect(provider.currentIndex, 1);
      expect(provider.analysisContext, null);
    });
  });
}
