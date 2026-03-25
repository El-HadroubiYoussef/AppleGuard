import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/analysis_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/ai_service.dart';
import '../../services/database_service.dart';
import '../../screens/settings/about_page.dart';
import '../../screens/settings/feedback_page.dart';
import '../../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _apiKeyController;
  late String _selectedApiType;
  bool _isLoading = true;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _selectedApiType = 'gemini';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedConfig();
    });
  }

  void _loadSavedConfig() {
    final settings = context.read<PreferencesState>();
    setState(() {
      _apiKeyController.text = settings.apiKey;
      _selectedApiType = settings.apiType;
      _isLoading = false;
    });
  }

  Future<bool> _validateApiKey(String apiKey, String apiType) async {
    if (apiKey.isEmpty) return false;

    try {
      final aiService = AIService();
      final testResponse = await aiService.testConnection(apiKey, apiType);
      return testResponse;
    } catch (e) {
      print('API validation failed: $e');
      return false;
    }
  }

  Future<void> _saveApiKey() async {
    final l10n = AppLocalizations.of(context);
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.apiKeyRequired ?? 'Please enter an API key'),
        ),
      );
      return;
    }

    setState(() => _isValidating = true);

    try {
      final isValid = await _validateApiKey(apiKey, _selectedApiType);

      if (!isValid && mounted) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n?.invalidApiKey ?? 'Invalid API Key'),
            content: Text(
              'The API key appears to be invalid or the service is unavailable. '
              'Do you still want to save it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n?.saveApiKey ?? 'Save API Key'),
              ),
            ],
          ),
        );

        if (shouldContinue != true) {
          setState(() => _isValidating = false);
          return;
        }
      }

      await context.read<PreferencesState>().setApiConfig(
        apiKey,
        _selectedApiType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isValid
                  ? '✅ ${l10n?.analysisComplete ?? 'API key saved and validated successfully'}'
                  : '⚠️ ${l10n?.analysisFailed ?? 'API key saved but validation failed'}',
            ),
            backgroundColor: isValid ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n?.somethingWentWrong ?? 'Error saving API key'}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.clearAllData ?? 'Clear All Data'),
        content: Text(
          l10n?.thisActionCannotBeUndone ?? 'This action cannot be undone',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final db = DatabaseService();
        await db.clearAllData();

        if (mounted) {
          final analysisProvider = Provider.of<AnalysisProvider>(
            context,
            listen: false,
          );
          await analysisProvider.loadHistory();

          final chatProvider = Provider.of<ChatProvider>(
            context,
            listen: false,
          );
          await chatProvider.loadSessions();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.deletedSuccessfully ?? 'All data cleared successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n?.errorDeleting ?? 'Error clearing data'}: $e',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settings ?? 'Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n?.general ?? 'General',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n?.language ?? 'Language'),
                        subtitle: Text(_getCurrentLanguageName(context)),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () {
                          _showLanguageDialog(context);
                        },
                      ),
                      const Divider(indent: 16, endIndent: 16),

                      ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: Text(l10n?.darkMode ?? 'Dark Mode'),
                        subtitle: Text(
                          l10n?.switchBetweenLightDark ??
                              'Switch between light and dark theme',
                        ),
                        trailing: Switch(
                          value: context.watch<PreferencesState>().isDarkMode,
                          onChanged: (value) {
                            context.read<PreferencesState>().toggleDarkMode(
                              value,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  l10n?.aiConfiguration ?? 'AI Configuration',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedApiType,
                          decoration: InputDecoration(
                            labelText: l10n?.aiConfiguration ?? 'AI Service',
                            border: const OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'gemini',
                              child: Text('Google Gemini'),
                            ),
                            DropdownMenuItem(
                              value: 'openai',
                              child: Text('OpenAI ChatGPT'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedApiType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _apiKeyController,
                          decoration: InputDecoration(
                            labelText: l10n?.apiKey ?? 'API Key',
                            border: const OutlineInputBorder(),
                            hintText: l10n?.apiKey ?? 'Enter your API key',
                            suffixIcon: _apiKeyController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _apiKeyController.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _isValidating ? null : _saveApiKey,
                            child: _isValidating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n?.saveApiKey ?? 'Save API Key'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  l10n?.dataManagement ?? 'Data Management',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: Text(l10n?.clearAllData ?? 'Clear All Data'),
                        subtitle: Text(
                          l10n?.deleteAllAnalysesAndChat ??
                              'Delete all analyses and chat history',
                        ),
                        onTap: _clearAllData,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  l10n?.about ?? 'About',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: Text(l10n?.about ?? 'About'),
                        subtitle: Text(
                          l10n?.about ?? 'App information and how it works',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.feedback),
                        title: Text(l10n?.sendFeedback ?? 'Send Feedback'),
                        subtitle: Text(
                          l10n?.sendFeedback ??
                              'Report issues or suggest improvements',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FeedbackPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _getCurrentLanguageName(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.selectLanguage ?? 'Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Français'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }
}
