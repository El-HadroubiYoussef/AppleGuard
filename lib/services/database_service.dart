import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/analysis_model.dart';
import '../models/chat_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'apple_disease.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE analyses(
            id INTEGER PRIMARY KEY,
            imagePath TEXT,
            diseaseKey TEXT,
            diseaseName TEXT,
            confidence REAL,
            aiFeedback TEXT,
            timestamp TEXT,
            rawPrediction TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE chat_sessions(
            id TEXT PRIMARY KEY,
            title TEXT,
            startTime TEXT,
            lastMessageTime TEXT,
            messages TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE app_settings(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        await db.insert('app_settings', {'key': 'api_key', 'value': ''});
        await db.insert('app_settings', {'key': 'api_type', 'value': 'gemini'});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE app_settings(
              key TEXT PRIMARY KEY,
              value TEXT
            )
          ''');
          await db.insert('app_settings', {'key': 'api_key', 'value': ''});
          await db.insert('app_settings', {
            'key': 'api_type',
            'value': 'gemini',
          });
        }
        if (oldVersion < 3) {
          try {
            await db.execute(
              'ALTER TABLE chat_sessions ADD COLUMN messages TEXT',
            );
          } catch (e) {}
        }
        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE analyses ADD COLUMN diseaseKey TEXT');
          } catch (e) {}
        }
      },
    );
  }

  Future<void> saveApiKey(String apiKey, String apiType) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('app_settings', {
        'key': 'api_key',
        'value': apiKey,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('app_settings', {
        'key': 'api_type',
        'value': apiType,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<Map<String, String>> loadApiConfig() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'app_settings',
      where: 'key IN (?, ?)',
      whereArgs: ['api_key', 'api_type'],
    );

    String apiKey = '';
    String apiType = 'gemini';

    for (var row in results) {
      if (row['key'] == 'api_key') {
        apiKey = row['value'] as String? ?? '';
      } else if (row['key'] == 'api_type') {
        apiType = row['value'] as String? ?? 'gemini';
      }
    }

    return {'apiKey': apiKey, 'apiType': apiType};
  }

  Future<void> insertAnalysis(AnalysisModel analysis) async {
    final db = await database;
    await db.insert('analyses', analysis.toMap());
  }

  Future<List<AnalysisModel>> getAnalyses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'analyses',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => AnalysisModel.fromMap(maps[i]));
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('analyses');
      await txn.delete('chat_sessions');
    });
  }

  Future<void> deleteAnalysis(int id) async {
    final db = await database;
    await db.delete('analyses', where: 'id = ?', whereArgs: [id]);
  }

  String _serializeMessages(List<ChatMessage> messages) {
    final List<Map<String, dynamic>> messageMaps = messages
        .map(
          (msg) => {
            'id': msg.id,
            'text': msg.text,
            'isUser': msg.isUser,
            'timestamp': msg.timestamp.toIso8601String(),
          },
        )
        .toList();
    return jsonEncode(messageMaps);
  }

  List<ChatMessage> _deserializeMessages(String? messagesJson) {
    if (messagesJson == null || messagesJson.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(messagesJson);
      return decoded
          .map(
            (msg) => ChatMessage(
              id: msg['id'],
              text: msg['text'],
              isUser: msg['isUser'],
              timestamp: DateTime.parse(msg['timestamp']),
            ),
          )
          .toList();
    } catch (e) {
      print('Error deserializing messages: $e');
      return [];
    }
  }

  Future<void> insertChatSession(ChatSession session) async {
    final db = await database;
    await db.insert('chat_sessions', {
      'id': session.id,
      'title': session.title,
      'startTime': session.startTime.toIso8601String(),
      'lastMessageTime': session.lastMessageTime.toIso8601String(),
      'messages': _serializeMessages(session.messages),
    });
  }

  Future<List<ChatSession>> getChatSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_sessions',
      orderBy: 'lastMessageTime DESC',
    );
    return List.generate(
      maps.length,
      (i) => ChatSession(
        id: maps[i]['id'],
        title: maps[i]['title'],
        startTime: DateTime.parse(maps[i]['startTime']),
        lastMessageTime: DateTime.parse(maps[i]['lastMessageTime']),
        messages: _deserializeMessages(maps[i]['messages']),
      ),
    );
  }

  Future<void> updateChatSession(ChatSession session) async {
    final db = await database;
    await db.update(
      'chat_sessions',
      {
        'title': session.title,
        'lastMessageTime': session.lastMessageTime.toIso8601String(),
        'messages': _serializeMessages(session.messages),
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> deleteChatSession(String sessionId) async {
    final db = await database;
    await db.delete('chat_sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<ChatSession?> getChatSession(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (results.isEmpty) return null;

    final map = results.first;
    return ChatSession(
      id: map['id'],
      title: map['title'],
      startTime: DateTime.parse(map['startTime']),
      lastMessageTime: DateTime.parse(map['lastMessageTime']),
      messages: _deserializeMessages(map['messages']),
    );
  }
}
