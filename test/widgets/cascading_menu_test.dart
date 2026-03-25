import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apple_guard/widgets/cascadingmenu.dart';
import 'package:apple_guard/l10n/app_localizations.dart';

void main() {
  group('CascadingMenu Widget Tests', () {
    testWidgets('CascadingMenu can be created', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test'),
              actions: const [CascadingMenu()],
            ),
          ),
        ),
      );

      expect(find.byType(CascadingMenu), findsOneWidget);
    });
  });
}
