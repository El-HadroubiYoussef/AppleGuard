import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apple_guard/widgets/markdown_response.dart';

void main() {
  group('MarkdownResponse Widget Tests', () {
    testWidgets('Displays user message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownResponse(content: 'User message text', isUser: true),
          ),
        ),
      );

      expect(find.text('User message text'), findsOneWidget);
    });

    testWidgets('Displays AI message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownResponse(content: 'AI response text', isUser: false),
          ),
        ),
      );

      expect(find.text('AI response text'), findsOneWidget);
    });
  });
}
