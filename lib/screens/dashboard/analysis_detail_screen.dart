import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import '../../models/analysis_model.dart';
import '../../l10n/app_localizations.dart';
import '../chat/analysis_chat_screen.dart';
import '../../utils/localization_helper.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final AnalysisModel analysis;

  const AnalysisDetailScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localizedDiseaseName = LocalizationHelper.getLocalizedDiseaseName(
      context,
      analysis.diseaseName,
    );
    final rawPrediction = analysis.rawPrediction;
    final probsList = rawPrediction?['probs'] as List? ?? [];
    final latency = rawPrediction?['latency'] as double?;
    final entropy = rawPrediction?['entropy'] as double?;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizedDiseaseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAnalysis(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<bool>(
                future: File(analysis.imagePath).exists(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return Image.file(
                      File(analysis.imagePath),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, size: 50),
                                const SizedBox(height: 8),
                                Text(l10n.imageProcessingError),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Container(
                    height: 250,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                localizedDiseaseName,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: analysis.confidence > 0.7
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              constraints: const BoxConstraints(minWidth: 70),
                              child: Text(
                                '${(analysis.confidence * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: analysis.confidence,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        analysis.confidence > 0.7
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    if (latency != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            size: 16,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${l10n.processingTime}: ${latency.toStringAsFixed(2)}ms',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.psychology,
                            size: 16,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${l10n.uncertainty}: ${entropy?.toStringAsFixed(3) ?? l10n.notAvailable}',
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (probsList.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.detailedAnalysis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DataTable(
                                  columnSpacing: 24,
                                  horizontalMargin: 16,
                                  headingRowHeight: 48,
                                  dataRowMinHeight: 48,
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                    verticalInside: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                  ),
                                  columns: [
                                    DataColumn(
                                      label: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 120,
                                        ),
                                        child: Text(
                                          l10n.classLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 100,
                                        ),
                                        child: Text(
                                          l10n.probability,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 100,
                                        ),
                                        child: Text(
                                          l10n.rawLogit,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: probsList.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    final isTop =
                                        item['label'] == analysis.diseaseName;
                                    final isDarkMode =
                                        Theme.of(context).brightness ==
                                        Brightness.dark;
                                    final probability =
                                        (item['probability'] * 100)
                                            .toStringAsFixed(1);

                                    return DataRow(
                                      color:
                                          WidgetStateProperty.resolveWith<
                                            Color?
                                          >((Set<WidgetState> states) {
                                            if (index.isEven) {
                                              return isDarkMode
                                                  ? Colors.grey.shade800
                                                        .withValues(alpha: 0.3)
                                                  : Colors.grey.shade50;
                                            }
                                            return null;
                                          }),
                                      cells: [
                                        DataCell(
                                          Text(
                                            LocalizationHelper.getLocalizedDiseaseName(
                                              context,
                                              item['label'],
                                            ),
                                            style: TextStyle(
                                              fontWeight: isTop
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isTop
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '$probability%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isTop
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isTop
                                                    ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                    : Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              item['logit'].toStringAsFixed(2),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiAnalysis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownBody(
                      data: analysis.aiFeedback,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.5),
                        h1: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        h2: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        h3: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        listBullet: Theme.of(context).textTheme.bodyMedium,
                        code: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        ),
                        blockquote: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            final confidencePercent =
                                (analysis.confidence * 100).toStringAsFixed(1);

                            final contextMessage =
                                '''
I'm reviewing an apple leaf analysis:

- Disease: ${analysis.diseaseName}
- Confidence: $confidencePercent%

Could you provide more detailed information about this disease?
''';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnalysisChatScreen(
                                  initialMessage: contextMessage,
                                ),
                              ),
                            );
                          },
                          child: Text(l10n.chatWithAi),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () =>
                              _copyToClipboard(context, analysis.aiFeedback),
                          child: Text(l10n.copy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.analysisInfo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      l10n.date,
                      _formatDateTime(analysis.timestamp),
                    ),
                    _buildInfoRow(
                      context,
                      l10n.time,
                      _formatTime(analysis.timestamp),
                    ),
                    _buildInfoRow(
                      context,
                      l10n.analysisId,
                      analysis.id.toString(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copiedToClipboard)),
    );
  }

  void _shareAnalysis(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.share)),
    );
  }
}
