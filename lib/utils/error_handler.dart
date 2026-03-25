import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    final l10n = AppLocalizations.of(context)!;
    final errorMessage = _getUserFriendlyMessage(context, error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.cancel,
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showLoading(BuildContext context, {String? message}) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message ?? l10n.analyzing),
          ],
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  static String _getUserFriendlyMessage(BuildContext context, dynamic error) {
    final l10n = AppLocalizations.of(context)!;
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return l10n.networkError;
    }
    if (errorStr.contains('timeout')) {
      return l10n.somethingWentWrong;
    }
    if (errorStr.contains('api key') || errorStr.contains('permission')) {
      return l10n.invalidApiKey;
    }
    if (errorStr.contains('camera')) {
      return l10n.cameraError;
    }
    if (errorStr.contains('image')) {
      return l10n.imageProcessingError;
    }
    if (errorStr.contains('model')) {
      return l10n.somethingWentWrong;
    }

    return l10n.somethingWentWrong;
  }
}
