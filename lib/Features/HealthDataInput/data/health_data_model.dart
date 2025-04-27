class HealthDataModel {
  final String? id;
  final double caloriesBurned;
  final int activeMinutes;
  final int heartRate;
  final double hydration;
  final double weight;
  final double goalWeightLoss;
  final double sleepHours;
  final int steps;
  final double distance;
  final DateTime timestamp;
  final String? userId;

  HealthDataModel({
    this.id,
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.heartRate,
    required this.hydration,
    required this.weight,
    required this.goalWeightLoss,
    required this.sleepHours,
    required this.steps,
    required this.distance,
    DateTime? timestamp,
    this.userId,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert model to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      if (userId != null) 'userId': userId,
      'caloriesBurned': caloriesBurned,
      'activeMinutes': activeMinutes,
      'heartRate': heartRate,
      'hydration': hydration,
      'weight': weight,
      'goalWeightLoss': goalWeightLoss,
      'sleepHours': sleepHours,
      'steps': steps,
      'distance': distance,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create model from Firebase document
  factory HealthDataModel.fromMap(Map<String, dynamic> map, String docId) {
    return HealthDataModel(
      id: docId,
      userId: map['userId'] as String?,
      caloriesBurned: map['caloriesBurned']?.toDouble() ?? 0.0,
      activeMinutes: map['activeMinutes']?.toInt() ?? 0,
      heartRate: map['heartRate']?.toInt() ?? 72,
      hydration: map['hydration']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 70.0,
      goalWeightLoss: map['goalWeightLoss']?.toDouble() ?? 0.0,
      sleepHours: map['sleepHours']?.toDouble() ?? 8.0,
      steps: map['steps']?.toInt() ?? 0,
      distance: map['distance']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
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
    double? sleepHours,
    int? steps,
    double? distance,
    DateTime? timestamp,
    String? userId,
  }) {
    return HealthDataModel(
      id: id ?? this.id,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      heartRate: heartRate ?? this.heartRate,
      hydration: hydration ?? this.hydration,
      weight: weight ?? this.weight,
      goalWeightLoss: goalWeightLoss ?? this.goalWeightLoss,
      sleepHours: sleepHours ?? this.sleepHours,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }
}