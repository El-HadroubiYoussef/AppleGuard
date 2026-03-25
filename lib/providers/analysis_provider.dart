import 'dart:io';
import 'package:flutter/material.dart';
import '../models/analysis_model.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import '../services/image_picker_service.dart';
import '../services/onnx_service.dart';
import '../utils/localization_helper.dart';

class AnalysisProvider extends ChangeNotifier {
  List<AnalysisModel> _analyses = [];
  bool _isAnalyzing = false;
  AnalysisModel? _currentAnalysis;
  bool _isDisposed = false;

  List<AnalysisModel> get analyses => _analyses;
  bool get isAnalyzing => _isAnalyzing;
  AnalysisModel? get currentAnalysis => _currentAnalysis;

  final DatabaseService _db = DatabaseService();
  final AIService _ai = AIService();
  final ImagePickerService _picker = ImagePickerService();
  final OnnxService _onnx = OnnxService();

  BuildContext? _uiContext;

  AnalysisProvider() {
    loadHistory();
    _initializeOnnx();
  }

  Future<void> _initializeOnnx() async {
    try {
      await _onnx.initialize();
      print('✅ ONNX initialized in provider');
    } catch (e) {
      print('Failed to initialize ONNX: $e');
    }
  }

  void setContext(BuildContext context) {
    _uiContext = context;
  }

  Future<void> deleteAnalysis(int id) async {
    final analysis = _analyses.firstWhere((a) => a.id == id);

    try {
      final imageFile = File(analysis.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }

    await _db.deleteAnalysis(id);
    _analyses.removeWhere((a) => a.id == id);

    if (_currentAnalysis?.id == id) {
      _currentAnalysis = null;
    }

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    _analyses = await _db.getAnalyses();
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> analyzeFromCamera(BuildContext context) async {
    if (_isDisposed) return;

    _uiContext = context;
    _isAnalyzing = true;
    _currentAnalysis = null;
    notifyListeners();

    try {
      final imagePath = await _picker.pickFromCamera(context);
      if (imagePath != null && imagePath.isNotEmpty) {
        print('📸 Image picked: $imagePath');
        await _performAnalysis(imagePath);
      } else {
        print('❌ No image picked from camera');
        _isAnalyzing = false;
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    } catch (e) {
      print('Camera analysis error: $e');
      _isAnalyzing = false;
      if (!_isDisposed) {
        notifyListeners();
      }
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> analyzeFromGallery(BuildContext context) async {
    if (_isDisposed) return;

    _uiContext = context;
    _isAnalyzing = true;
    _currentAnalysis = null;
    notifyListeners();

    try {
      final imagePath = await _picker.pickFromGallery();
      if (imagePath != null && imagePath.isNotEmpty) {
        print('🖼️ Image picked: $imagePath');
        await _performAnalysis(imagePath);
      } else {
        print('❌ No image picked from gallery');
        _isAnalyzing = false;
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    } catch (e) {
      print('Gallery analysis error: $e');
      _isAnalyzing = false;
      if (!_isDisposed) {
        notifyListeners();
      }
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _performAnalysis(String imagePath) async {
    try {
      print('🔍 Starting analysis for: $imagePath');

      final prediction = await _onnx.getDetailedStats(File(imagePath));
      final diseaseKey = prediction['disease'];

      print(
        '✅ ONNX prediction complete: ${prediction['disease']} with confidence ${prediction['confidence']}',
      );

      final probsList = (prediction['probs'] as List<double>)
          .asMap()
          .entries
          .map(
            (e) => {
              'label': _onnx.labels[e.key],
              'probability': e.value,
              'logit': (prediction['logits'] as List<double>)[e.key],
            },
          )
          .toList();

      final BuildContext? savedContext = _uiContext;
      final bool hasValidContext = savedContext != null && savedContext.mounted;

      String localizedDiseaseName = diseaseKey;
      if (hasValidContext) {
        localizedDiseaseName = LocalizationHelper.getLocalizedDiseaseName(
          savedContext,
          diseaseKey,
        );
        print(
          '📝 Localized: ${prediction['disease']} -> $localizedDiseaseName',
        );
      } else {
        print('⚠️ No valid context for localization, using raw disease name');
      }

      String aiFeedback;
      try {
        if (hasValidContext) {
          if (savedContext.mounted) {
            aiFeedback = await _ai.getDiseaseFeedback(
              context: savedContext,
              diseaseName: diseaseKey,
              confidence: prediction['confidence'],
              imagePath: imagePath,
              probsList: probsList,
              latency: prediction['latency'],
              entropy: prediction['entropy'],
            );
            print('✅ AI feedback received');
          } else {
            print('⚠️ Context became unmounted before AI call');
            aiFeedback = _getDefaultFeedback(
              localizedDiseaseName,
              prediction['confidence'],
            );
          }
        } else {
          print('⚠️ No valid context for AI, using default feedback');
          aiFeedback = _getDefaultFeedback(
            localizedDiseaseName,
            prediction['confidence'],
          );
        }
      } catch (e) {
        print('⚠️ AI feedback failed, using default: $e');
        aiFeedback = _getDefaultFeedback(
          localizedDiseaseName,
          prediction['confidence'],
        );
      }

      final analysis = AnalysisModel(
        id: DateTime.now().millisecondsSinceEpoch,
        imagePath: imagePath,
        diseaseKey: diseaseKey,
        diseaseName: localizedDiseaseName,
        confidence: prediction['confidence'],
        aiFeedback: aiFeedback,
        timestamp: DateTime.now(),
        rawPrediction: {
          'probs': probsList,
          'logits': prediction['logits'],
          'latency': prediction['latency'],
          'entropy': prediction['entropy'],
        },
      );

      await _db.insertAnalysis(analysis);
      _analyses.insert(0, analysis);
      _currentAnalysis = analysis;
      _isAnalyzing = false;

      if (!_isDisposed) {
        notifyListeners();
        if (hasValidContext && savedContext.mounted) {
          _showSuccess('Analysis complete!');
        }
      }

      print(
        '✅ Analysis complete and saved with localized name: $localizedDiseaseName',
      );
    } catch (e) {
      print('❌ Analysis failed: $e');
      _isAnalyzing = false;
      if (!_isDisposed) {
        notifyListeners();
      }
      if (_uiContext != null && _uiContext!.mounted) {
        _showError('Analysis failed: $e');
      }
      rethrow;
    }
  }

  String _getDefaultFeedback(String diseaseName, double confidence) {
    final confidencePercent = (confidence * 100).toStringAsFixed(1);
    return '''
## 🌿 Local Analysis Complete

**Detected Disease:** $diseaseName  
**Confidence:** $confidencePercent%

### 📋 Basic Recommendations:
- Remove and dispose of affected leaves
- Ensure good air circulation around trees
- Monitor other trees for symptoms

### 🛡️ Prevention Tips:
- Practice good orchard sanitation
- Avoid overhead watering
- Apply preventative treatments in early spring

---
📱 **For detailed AI advice**  
Please configure your API key in Settings → AI Configuration to get personalized treatment plans.
''';
  }

  void _showError(String message) {
    if (_uiContext != null && _uiContext!.mounted) {
      ScaffoldMessenger.of(_uiContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      print('❌ Error (no context): $message');
    }
  }

  void _showSuccess(String message) {
    if (_uiContext != null && _uiContext!.mounted) {
      ScaffoldMessenger.of(_uiContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      print('✅ Success (no context): $message');
    }
  }

  void clearCurrentAnalysis() {
    if (_isDisposed) return;
    _currentAnalysis = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _onnx.dispose();
    super.dispose();
  }
}
