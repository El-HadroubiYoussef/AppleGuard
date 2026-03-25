import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LocalizationHelper {
  static const Map<String, String> _diseaseKeyMap = {
    'Alternaria leaf spot': 'alternariaLeafSpot',
    'Brown spot': 'brownSpot',
    'Gray spot': 'graySpot',
    'Healthy leaf': 'healthyLeaf',
    'Rust': 'rust',
    'Apple scab': 'appleScab',
    'Fire blight': 'fireBlight',
  };

  static String getLocalizedDiseaseName(
    BuildContext context,
    String diseaseName,
  ) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return diseaseName;

    final key = _diseaseKeyMap[diseaseName];
    if (key == null) return diseaseName;

    switch (key) {
      case 'alternariaLeafSpot':
        return l10n.alternariaLeafSpot;
      case 'brownSpot':
        return l10n.brownSpot;
      case 'graySpot':
        return l10n.graySpot;
      case 'healthyLeaf':
        return l10n.healthyLeaf;
      case 'rust':
        return l10n.rust;
      case 'appleScab':
        return l10n.appleScab;
      case 'fireBlight':
        return l10n.fireBlight;
      default:
        return diseaseName;
    }
  }

  static String getLocalizedConfidenceLevel(
    BuildContext context,
    double confidence,
  ) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null)
      return confidence > 0.7 ? 'High' : (confidence > 0.4 ? 'Medium' : 'Low');

    if (confidence > 0.7) return l10n.highConfidence;
    if (confidence > 0.4) return l10n.mediumConfidence;
    return l10n.lowConfidence;
  }
}
