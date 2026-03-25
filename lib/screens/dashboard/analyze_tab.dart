import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../chat/analysis_chat_screen.dart';
import 'dart:io';
import '../../models/analysis_model.dart';
import '../../providers/analysis_provider.dart';
import '../../widgets/image_source_dialog.dart';
import '../../utils/localization_helper.dart';

class AnalyzeTab extends StatelessWidget {
  const AnalyzeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.isAnalyzing) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analyzing leaf image...'),
              ],
            ),
          );
        }

        if (provider.currentAnalysis != null) {
          return _buildResult(context, provider.currentAnalysis!);
        }
        return _buildInitial(context);
      },
    );
  }

  Widget _buildInitial(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.agriculture, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          Text(
            l10n.analyzeLeafDisease,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.takePhotoOrSelect,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showImageSourceDialog(context),
            icon: const Icon(Icons.camera_alt),
            label: Text(l10n.startAnalysis),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, AnalysisModel analysis) {
    final l10n = AppLocalizations.of(context)!;
    final diseaseName = analysis.diseaseName;
    final rawPrediction = analysis.rawPrediction;
    final probsList = rawPrediction?['probs'] as List? ?? [];
    final latency = rawPrediction?['latency'] as double?;
    final entropy = rawPrediction?['entropy'] as double?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(analysis.imagePath),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
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
                              diseaseName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
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
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      analysis.confidence > 0.7 ? Colors.green : Colors.orange,
                    ),
                  ),
                  if (latency != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.speed, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${l10n.processingTime}: ${latency.toStringAsFixed(2)}ms',
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.psychology,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${l10n.uncertainty}: ${entropy?.toStringAsFixed(3) ?? l10n.notAvailable}',
                            style: const TextStyle(color: Colors.grey),
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
                                        WidgetStateProperty.resolveWith<Color?>(
                                          (Set<WidgetState> states) {
                                            if (index.isEven) {
                                              return isDarkMode
                                                  ? Colors.grey.shade800
                                                        .withValues(alpha: 0.3)
                                                  : Colors.grey.shade50;
                                            }
                                            return null;
                                          },
                                        ),
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
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aiAnalysis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          final confidencePercent = (analysis.confidence * 100)
                              .toStringAsFixed(1);

                          final contextMessage =
                              '''
I just analyzed an apple leaf and got these results:

- Disease: ${analysis.diseaseName}
- Confidence: $confidencePercent%

Can you provide more details about this disease, including treatment options and prevention methods?
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
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<AnalysisProvider>()
                              .clearCurrentAnalysis();
                        },
                        child: Text(l10n.newAnalysis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final originalContext = context;

    showModalBottomSheet(
      context: originalContext,
      builder: (bottomSheetContext) => ImageSourceDialog(
        onCamera: () {
          Navigator.pop(bottomSheetContext);
          originalContext.read<AnalysisProvider>().analyzeFromCamera(
            originalContext,
          );
        },
        onGallery: () {
          Navigator.pop(bottomSheetContext);
          originalContext.read<AnalysisProvider>().analyzeFromGallery(
            originalContext,
          );
        },
      ),
    );
  }
}
