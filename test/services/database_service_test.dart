import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:apple_guard/services/database_service.dart';

void main() {
  // Initialize FFI database factory for tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Service Tests', () {
    late DatabaseService dbService;

    setUp(() async {
      dbService = DatabaseService();
    });

    test('Save and load API configuration', () async {
      await dbService.saveApiKey('test_key', 'gemini');
      final config = await dbService.loadApiConfig();
      expect(config['apiKey'], 'test_key');
    });
  });
}
