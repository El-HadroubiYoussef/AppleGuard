import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Localization Helper Tests', () {
    test('Confidence level returns correct string', () {
      String getConfidenceLevel(double confidence) {
        if (confidence > 0.7) return 'high';
        if (confidence > 0.4) return 'medium';
        return 'low';
      }

      expect(getConfidenceLevel(0.9), 'high');
      expect(
        getConfidenceLevel(0.7),
        'medium',
      ); // boundary: >0.7, so 0.7 is medium
      expect(getConfidenceLevel(0.5), 'medium');
      expect(getConfidenceLevel(0.4), 'low');
      expect(getConfidenceLevel(0.3), 'low');
    });
  });
}
