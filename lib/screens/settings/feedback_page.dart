import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();
  String _feedbackType = 'suggestion';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      // Get localized feedback type label
      String feedbackLabel;
      switch (_feedbackType) {
        case 'suggestion':
          feedbackLabel = l10n.suggestion;
          break;
        case 'bug':
          feedbackLabel = l10n.bugReport;
          break;
        case 'feature':
          feedbackLabel = l10n.featureRequest;
          break;
        default:
          feedbackLabel = l10n.other;
      }

      final email = Uri(
        scheme: 'mailto',
        path: 'support@example.com',
        query: encodeQueryParameters(<String, String>{
          'subject': 'App Feedback: $feedbackLabel',
          'body':
              '''
Name: ${_nameController.text}
Email: ${_emailController.text}
Type: $feedbackLabel

Feedback:
${_feedbackController.text}
          ''',
        }),
      );

      if (await canLaunchUrl(email)) {
        await launchUrl(email);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.sendFeedback)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
      }
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sendFeedback)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.about,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.somethingWentWrong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.somethingWentWrong;
                  }
                  if (!value.contains('@')) {
                    return l10n.somethingWentWrong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _feedbackType,
                decoration: InputDecoration(
                  labelText: l10n.feedbackType,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'suggestion',
                    child: Text(l10n.suggestion),
                  ),
                  DropdownMenuItem(value: 'bug', child: Text(l10n.bugReport)),
                  DropdownMenuItem(
                    value: 'feature',
                    child: Text(l10n.featureRequest),
                  ),
                  DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                ],
                onChanged: (value) {
                  setState(() {
                    _feedbackType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: l10n.sendFeedback,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.feedback),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.somethingWentWrong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.sendFeedback),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
