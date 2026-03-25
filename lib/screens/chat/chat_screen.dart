import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/chat_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/error_handler.dart';
import 'chat_message_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _hasSentContext = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      if (provider.currentSession == null) {
        provider.startNewSession();
      }

      final navProvider = context.read<NavigationProvider>();
      final analysisContext = navProvider.analysisContext;

      if (analysisContext != null && !_hasSentContext) {
        _hasSentContext = true;
        _sendAnalysisContext(analysisContext);
        navProvider.clearAnalysisContext();
      }
    });
  }

  Future<void> _sendAnalysisContext(String analysisContext) async {
    setState(() => _isTyping = true);

    try {
      await context.read<ChatProvider>().sendMessage(context, analysisContext);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() => _isTyping = true);

    try {
      await context.read<ChatProvider>().sendMessage(
        context,
        text,
      ); // Pass context
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final messages = provider.currentSession?.messages ?? [];

        return Column(
          children: [
            Expanded(
              child: messages.isEmpty && !provider.isLoading
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (provider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && provider.isLoading) {
                          return _buildTypingIndicator(context);
                        }
                        return ChatMessageWidget(message: messages[index]);
                      },
                    ),
            ),
            if (provider.isLoading && messages.isEmpty)
              const LinearProgressIndicator(),
            _buildInputBar(context),
          ],
        );
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            child: const Icon(Icons.assistant, size: 16, color: Colors.green),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomLeft: Radius.zero),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 20,
                  child: Text('.', style: TextStyle(fontSize: 24, height: 0.8)),
                ),
                SizedBox(
                  width: 20,
                  child: Text('.', style: TextStyle(fontSize: 24, height: 0.8)),
                ),
                SizedBox(
                  width: 20,
                  child: Text('.', style: TextStyle(fontSize: 24, height: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.askAboutAppleTrees, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            l10n.diseasesCareTreatment,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip(context, l10n.appleScab),
              _buildSuggestionChip(context, l10n.fireBlight),
              _buildSuggestionChip(context, l10n.howToPrune),
              _buildSuggestionChip(context, l10n.organicTreatment),
              _buildSuggestionChip(context, l10n.fertilizerSchedule),
              _buildSuggestionChip(context, l10n.pestControl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _controller.text = text;
        _sendMessage();
      },
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: _isTyping ? l10n.sending : l10n.typeYourMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabled: !_isTyping,
              ),
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isTyping,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _isTyping
                ? Colors.grey
                : Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(
                _isTyping ? Icons.close : Icons.send,
                color: Colors.white,
              ),
              onPressed: _isTyping ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
