import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


// --- Data Class HealthGoal ---
@immutable
class HealthGoal {
  final String title;
  final double target;
  final int repetition;
  final int daysToAchieve;
  final int daysAchieved;
  final IconData icon;
  final MaterialColor color;
  final GoalCategory category;
  final GoalDuration duration;
  final double currentProgress;

  const HealthGoal({
    required this.title,
    required this.target,
    required this.repetition,
    required this.daysToAchieve,
    required this.daysAchieved,
    required this.icon,
    required this.color,
    required this.category,
    required this.duration,
    required this.currentProgress,
  });

  HealthGoal copyWith({
    String? title,
    double? target,
    int? repetition,
    int? daysToAchieve,
    int? daysAchieved,
    IconData? icon,
    MaterialColor? color,
    GoalCategory? category,
    GoalDuration? duration,
    double? currentProgress,
  }) {
    return HealthGoal(
      title: title ?? this.title,
      target: target ?? this.target,
      repetition: repetition ?? this.repetition,
      daysToAchieve: daysToAchieve ?? this.daysToAchieve,
      daysAchieved: daysAchieved ?? this.daysAchieved,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HealthGoal &&
              runtimeType == other.runtimeType &&
              title == other.title &&
              target == other.target &&
              repetition == other.repetition &&
              daysToAchieve == other.daysToAchieve &&
              daysAchieved == other.daysAchieved &&
              category == other.category &&
              duration == other.duration &&
              currentProgress == other.currentProgress;

  @override
  int get hashCode =>
      title.hashCode ^
      target.hashCode ^
      repetition.hashCode ^
      daysToAchieve.hashCode ^
      daysAchieved.hashCode ^
      category.hashCode ^
      duration.hashCode ^
      currentProgress.hashCode;
}


enum GoalCategory {
  heartRate,
  bloodPressure,
  caloriesBurned,
  distanceCovered,
  steps,
  activeMinutes,
  sleepHours,
  hydration,
  weight,
  goalWeightLoss;

  String get displayName {
    switch (this) {
      case GoalCategory.heartRate: return 'Heart Rate';
      case GoalCategory.bloodPressure: return 'Blood Pressure';
      case GoalCategory.caloriesBurned: return 'Calories Burned';
      case GoalCategory.distanceCovered: return 'Distance Covered';
      case GoalCategory.steps: return 'Steps';
      case GoalCategory.activeMinutes: return 'Active Minutes';
      case GoalCategory.weight: return 'Weight';
      case GoalCategory.goalWeightLoss: return 'Goal Weight Loss';
      case GoalCategory.sleepHours: return 'Sleep Hours';
      case GoalCategory.hydration: return 'Hydration';
    }
  }

  static GoalCategory fromString(String value) {
    return GoalCategory.values.firstWhere(
          (element) => element.toString().split('.').last == value,
      orElse: () => GoalCategory.steps,
    );
  }
}

enum GoalDuration {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case GoalDuration.daily: return 'Daily';
      case GoalDuration.weekly: return 'Weekly';
      case GoalDuration.monthly: return 'Monthly';
    }
  }

  static GoalDuration fromString(String value) {
    return GoalDuration.values.firstWhere(
          (element) => element.toString().split('.').last == value,
      orElse: () => GoalDuration.daily,
    );
  }
}

class HealthGoalModel {
  final String? id;
  final String title;
  final double target;
  final int repetition;
  final int daysToAchieve;
  final int daysAchieved;
  final GoalCategory category;
  final GoalDuration duration;
  final double currentProgress;
  final Timestamp createdAt;
  final Timestamp? lastUpdatedAt;
  final String userId;

  HealthGoalModel({
    this.id,
    required this.title,
    required this.target,
    required this.repetition,
    required this.daysToAchieve,
    required this.daysAchieved,
    required this.category,
    required this.duration,
    required this.currentProgress,
    required this.createdAt,
    this.lastUpdatedAt,
    required this.userId,
  });

  // Helper method to get icon based on category
  IconData get icon {
    switch (category) {
      case GoalCategory.heartRate: return Iconsax.heart;
      case GoalCategory.bloodPressure: return Iconsax.heart_circle;
      case GoalCategory.caloriesBurned: return Iconsax.flash_1;
      case GoalCategory.distanceCovered: return Iconsax.location;
      case GoalCategory.steps: return Iconsax.activity;
      case GoalCategory.activeMinutes: return Iconsax.timer_1;
      case GoalCategory.sleepHours: return Iconsax.moon;
      case GoalCategory.hydration: return Iconsax.cup;
      default: return Iconsax.task_square;
    }
  }

  // Helper method to get color based on category
  MaterialColor get color {
    switch (category) {
      case GoalCategory.heartRate: return Colors.red;
      case GoalCategory.bloodPressure: return Colors.pink;
      case GoalCategory.caloriesBurned: return Colors.orange;
      case GoalCategory.distanceCovered: return Colors.green;
      case GoalCategory.steps: return Colors.blue;
      case GoalCategory.activeMinutes: return Colors.cyan;
      case GoalCategory.sleepHours: return Colors.purple;
      case GoalCategory.hydration: return Colors.teal;
      default: return Colors.grey;
    }
  }

  // Convert to HealthGoal UI object
  HealthGoal toHealthGoal() {
    return HealthGoal(
      title: title,
      target: target,
      repetition: repetition,
      daysToAchieve: daysToAchieve,
      daysAchieved: daysAchieved,
      icon: icon,
      color: color,
      category: category,
      duration: duration,
      currentProgress: currentProgress,
    );
  }

  // From HealthGoal UI object and user ID
  factory HealthGoalModel.fromHealthGoal(HealthGoal goal, String userId) {
    return HealthGoalModel(
      title: goal.title,
      target: goal.target,
      repetition: goal.repetition,
      daysToAchieve: goal.daysToAchieve,
      daysAchieved: goal.daysAchieved,
      category: goal.category,
      duration: goal.duration,
      currentProgress: goal.currentProgress,
      createdAt: Timestamp.now(),
      userId: userId,
    );
  }

  // Create model from Firestore document
  factory HealthGoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HealthGoalModel(
      id: doc.id,
      title: data['title'] ?? '',
      target: (data['target'] as num).toDouble(),
      repetition: data['repetition'] ?? 1,
      daysToAchieve: data['daysToAchieve'] ?? 30,
      daysAchieved: data['daysAchieved'] ?? 0,
      category: GoalCategory.fromString(data['category']),
      duration: GoalDuration.fromString(data['duration']),
      currentProgress: (data['currentProgress'] as num).toDouble(),
      createdAt: data['createdAt'] as Timestamp,
      lastUpdatedAt: data['lastUpdatedAt'] as Timestamp?,
      userId: data['userId'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'target': target,
      'repetition': repetition,
      'daysToAchieve': daysToAchieve,
      'daysAchieved': daysAchieved,
      'category': category.toString().split('.').last,
      'duration': duration.toString().split('.').last,
      'currentProgress': currentProgress,
      'createdAt': createdAt,
      'lastUpdatedAt': Timestamp.now(),
      'userId': userId,
    };
  }

  // Create a copy with updated fields
  HealthGoalModel copyWith({
    String? id,
    String? title,
    double? target,
    int? repetition,
    int? daysToAchieve,
    int? daysAchieved,
    GoalCategory? category,
    GoalDuration? duration,
    double? currentProgress,
    Timestamp? createdAt,
    Timestamp? lastUpdatedAt,
    String? userId,
  }) {
    return HealthGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      target: target ?? this.target,
      repetition: repetition ?? this.repetition,
      daysToAchieve: daysToAchieve ?? this.daysToAchieve,
      daysAchieved: daysAchieved ?? this.daysAchieved,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      currentProgress: currentProgress ?? this.currentProgress,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      userId: userId ?? this.userId,
    );
  }
}
