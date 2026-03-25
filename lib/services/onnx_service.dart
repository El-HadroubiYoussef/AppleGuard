import 'dart:typed_data';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

class OnnxService {
  static final OnnxService _instance = OnnxService._internal();
  factory OnnxService() => _instance;
  OnnxService._internal();

  late OrtSession _session;
  bool _isInitialized = false;
  String? _inputName;

  final List<String> labels = const [
    'Alternaria leaf spot',
    'Brown spot',
    'Gray spot',
    'Healthy leaf',
    'Rust',
  ];

  final List<double> mean = [0.485, 0.456, 0.406];
  final List<double> std = [0.229, 0.224, 0.225];
  final int imageSize = 224;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      OrtEnv.instance.init();
      final ByteData modelData = await rootBundle.load(
        'assets/models/apple_disease_model.onnx',
      );
      final Uint8List modelBytes = modelData.buffer.asUint8List();
      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);
      _inputName = _session.inputNames.first;
      _isInitialized = true;
      print('ONNX Runtime initialized successfully');
      print('Input name: $_inputName');
    } catch (e) {
      print('Error initializing ONNX Runtime: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDetailedStats(File imageFile) async {
    if (!_isInitialized) await initialize();

    final stopwatch = Stopwatch()..start();

    List<OrtValue?>? outputs;
    OrtValue? inputOrt;
    OrtRunOptions? runOptions;

    try {
      final img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) throw Exception('Failed to decode image');
      final Float32List inputTensor = await _preprocessImage(image);
      final inputShape = [1, 3, imageSize, imageSize];
      inputOrt = OrtValueTensor.createTensorWithDataList(
        inputTensor,
        inputShape,
      );
      final inputs = {_inputName!: inputOrt};
      runOptions = OrtRunOptions();
      outputs = await _session.runAsync(runOptions, inputs);
      stopwatch.stop();
      if (outputs == null || outputs.isEmpty || outputs[0] == null) {
        throw Exception('No output from model');
      }
      final outputOrt = outputs[0]!;
      final outputValue = outputOrt.value;
      List<double> logits;
      if (outputValue is List<List<double>>) {
        logits = outputValue[0];
      } else if (outputValue is List<double>) {
        logits = outputValue;
      } else {
        throw Exception('Unexpected output type: ${outputValue.runtimeType}');
      }

      final probs = _softmax(logits);
      final entropy = _calculateEntropy(probs);
      final topIndex = _argMax(probs);
      return {
        'probs': probs,
        'logits': logits,
        'latency': stopwatch.elapsedMilliseconds.toDouble(),
        'entropy': entropy,
        'topIndex': topIndex,
        'disease': labels[topIndex],
        'confidence': probs[topIndex],
      };
    } catch (e) {
      print('Error during inference: $e');
      rethrow;
    } finally {
      inputOrt?.release();
      runOptions?.release();
      outputs?.forEach((element) {
        element?.release();
      });
    }
  }

  Future<Float32List> _preprocessImage(img.Image image) async {
    img.Image resized = img.copyResize(
      image,
      width: imageSize,
      height: imageSize,
      interpolation: img.Interpolation.linear,
    );

    final Float32List inputTensor = Float32List(3 * imageSize * imageSize);

    int index = 0;
    for (int c = 0; c < 3; c++) {
      for (int h = 0; h < imageSize; h++) {
        for (int w = 0; w < imageSize; w++) {
          final pixel = resized.getPixel(w, h);
          double value;
          if (c == 0) {
            value = pixel.r / 255.0;
          } else if (c == 1) {
            value = pixel.g / 255.0;
          } else {
            value = pixel.b / 255.0;
          }

          value = (value - mean[c]) / std[c];
          inputTensor[index++] = value;
        }
      }
    }
    return inputTensor;
  }

  List<double> _softmax(List<double> logits) {
    double maxLogit = logits[0];
    for (int i = 1; i < logits.length; i++) {
      if (logits[i] > maxLogit) maxLogit = logits[i];
    }

    final List<double> expValues = List<double>.generate(
      logits.length,
      (i) => math.exp(logits[i] - maxLogit),
    );

    double sumExp = 0.0;
    for (final val in expValues) {
      sumExp += val;
    }
    return expValues.map((e) => e / sumExp).toList();
  }

  double _calculateEntropy(List<double> probs) {
    double entropy = 0.0;
    const double epsilon = 1e-9;

    for (final p in probs) {
      if (p > epsilon) {
        entropy -= p * math.log(p);
      }
    }
    return entropy;
  }

  int _argMax(List<double> array) {
    int maxIndex = 0;
    double maxValue = array[0];

    for (int i = 1; i < array.length; i++) {
      if (array[i] > maxValue) {
        maxValue = array[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  void dispose() {
    if (_isInitialized) {
      _session.release();
      OrtEnv.instance.release();
    }
  }
}
