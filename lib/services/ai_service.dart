import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../l10n/app_localizations.dart';
import '../utils/localization_helper.dart';
import 'package:http/http.dart' as http;
import 'database_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  String _apiKey = '';
  String _apiType = 'gemini';
  String _currentLanguage = 'en';
  final DatabaseService _db = DatabaseService();

  GenerativeModel? _model;
  ChatSession? _chatSession;

  List<Map<String, String>> _openAIContext = [];

  String _getSystemInstruction(String languageCode) {
    final languageName = _getLanguageName(languageCode);

    return '''
You are an expert agricultural AI assistant specializing in apple tree diseases.
Provide practical, helpful advice for farmers and gardeners.
Use clear sections with emojis when appropriate.
Always be accurate and focus on actionable recommendations.
DO NOT give long responses, keep your responses medium size.

IMPORTANT: You MUST respond in $languageName language. 
The user is communicating in $languageName, so all your responses should be in $languageName.
Use the appropriate language for all sections, headings, and content.
''';
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'Arabic (العربية)';
      case 'fr':
        return 'French (Français)';
      case 'en':
      default:
        return 'English';
    }
  }

  String get apiKey => _apiKey;
  String get apiType => _apiType;
  bool get hasValidKey => _apiKey.isNotEmpty;

  AIService() {
    _loadConfig();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language_code') ?? 'en';
      debugPrint('AIService loaded language: $_currentLanguage');

      if (_apiKey.isNotEmpty && _apiType == 'gemini') {
        _initGeminiModel();
      } else if (_apiKey.isNotEmpty && _apiType == 'openai') {
        _initOpenAIContext();
      }
    } catch (e) {
      debugPrint('Failed to load language: $e');
    }
  }

  Future<void> _loadConfig() async {
    try {
      final config = await _db.loadApiConfig();
      _apiKey = config['apiKey'] ?? '';
      _apiType = config['apiType'] ?? 'gemini';

      if (_apiKey.isNotEmpty && _apiType == 'gemini') {
        _initGeminiModel();
      } else if (_apiKey.isNotEmpty && _apiType == 'openai') {
        _initOpenAIContext();
      }

      debugPrint('AIService loaded: $_apiType, key length: ${_apiKey.length}');
    } catch (e) {
      debugPrint('Failed to load API config: $e');
    }
  }

  void _initGeminiModel() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite', // Working model
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
      systemInstruction: Content.system(
        _getSystemInstruction(_currentLanguage),
      ),
    );
  }

  void _initOpenAIContext() {
    _openAIContext = [
      {'role': 'system', 'content': _getSystemInstruction(_currentLanguage)},
    ];
  }

  Future<void> saveConfig(String apiKey, String apiType) async {
    await _db.saveApiKey(apiKey, apiType);
    _apiKey = apiKey;
    _apiType = apiType;

    if (apiKey.isNotEmpty) {
      if (apiType == 'gemini') {
        _initGeminiModel();
        _chatSession = null;
      } else if (apiType == 'openai') {
        _initOpenAIContext();
      }
    }

    debugPrint('AIService saved: $_apiType');
  }

  void updateApiKey(String apiKey) {
    _apiKey = apiKey;
    if (_apiKey.isNotEmpty) {
      if (_apiType == 'gemini') {
        _initGeminiModel();
        _chatSession = null;
      } else if (_apiType == 'openai') {
        _initOpenAIContext();
      }
    }
  }

  void updateApiType(String apiType) {
    _apiType = apiType;
    if (_apiKey.isNotEmpty) {
      if (_apiType == 'gemini') {
        _initGeminiModel();
        _chatSession = null;
      } else if (_apiType == 'openai') {
        _initOpenAIContext();
      }
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    debugPrint('AIService updating language to: $_currentLanguage');

    if (_apiKey.isNotEmpty) {
      if (_apiType == 'gemini') {
        _initGeminiModel();
        _chatSession = null;
      } else if (_apiType == 'openai') {
        _initOpenAIContext();
      }
    }
  }

  Future<bool> testConnection(String apiKey, String apiType) async {
    if (apiKey.isEmpty) return false;

    try {
      if (apiType == 'gemini') {
        final model = GenerativeModel(
          model: 'gemini-2.5-flash-lite',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 10,
          ),
        );

        final response = await model.generateContent([
          Content.text('Reply with "OK" if you can read this message.'),
        ]);

        return response.text?.contains('OK') ?? false;
      } else if (apiType == 'openai') {
        final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'user',
                'content': 'Reply with "OK" if you can read this message.',
              },
            ],
            'max_tokens': 10,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'];
          return content?.contains('OK') ?? false;
        }
        return false;
      }
      return false;
    } catch (e) {
      print('API test failed: $e');
      return false;
    }
  }

  Future<String> getDiseaseFeedback({
    required BuildContext context,
    required String diseaseName,
    required double confidence,
    String? imagePath,
    List<Map<String, dynamic>>? probsList,
    double? latency,
    double? entropy,
  }) async {
    // CRITICAL: Check if context is mounted at the START
    if (!context.mounted) {
      print('Context not mounted in getDiseaseFeedback, using default');
      return _getDefaultFeedback(context, diseaseName, confidence);
    }

    final l10n = AppLocalizations.of(context);

    final currentLocale = Localizations.localeOf(context);
    final languageCode = currentLocale.languageCode;

    if (_currentLanguage != languageCode) {
      await updateLanguage(languageCode);
    }

    if (_apiKey.isEmpty) {
      print('No API key, using default feedback');
      return _getDefaultFeedback(context, diseaseName, confidence);
    }

    String probsTable = '';
    if (probsList != null && probsList.isNotEmpty) {
      probsTable =
          '\n\n## 📊 ${l10n?.detailedAnalysis ?? 'Detailed Analysis'}\n\n';
      probsTable +=
          '| ${l10n?.classLabel ?? 'Class Label'} | ${l10n?.probability ?? 'Probability'} |\n';
      probsTable += '|-------------|------------|\n';
      for (final item in probsList) {
        final label = item['label'];
        final prob = (item['probability'] * 100).toStringAsFixed(1);
        final isTop = label == diseaseName;
        probsTable += '| ${isTop ? '**$label**' : label} | $prob% |\n';
      }

      probsTable += '\n**${l10n?.analysisInfo ?? 'Metrics'}:**\n';
      probsTable +=
          '- ⚡ **${l10n?.processingTime ?? 'Processing Time'}:** ${latency?.toStringAsFixed(2) ?? 'N/A'}ms\n';
      probsTable +=
          '- 🎲 **${l10n?.uncertainty ?? 'Uncertainty'}:** ${entropy?.toStringAsFixed(3) ?? 'N/A'}\n';
    }

    final localizedDiseaseName = LocalizationHelper.getLocalizedDiseaseName(
      context,
      diseaseName,
    );
    final confidencePercent = (confidence * 100).toStringAsFixed(1);

    final languageInstruction = _getLanguageInstruction(languageCode);

    final prompt =
        '''
${languageInstruction}

**${l10n?.diagnosisResults ?? 'Diagnosis Results'}:**\n
- **${l10n?.detectedDisease ?? 'Detected Disease'}:** $diseaseName
- **${l10n?.confidence ?? 'Confidence'}:** $confidencePercent%
$probsTable

Please provide a comprehensive analysis for this apple leaf disease.

Provide the response in this exact format:

### Disease Description
[Brief description of $diseaseName and common symptoms]

### Treatment Recommendations
**Organic Options:**
- [List organic treatments]

**Chemical Options:**
- [List chemical treatments if necessary]

### Prevention Tips
- [List prevention strategies]

### When to Act
- [Severity indicators and urgency levels]

### Additional Notes
- [Any other relevant information]

Keep the response practical and helpful for farmers. Use emojis and clear sections.
''';

    try {
      print(
        'Calling AI API for disease: $diseaseName in language: $languageCode',
      );
      String response;
      if (_apiType == 'gemini') {
        response = await _getGeminiFeedback(prompt);
      } else {
        response = await _getOpenAIFeedback(prompt);
      }
      print('AI feedback received, length: ${response.length}');
      return response;
    } catch (e) {
      print('AI feedback failed: $e');
      if (context.mounted) {
        return _getErrorFeedback(context, diseaseName, confidence, e);
      } else {
        return _getDefaultFeedback(context, diseaseName, confidence);
      }
    }
  }

  String _getLanguageInstruction(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'IMPORTANT: You must respond in Arabic language (العربية). All your responses should be in Arabic.';
      case 'fr':
        return 'IMPORTANT: You must respond in French language (Français). All your responses should be in French.';
      case 'en':
      default:
        return 'IMPORTANT: You must respond in English language. All your responses should be in English.';
    }
  }

  Future<String> _getGeminiFeedback(String prompt) async {
    if (_model == null) {
      _initGeminiModel();
    }
    final content = [Content.text(prompt)];
    final response = await _model!.generateContent(content);
    return response.text?.trim() ?? 'No response generated.';
  }

  Future<String> _getOpenAIFeedback(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': _getSystemInstruction(_currentLanguage),
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 2048,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else {
      final errorData = jsonDecode(response.body);
      final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
      throw Exception('OpenAI API error: $errorMsg');
    }
  }

  Future<String> chat({
    required BuildContext context,
    required String message,
    required List<dynamic> contextMessages,
  }) async {
    final l10n = AppLocalizations.of(context);

    final currentLocale = Localizations.localeOf(context);
    final languageCode = currentLocale.languageCode;
    if (_currentLanguage != languageCode) {
      await updateLanguage(languageCode);
    }

    if (_apiKey.isEmpty) {
      return "⚠️ ${l10n?.apiKeyRequired ?? 'Please configure your API key in Settings first.'}";
    }

    try {
      if (_apiType == 'gemini') {
        return await _geminiChat(message);
      } else if (_apiType == 'openai') {
        return await _openAIChat(message);
      }
      return "${l10n?.apiKeyRequired ?? 'Please configure your API in Settings first.'}";
    } catch (e) {
      debugPrint('Chat error: $e');
      return '${l10n?.somethingWentWrong ?? 'Error'}: ${e.toString()}';
    }
  }

  Future<String> _geminiChat(String message) async {
    if (_model == null) {
      _initGeminiModel();
    }
    _chatSession ??= _model!.startChat();
    final response = await _chatSession!.sendMessage(Content.text(message));
    return response.text?.trim() ?? 'No response.';
  }

  Future<String> _openAIChat(String message) async {
    _openAIContext.add({'role': 'user', 'content': message});

    if (_openAIContext.length > 20) {
      _openAIContext = [
        _openAIContext[0],
        ..._openAIContext.sublist(_openAIContext.length - 19),
      ];
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': _openAIContext,
        'temperature': 0.7,
        'max_tokens': 2048,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final assistantMessage = data['choices'][0]['message']['content']
          .toString()
          .trim();
      _openAIContext.add({'role': 'assistant', 'content': assistantMessage});
      return assistantMessage;
    } else {
      final errorData = jsonDecode(response.body);
      final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
      throw Exception('OpenAI API error: $errorMsg');
    }
  }

  void resetChat() {
    _chatSession = null;
    _openAIContext = [
      {'role': 'system', 'content': _getSystemInstruction(_currentLanguage)},
    ];
  }

  String _getErrorFeedback(
    BuildContext context,
    String diseaseName,
    double confidence,
    dynamic error,
  ) {
    final l10n = AppLocalizations.of(context);
    final errorStr = error.toString().toLowerCase();
    final confidencePercent = (confidence * 100).toStringAsFixed(1);

    if (errorStr.contains('rate limit') || errorStr.contains('quota')) {
      return '''
## ⚠️ ${l10n?.rateLimitReached ?? 'API Rate Limit Reached'}

**${l10n?.confidence ?? 'Confidence'}:** $confidencePercent%

${l10n?.rateLimitMessage ?? 'The AI service is currently experiencing high demand. Please try again in a few minutes.'}

**${l10n?.quickActions ?? 'Quick Actions'}:**
- ${l10n?.checkApiQuota ?? 'Check your API quota'}
- ${l10n?.tryAgainLater ?? 'Try again later'}
- ${l10n?.useLocalAnalysis ?? 'Use the local analysis results for immediate action'}

---
*${l10n?.localDiagnosis ?? 'Local diagnosis shows'} $confidencePercent% ${l10n?.confidence ?? 'confidence'}.*
''';
    }

    if (errorStr.contains('permission') ||
        errorStr.contains('api key') ||
        errorStr.contains('auth')) {
      return '''
## 🔑 ${l10n?.apiKeyRequiredTitle ?? 'API Key Configuration Required'}

**${l10n?.confidence ?? 'Confidence'}:** $confidencePercent%

${l10n?.invalidApiKeyMessage ?? 'Your API key appears to be invalid or not properly configured.'}

**${l10n?.whatToDo ?? 'What to do'}:**
1. ${l10n?.goToSettings ?? 'Go to'} **${l10n?.settings ?? 'Settings'}** → **${l10n?.aiConfiguration ?? 'AI Configuration'}**
2. ${l10n?.verifyApiKey ?? 'Verify your API key is correct'}
3. ${l10n?.clickTestConnection ?? 'Click'} **${l10n?.testConnection ?? 'Test Connection'}** ${l10n?.toValidate ?? 'to validate'}
4. ${l10n?.saveAndRetry ?? 'Save the key and try again'}

---
*${l10n?.localDiagnosis ?? 'Local diagnosis shows'} $confidencePercent% ${l10n?.confidence ?? 'confidence'}.*
''';
    }

    return '''
## 🔧 ${l10n?.serviceUnavailable ?? 'Service Temporarily Unavailable'}

**${l10n?.confidence ?? 'Confidence'}:** $confidencePercent%

${l10n?.unableToFetchAnalysis ?? 'Unable to fetch detailed AI analysis at this moment.'}

**${l10n?.whatToDo ?? 'What to do'}:**
1. ${l10n?.checkInternetConnection ?? 'Check your internet connection'}
2. ${l10n?.verifyApiConfig ?? 'Verify API configuration in Settings'}
3. ${l10n?.tryAgainLater ?? 'Try again in a few minutes'}

---
*${l10n?.localDiagnosis ?? 'Local diagnosis shows'} $confidencePercent% ${l10n?.confidence ?? 'confidence'}.*
''';
  }

  String _getDefaultFeedback(
    BuildContext context,
    String diseaseName,
    double confidence,
  ) {
    final l10n = AppLocalizations.of(context);
    final confidencePercent = (confidence * 100).toStringAsFixed(1);
    final localizedDiseaseName = LocalizationHelper.getLocalizedDiseaseName(
      context,
      diseaseName,
    );

    return '''
## 🌿 ${l10n?.localAnalysisComplete ?? 'Local Analysis Complete'}

**${l10n?.detectedDisease ?? 'Detected Disease'}:** $localizedDiseaseName  
**${l10n?.confidence ?? 'Confidence'}:** $confidencePercent%

### 📋 ${l10n?.basicRecommendations ?? 'Basic Recommendations'}:
- ${l10n?.removeAffectedLeaves ?? 'Remove and dispose of affected leaves'}
- ${l10n?.ensureAirCirculation ?? 'Ensure good air circulation around trees'}
- ${l10n?.monitorOtherTrees ?? 'Monitor other trees for symptoms'}

### 🛡️ ${l10n?.preventionTips ?? 'Prevention Tips'}:
- ${l10n?.orchardSanitation ?? 'Practice good orchard sanitation'}
- ${l10n?.avoidOverheadWatering ?? 'Avoid overhead watering'}
- ${l10n?.applyPreventativeTreatments ?? 'Apply preventative treatments in early spring'}

---
📱 **${l10n?.detailedAiAdvice ?? 'For detailed AI advice'}**  
${l10n?.configureApiKey ?? 'Please configure your API key in'} **${l10n?.settings ?? 'Settings'}** → **${l10n?.aiConfiguration ?? 'AI Configuration'}** ${l10n?.getPersonalizedPlans ?? 'to get personalized treatment plans.'}
''';
  }
}
