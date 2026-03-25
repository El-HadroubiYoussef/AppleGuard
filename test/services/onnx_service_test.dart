import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

void main() {
  group('ONNX Service Logic Tests', () {
    List<double> softmax(List<double> logits) {
      double maxLogit = logits.reduce((a, b) => a > b ? a : b);
      List<double> expValues = logits.map((l) => exp(l - maxLogit)).toList();
      double sumExp = expValues.reduce((a, b) => a + b);
      return expValues.map((e) => e / sumExp).toList();
    }

    double calculateEntropy(List<double> probs) {
      double entropy = 0.0;
      const double epsilon = 1e-9;
      for (final p in probs) {
        if (p > epsilon) entropy -= p * log(p);
      }
      return entropy;
    }

    test('Softmax returns probabilities summing to 1', () {
      final logits = [2.0, 1.0, 0.1];
      final probs = softmax(logits);
      final sum = probs.reduce((a, b) => a + b);

      expect(sum, closeTo(1.0, 0.0001));
    });

    test('Softmax maintains order of probabilities', () {
      final logits = [5.0, 2.0, 1.0];
      final probs = softmax(logits);

      expect(probs[0], greaterThan(probs[1]));
      expect(probs[1], greaterThan(probs[2]));
    });

    test('Entropy is zero for deterministic distribution', () {
      final deterministicProbs = [1.0, 0.0, 0.0, 0.0, 0.0];
      final entropy = calculateEntropy(deterministicProbs);

      expect(entropy, closeTo(0.0, 0.001));
    });

    test('Entropy is maximal for uniform distribution', () {
      final uniformProbs = [0.2, 0.2, 0.2, 0.2, 0.2];
      final entropy = calculateEntropy(uniformProbs);
      final maxEntropy = log(5); // ≈ 1.609

      expect(entropy, closeTo(maxEntropy, 0.001));
    });
  });
}
