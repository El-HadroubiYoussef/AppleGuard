import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import '../../utils/localization_helper.dart';
import '../../providers/analysis_provider.dart';
import '../../models/analysis_model.dart';
import '../../l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _filterPeriod = 'week';

  List<AnalysisModel> _filterAnalyses(List<AnalysisModel> analyses) {
    final now = DateTime.now();
    switch (_filterPeriod) {
      case 'day':
        return analyses.where((a) {
          return a.timestamp.year == now.year &&
              a.timestamp.month == now.month &&
              a.timestamp.day == now.day;
        }).toList();
      case 'week':
        return analyses.where((a) {
          return a.timestamp.isAfter(now.subtract(const Duration(days: 7)));
        }).toList();
      case 'month':
        return analyses.where((a) {
          return a.timestamp.isAfter(now.subtract(const Duration(days: 30)));
        }).toList();
      case 'all':
      default:
        return analyses;
    }
  }

  Future<void> _exportCSV(
    List<AnalysisModel> analyses,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filterAnalyses(analyses);

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noDataToExport),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    List<List<String>> rows = [
      [l10n.date, l10n.disease, l10n.confidence, 'AI Feedback (Preview)'],
    ];

    for (var analysis in filtered) {
      rows.add([
        '${analysis.timestamp.year}-${analysis.timestamp.month}-${analysis.timestamp.day} ${analysis.timestamp.hour}:${analysis.timestamp.minute}',
        analysis.diseaseName,
        (analysis.confidence * 100).toStringAsFixed(1),
        analysis.aiFeedback
            .replaceAll('\n', ' ')
            .substring(
              0,
              analysis.aiFeedback.length > 100
                  ? 100
                  : analysis.aiFeedback.length,
            ),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final tempDir = await Directory.systemTemp.createTemp();
    final file = File(
      '${tempDir.path}/apple_disease_stats_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Apple Disease Detection Statistics - ${_getPeriodLabel(context)}',
    );
  }

  String _getPeriodLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_filterPeriod) {
      case 'day':
        return l10n.today;
      case 'week':
        return l10n.week;
      case 'month':
        return l10n.month;
      case 'all':
        return l10n.allTime;
      default:
        return l10n.allTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          final allAnalyses = provider.analyses;
          final analyses = _filterAnalyses(allAnalyses);

          if (allAnalyses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics, size: 80, color: Colors.grey),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, l10n.today, 'day', Icons.today),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        l10n.week,
                        'week',
                        Icons.calendar_view_week,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        l10n.month,
                        'month',
                        Icons.calendar_month,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        l10n.allTime,
                        'all',
                        Icons.history,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildSummaryCards(context, analyses),
                const SizedBox(height: 16),

                _buildDiseaseDistributionChart(context, analyses),
                const SizedBox(height: 16),

                _buildDailyVolumeChart(context, analyses),
                const SizedBox(height: 16),

                _buildConfidenceTrend(context, analyses),
                const SizedBox(height: 16),

                _buildDetailedStats(context, analyses),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _filterAnalyses(analyses).isEmpty
                        ? null
                        : () => _exportCSV(analyses, context),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(
                      '${l10n.exportAsCsv} (${_filterAnalyses(analyses).length} records)',
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String period,
    IconData icon,
  ) {
    final isSelected = _filterPeriod == period;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? (isDarkMode ? Colors.black : Colors.white)
                : null,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterPeriod = period;
          });
        }
      },
      backgroundColor: isDarkMode
          ? (isSelected ? Colors.green.shade300 : Colors.grey.shade800)
          : (isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200),
      selectedColor: isDarkMode
          ? Colors.green.shade300
          : Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? (isDarkMode ? Colors.black : Colors.white)
            : (isDarkMode ? Colors.white : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
          width: 1,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    List<AnalysisModel> analyses,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (analyses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              l10n.noDataToExport,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }

    final total = analyses.length;
    final avgConfidence =
        analyses.fold(0.0, (sum, a) => sum + a.confidence) / total;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: 170,
            child: _buildSummaryCard(
              context,
              l10n.totalAnalyses,
              total.toString(),
              Icons.analytics,
              Colors.blue,
              _getPeriodLabel(context),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 170,
            child: _buildSummaryCard(
              context,
              l10n.avgConfidence,
              '${(avgConfidence * 100).toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.green,
              l10n.allTime,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseDistributionChart(
    BuildContext context,
    List<AnalysisModel> analyses,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (analyses.isEmpty) {
      return const SizedBox.shrink();
    }

    final diseaseCounts = <String, int>{};
    for (var a in analyses) {
      diseaseCounts[a.diseaseKey] = (diseaseCounts[a.diseaseKey] ?? 0) + 1;
    }

    final total = analyses.length;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    final sortedDiseases = diseaseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.diseaseDistribution,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sortedDiseases.asMap().entries.map((entry) {
                    final index = entry.key;
                    final disease = entry.value;
                    final percentage = (disease.value / total) * 100;
                    final localizedName =
                        LocalizationHelper.getLocalizedDiseaseName(
                          context,
                          disease.key,
                        );
                    return PieChartSectionData(
                      value: disease.value.toDouble(),
                      title: percentage > 8 ? localizedName : '',
                      color: colors[index % colors.length],
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortedDiseases.asMap().entries.map((entry) {
                  final index = entry.key;
                  final disease = entry.value;
                  final percentage = (disease.value / total) * 100;
                  final localizedName =
                      LocalizationHelper.getLocalizedDiseaseName(
                        context,
                        disease.key,
                      );
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$localizedName (${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(
    BuildContext context,
    List<AnalysisModel> analyses,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (analyses.isEmpty) {
      return const SizedBox.shrink();
    }

    final diseaseCounts = <String, int>{};
    final diseaseConfidence = <String, List<double>>{};

    for (var a in analyses) {
      diseaseCounts[a.diseaseKey] = (diseaseCounts[a.diseaseKey] ?? 0) + 1;
      diseaseConfidence.putIfAbsent(a.diseaseKey, () => []);
      diseaseConfidence[a.diseaseKey]!.add(a.confidence);
    }

    final sortedDiseases = diseaseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.detailedAnalysis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DataTable(
                  columnSpacing: 16,
                  horizontalMargin: 12,
                  border: TableBorder(
                    horizontalInside: BorderSide(color: borderColor, width: 1),
                    verticalInside: BorderSide(color: borderColor, width: 1),
                  ),
                  columns: [
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.disease,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.totalAnalyses,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.probability,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.avgConfidence,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.minMax,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  rows: sortedDiseases.asMap().entries.map((entry) {
                    final index = entry.key;
                    final disease = entry.value;
                    final count = disease.value;
                    final percentage = (count / analyses.length) * 100;
                    final avgConfidence =
                        diseaseConfidence[disease.key]!.fold(
                          0.0,
                          (sum, c) => sum + c,
                        ) /
                        diseaseConfidence[disease.key]!.length;
                    final minConfidence = diseaseConfidence[disease.key]!
                        .reduce((a, b) => a < b ? a : b);
                    final maxConfidence = diseaseConfidence[disease.key]!
                        .reduce((a, b) => a > b ? a : b);
                    final localizedName =
                        LocalizationHelper.getLocalizedDiseaseName(
                          context,
                          disease.key,
                        );

                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (index.isEven) {
                          return isDarkMode
                              ? Colors.grey.shade800.withValues(alpha: 0.3)
                              : Colors.grey.shade50;
                        }
                        return null;
                      }),
                      cells: [
                        DataCell(
                          Text(
                            localizedName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              count.toString(),
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              '${(avgConfidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: avgConfidence > 0.7
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              '${(minConfidence * 100).toStringAsFixed(0)}% - ${(maxConfidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDailyVolumeChart(
    BuildContext context,
    List<AnalysisModel> analyses,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (analyses.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, int> dailyCounts = {};
    for (var a in analyses) {
      final year = a.timestamp.year;
      final month = a.timestamp.month.toString().padLeft(2, '0');
      final day = a.timestamp.day.toString().padLeft(2, '0');
      final dateKey = '$year-$month-$day';
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }

    final sortedDates = dailyCounts.keys.toList()..sort();
    final showWeekly = sortedDates.length > 14;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dailyVolume,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showWeekly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.week,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: _buildBarGroups(
                    sortedDates,
                    dailyCounts,
                    showWeekly,
                  ),
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedDates.length)
                            return const Text('');
                          final dateStr = sortedDates[value.toInt()];
                          try {
                            final parts = dateStr.split('-');
                            if (parts.length == 3) {
                              final month = int.parse(parts[1]);
                              final day = int.parse(parts[2]);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  showWeekly
                                      ? '${l10n.week} ${((value.toInt() / 7).floor() + 1)}'
                                      : '$day/$month',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                          } catch (e) {
                            return const Text('');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dateStr = sortedDates[group.x.toInt()];
                        try {
                          final parts = dateStr.split('-');
                          if (parts.length == 3) {
                            final year = int.parse(parts[0]);
                            final month = int.parse(parts[1]);
                            final day = int.parse(parts[2]);
                            return BarTooltipItem(
                              '$day/$month/$year\n${rod.toY.toInt()} ${l10n.totalAnalyses.toLowerCase()}',
                              const TextStyle(color: Colors.white),
                            );
                          }
                        } catch (e) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} ${l10n.totalAnalyses.toLowerCase()}',
                            const TextStyle(color: Colors.white),
                          );
                        }
                        return BarTooltipItem(
                          '${rod.toY.toInt()} ${l10n.totalAnalyses.toLowerCase()}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<String> dates,
    Map<String, int> dailyCounts,
    bool showWeekly,
  ) {
    if (showWeekly) {
      final weeklyData = <int, double>{};
      for (int i = 0; i < dates.length; i++) {
        final weekIndex = (i / 7).floor();
        final currentTotal = weeklyData[weekIndex] ?? 0;
        weeklyData[weekIndex] = currentTotal + dailyCounts[dates[i]]!;
      }

      return weeklyData.entries.map((entry) {
        final avg = entry.value / 7.0;
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: avg,
              color: Colors.blue,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }).toList();
    } else {
      return dates.asMap().entries.map((entry) {
        final index = entry.key;
        final date = entry.value;
        final count = dailyCounts[date] ?? 0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blue,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }).toList();
    }
  }

  Widget _buildConfidenceTrend(
    BuildContext context,
    List<AnalysisModel> analyses,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (analyses.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, List<double>> dailyConfidence = {};
    for (var a in analyses) {
      final year = a.timestamp.year;
      final month = a.timestamp.month.toString().padLeft(2, '0');
      final day = a.timestamp.day.toString().padLeft(2, '0');
      final dateKey = '$year-$month-$day';
      dailyConfidence.putIfAbsent(dateKey, () => []);
      dailyConfidence[dateKey]!.add(a.confidence);
    }

    final dailyAverages = <String, double>{};
    for (var entry in dailyConfidence.entries) {
      dailyAverages[entry.key] =
          entry.value.fold(0.0, (sum, c) => sum + c) / entry.value.length;
    }

    final sortedDates = dailyAverages.keys.toList()..sort();

    if (sortedDates.length < 2) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.confidenceTrend,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedDates.asMap().entries.map((entry) {
                        final index = entry.key;
                        final date = entry.value;
                        return FlSpot(
                          index.toDouble(),
                          dailyAverages[date]! * 100,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedDates.length)
                            return const Text('');
                          final dateStr = sortedDates[value.toInt()];
                          try {
                            final parts = dateStr.split('-');
                            if (parts.length == 3) {
                              final month = int.parse(parts[1]);
                              final day = int.parse(parts[2]);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '$day/$month',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                          } catch (e) {
                            return const Text('');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final dateStr = sortedDates[spot.x.toInt()];
                          try {
                            final parts = dateStr.split('-');
                            if (parts.length == 3) {
                              final year = int.parse(parts[0]);
                              final month = int.parse(parts[1]);
                              final day = int.parse(parts[2]);
                              return LineTooltipItem(
                                '$day/$month/$year\n${spot.y.toStringAsFixed(1)}%',
                                const TextStyle(color: Colors.white),
                              );
                            }
                          } catch (e) {
                            return LineTooltipItem(
                              '${spot.y.toStringAsFixed(1)}%',
                              const TextStyle(color: Colors.white),
                            );
                          }
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)}%',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
