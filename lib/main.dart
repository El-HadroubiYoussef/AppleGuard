import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'widgets/cascadingmenu.dart';
import 'screens/settings/settings_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/statistics/statistics_screen.dart';

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final bool _isChatVisible = false;

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = context.watch<NavigationProvider>().currentIndex;
    final locale = context.watch<LocaleProvider>().locale;

    final isRtl = locale.languageCode == 'ar';

    final preferencesState = context.watch<PreferencesState>();
    final isDarkMode = preferencesState.isDarkMode;

    final ThemeData themeData = ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorScheme: isDarkMode
          ? const ColorScheme.dark(primary: Colors.green)
          : const ColorScheme.light(primary: Colors.green),
    );

    return MaterialApp(
      title: 'AppleGuard',
      theme: themeData,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routes: {'/settings': (context) => const SettingsPage()},
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);

          return Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  currentPageIndex == 0
                      ? (l10n?.appTitle ?? 'Disease Detector')
                      : currentPageIndex == 1
                      ? (l10n?.assistant ?? 'AI Assistant')
                      : (l10n?.statistics ?? 'Statistics'),
                ),
                actions: <Widget>[
                  if (!_isChatVisible && currentPageIndex != 1)
                    const CascadingMenu(key: ValueKey('appbar_menu')),
                  if (currentPageIndex == 1)
                    IconButton(
                      icon: const Icon(Icons.add_comment),
                      onPressed: () async {
                        final chatProvider = context.read<ChatProvider>();
                        await chatProvider.startNewSession();
                        setState(() {});
                      },
                      tooltip: l10n?.newChat ?? 'New Chat',
                    ),
                  if (currentPageIndex == 1)
                    const CascadingMenu(key: ValueKey('chat_menu')),
                ],
              ),
              body: IndexedStack(
                index: currentPageIndex,
                children: const [
                  DashboardScreen(),
                  ChatScreen(),
                  StatisticsScreen(),
                ],
              ),
              bottomNavigationBar: _isChatVisible
                  ? null
                  : NavigationBar(
                      selectedIndex: currentPageIndex,
                      onDestinationSelected: (int index) {
                        context.read<NavigationProvider>().setIndex(index);
                      },
                      labelBehavior:
                          NavigationDestinationLabelBehavior.onlyShowSelected,
                      destinations: [
                        NavigationDestination(
                          selectedIcon: const Icon(Icons.dashboard),
                          icon: const Icon(Icons.dashboard_outlined),
                          label: l10n?.dashboard ?? 'Dashboard',
                        ),
                        NavigationDestination(
                          selectedIcon: const Icon(Icons.assistant),
                          icon: const Icon(Icons.assistant_outlined),
                          label: l10n?.assistant ?? 'Assistant',
                        ),
                        NavigationDestination(
                          selectedIcon: const Icon(Icons.assessment),
                          icon: const Icon(Icons.assessment_outlined),
                          label: l10n?.statistics ?? 'Statistics',
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesState()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const AppHome(),
    ),
  );
}
