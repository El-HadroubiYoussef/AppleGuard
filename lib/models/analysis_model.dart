class AnalysisModel {
  final int id;
  final String imagePath;
  final String diseaseKey;
  final String diseaseName;
  final double confidence;
  final String aiFeedback;
  final DateTime timestamp;
  final Map<String, dynamic>? rawPrediction;

  AnalysisModel({
    required this.id,
    required this.imagePath,
    required this.diseaseKey,
    required this.diseaseName,
    required this.confidence,
    required this.aiFeedback,
    required this.timestamp,
    this.rawPrediction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'diseaseKey': diseaseKey,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'aiFeedback': aiFeedback,
      'timestamp': timestamp.toIso8601String(),
      'rawPrediction': rawPrediction?.toString(),
    };
  }

  factory AnalysisModel.fromMap(Map<String, dynamic> map) {
    return AnalysisModel(
      id: map['id'],
      imagePath: map['imagePath'],
      diseaseKey: map['diseaseKey'] ?? map['diseaseName'],
      diseaseName: map['diseaseName'],
      confidence: map['confidence'],
      aiFeedback: map['aiFeedback'],
      timestamp: DateTime.parse(map['timestamp']),
      rawPrediction: null,
    );
  }
}
