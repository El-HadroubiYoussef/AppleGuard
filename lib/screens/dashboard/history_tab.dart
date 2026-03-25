import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../l10n/app_localizations.dart';
import '../../models/analysis_model.dart';
import '../../providers/analysis_provider.dart';
import '../../screens/dashboard/analysis_detail_screen.dart';
import '../../utils/localization_helper.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'#{1,6}\s+'), '')
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
        .replaceAll(RegExp(r'`(.*?)`'), r'$1')
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.analyses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  l10n.noAnalysesYet,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.startByAnalyzing,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: provider.analyses.length,
          itemBuilder: (context, index) {
            final analysis = provider.analyses[index];
            return _buildHistoryItem(context, analysis);
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, AnalysisModel analysis) {
    final l10n = AppLocalizations.of(context)!;
    final localizedDiseaseName = LocalizationHelper.getLocalizedDiseaseName(
      context,
      analysis.diseaseName,
    );
    final previewText = _stripMarkdown(analysis.aiFeedback);

    return Dismissible(
      key: Key(analysis.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.delete),
            content: Text(l10n.deleteAllAnalysesAndChat),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          final imageFile = File(analysis.imagePath);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }

          await context.read<AnalysisProvider>().deleteAnalysis(analysis.id);

          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.deletedSuccessfully)));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.errorDeleting}: $e')),
            );
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FutureBuilder<bool>(
              future: File(analysis.imagePath).exists(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return Image.file(
                    File(analysis.imagePath),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 30),
                      );
                    },
                  );
                }
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 30),
                );
              },
            ),
          ),
          title: Text(
            localizedDiseaseName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(analysis.timestamp, context),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                previewText.length > 60
                    ? '${previewText.substring(0, 60)}...'
                    : previewText,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Chip(
            label: Text('${(analysis.confidence * 100).toStringAsFixed(0)}%'),
            backgroundColor: analysis.confidence > 0.7
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            labelStyle: TextStyle(
              color: analysis.confidence > 0.7 ? Colors.green : Colors.orange,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalysisDetailScreen(analysis: analysis),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${l10n.today}, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return '${l10n.yesterday}, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${l10n.daysAgo}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
