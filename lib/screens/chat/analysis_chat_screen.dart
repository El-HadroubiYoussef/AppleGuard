import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/chat_provider.dart';
import '../../utils/error_handler.dart';
import '../../widgets/markdown_response.dart';
import '../../models/chat_model.dart';

class AnalysisChatScreen extends StatefulWidget {
  final String initialMessage;

  const AnalysisChatScreen({super.key, required this.initialMessage});

  @override
  State<AnalysisChatScreen> createState() => _AnalysisChatScreenState();
}

class _AnalysisChatScreenState extends State<AnalysisChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _hasSentInitialMessage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      if (provider.currentSession == null) {
        provider.startNewSession();
      }

      if (!_hasSentInitialMessage && widget.initialMessage.isNotEmpty) {
        _hasSentInitialMessage = true;
        _sendMessage(widget.initialMessage);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // lib/screens/analysis_chat_screen.dart
  // Update this method:

  // Update _sendMessage method
  Future<void> _sendMessage(String text) async {
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

  void _sendFromInput() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _sendMessage(text);
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiAnalysisAssistant),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final provider = context.read<ChatProvider>();
              await provider.startNewSession();
              _hasSentInitialMessage = false;
              if (widget.initialMessage.isNotEmpty) {
                _sendMessage(widget.initialMessage);
              }
              setState(() {});
            },
            tooltip: l10n.newChat,
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          final messages = provider.currentSession?.messages ?? [];

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty && !provider.isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.agriculture,
                              size: 80,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.askAboutLeafAnalysis,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.initialMessage.isNotEmpty
                                  ? l10n.sendingAnalysisData
                                  : l10n.typeQuestionAboutDisease,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            messages.length + (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && provider.isLoading) {
                            return _buildTypingIndicator(context);
                          }
                          return _buildMessageBubble(context, messages[index]);
                        },
                      ),
              ),
              if (provider.isLoading && messages.isEmpty)
                const LinearProgressIndicator(),
              _buildInputBar(context),
            ],
          );
        },
      ),
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

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: const Icon(Icons.assistant, size: 16, color: Colors.green),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: MarkdownResponse(
              content: message.text,
              isUser: message.isUser,
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 16, color: Colors.blue),
            ),
        ],
      ),
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
                hintText: _isTyping ? l10n.sending : l10n.askAboutDisease,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabled: !_isTyping,
              ),
              onSubmitted: (_) => _sendFromInput(),
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
              onPressed: _isTyping ? null : _sendFromInput,
            ),
          ),
        ],
      ),
    );
  }
}
