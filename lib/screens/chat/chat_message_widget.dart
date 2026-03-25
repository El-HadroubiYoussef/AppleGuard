import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../widgets/markdown_response.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(Icons.assistant, Colors.green),
          const SizedBox(width: 8),
          Flexible(
            child: MarkdownResponse(
              content: message.text,
              isUser: message.isUser,
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(Icons.person, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildAvatar(IconData icon, Color color) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
