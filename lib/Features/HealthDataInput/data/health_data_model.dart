class HealthDataModel {
  final String? id;
  final double caloriesBurned;
  final int activeMinutes;
  final int heartRate;
  final double hydration;
  final double weight;
  final double goalWeightLoss;
  final DateTime timestamp;


  HealthDataModel({
    this.id,
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.heartRate,
    required this.hydration,
    required this.weight,
    required this.goalWeightLoss,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert model to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'caloriesBurned': caloriesBurned,
      'activeMinutes': activeMinutes,
      'heartRate': heartRate,
      'hydration': hydration,
      'weight': weight,
      'goalWeightLoss': goalWeightLoss,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create model from Firebase document
  factory HealthDataModel.fromMap(Map<String, dynamic> map, String docId) {
    return HealthDataModel(
      id: docId,
      caloriesBurned: map['caloriesBurned']?.toDouble() ?? 0.0,
      activeMinutes: map['activeMinutes']?.toInt() ?? 0,
      heartRate: map['heartRate']?.toInt() ?? 0,
      hydration: map['hydration']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      goalWeightLoss: map['goalWeightLoss']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  // Create a copy of this model with the given field values updated
  HealthDataModel copyWith({
    String? id,
    double? caloriesBurned,
    int? activeMinutes,
    int? heartRate,
    double? hydration,
    double? weight,
    double? goalWeightLoss,
    DateTime? timestamp,
  }) {
    return HealthDataModel(
      id: id ?? this.id,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      heartRate: heartRate ?? this.heartRate,
      hydration: hydration ?? this.hydration,
      weight: weight ?? this.weight,
      goalWeightLoss: goalWeightLoss ?? this.goalWeightLoss,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}