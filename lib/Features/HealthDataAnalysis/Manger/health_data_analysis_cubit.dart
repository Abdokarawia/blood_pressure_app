import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../GoalReminders/data/HealthGoalModel.dart';
import 'package:intl/intl.dart';

import '../../HealthDataInput/data/health_data_model.dart';
import 'health_data_analysis_state.dart';

class HealthAnalysisCubit extends Cubit<HealthAnalysisState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache for analyzed data
  Map<String, dynamic> _analysisCache = {};

  // Metric options for analysis
  static const List<String> metricOptions = [
    'Calories Burned',
    'Active Minutes',
    'Heart Rate',
    'Hydration',
    'Weight',
    'Sleep Hours',
    'Steps',
    'Distance'
  ];

  // Maps metrics to their database field names
  static const Map<String, String> metricToField = {
    'Calories Burned': 'caloriesBurned',
    'Active Minutes': 'activeMinutes',
    'Heart Rate': 'heartRate',
    'Hydration': 'hydration',
    'Weight': 'weight',
    'Sleep Hours': 'sleepHours',
    'Steps': 'steps',
    'Distance': 'distance',
  };

  // Define units for each metric for display
  static const Map<String, String> metricUnits = {
    'Calories Burned': 'kcal',
    'Active Minutes': 'min',
    'Heart Rate': 'bpm',
    'Hydration': 'L',
    'Weight': 'kg',
    'Sleep Hours': 'hrs',
    'Steps': 'steps',
    'Distance': 'km',
  };

  HealthAnalysisCubit() : super(HealthAnalysisInitial());

  String? get _userId => _auth.currentUser?.uid;

  // Format a DateTime to a consistent string key for daily data storage
  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Load this week's health data for analysis
  Future<void> loadThisWeekData() async {
    try {
      emit(HealthAnalysisLoading());

      final userId = _userId;
      if (userId == null) {
        emit(HealthAnalysisError('User not authenticated'));
        return;
      }

      // Get the current week's data
      final weekData = await _getThisWeekData();

      // Process the data for analysis
      final weeklyAnalysis = _processWeeklyData(weekData);

      emit(HealthAnalysisLoaded(weeklyAnalysis));
    } catch (e) {
      emit(HealthAnalysisError('Failed to load weekly analysis: ${e.toString()}'));
    }
  }

  // Get health data for the current week
  Future<List<HealthDataModel>> _getThisWeekData() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Simply get the last 7 days of data
      final querySnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('dailyData')
          .limit(7)
          .get();

      return querySnapshot.docs
          .map((doc) => HealthDataModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get this week\'s health data: $e');
    }
  }

  // Get health data for specific day
  Future<HealthDataModel?> getHealthDataForDay(String dateKey) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final docSnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('dailyData')
          .doc(dateKey)
          .get();

      if (docSnapshot.exists) {
        return HealthDataModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get health data for day: $e');
    }
  }

  // Process weekly data for analysis
  Map<String, dynamic> _processWeeklyData(List<HealthDataModel> weekData) {
    // Create a map to store analysis results
    Map<String, dynamic> analysis = {
      'dailyData': <String, Map<String, dynamic>>{},
      'averages': <String, double>{},
      'totals': <String, double>{},
      'maxValues': <String, double>{},
      'minValues': <String, double>{},
      'weeklyGoalProgress': <String, double>{},
      'chartData': <String, List<dynamic>>{},
    };

    // Initialize totals and averages
    for (final metric in metricOptions) {
      final field = metricToField[metric]!;
      analysis['totals'][field] = 0.0;
      analysis['averages'][field] = 0.0;
      analysis['maxValues'][field] = double.negativeInfinity;
      analysis['minValues'][field] = double.infinity;
      analysis['chartData'][field] = <Map<String, dynamic>>[];
    }

    // Process each day's data
    for (final dayData in weekData) {
      final dateKey = _formatDateKey(dayData.timestamp);

      // Store daily data
      analysis['dailyData'][dateKey] = {
        'caloriesBurned': dayData.caloriesBurned,
        'activeMinutes': dayData.activeMinutes.toDouble(),
        'heartRate': dayData.heartRate.toDouble(),
        'hydration': dayData.hydration,
        'weight': dayData.weight,
        'sleepHours': dayData.sleepHours,
        'steps': dayData.steps.toDouble(),
        'distance': dayData.distance,
        'date': dateKey,
      };

      // Update totals, max/min values, and chart data
      for (final metric in metricOptions) {
        final field = metricToField[metric]!;
        final value = _getValueByField(dayData, field);

        // Update total
        analysis['totals'][field] = (analysis['totals'][field] ?? 0) + value;

        // Update max/min
        if (value > (analysis['maxValues'][field] ?? double.negativeInfinity)) {
          analysis['maxValues'][field] = value;
        }
        if (value < (analysis['minValues'][field] ?? double.infinity) && value > 0) {
          analysis['minValues'][field] = value;
        }

        // Add to chart data - Fix: Ensure we're adding a map and properly casting
        (analysis['chartData'][field] as List).add({
          'date': dateKey,
          'value': value,
        });
      }
    }

    // Calculate averages
    if (weekData.isNotEmpty) {
      for (final metric in metricOptions) {
        final field = metricToField[metric]!;
        analysis['averages'][field] = analysis['totals'][field] / weekData.length;
      }
    }

    // Store in cache
    _analysisCache['weeklyAnalysis'] = analysis;

    return analysis;
  }

  // Helper to get value from a health data model by field name
  double _getValueByField(HealthDataModel data, String field) {
    switch (field) {
      case 'caloriesBurned':
        return data.caloriesBurned;
      case 'activeMinutes':
        return data.activeMinutes.toDouble();
      case 'heartRate':
        return data.heartRate.toDouble();
      case 'hydration':
        return data.hydration;
      case 'weight':
        return data.weight;
      case 'sleepHours':
        return data.sleepHours;
      case 'steps':
        return data.steps.toDouble();
      case 'distance':
        return data.distance;
      default:
        return 0.0;
    }
  }

  // Calculate progress towards goals
  Future<Map<String, double>> calculateGoalProgress() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get current goals
      final goalSnapshot = await _firestore
          .collection('health_goals')
          .where('userId', isEqualTo: userId)
          .get();

      final goals = goalSnapshot.docs
          .map((doc) => HealthGoalModel.fromFirestore(doc))
          .toList();

      // Get current week's analysis
      Map<String, dynamic> analysis = _analysisCache['weeklyAnalysis'] ?? {};
      if (analysis.isEmpty) {
        await loadThisWeekData();
        analysis = _analysisCache['weeklyAnalysis'] ?? {};
      }

      // Calculate progress for each goal
      Map<String, double> progress = {};

      for (final goal in goals) {
        final category = goal.category;
        final target = goal.target;

        // Get the relevant metric field for the goal category
        String? field;
        switch (category) {
          case GoalCategory.steps:
            field = 'steps';
            break;
          case GoalCategory.distanceCovered:
            field = 'distance';
            break;
          case GoalCategory.activeMinutes:
            field = 'activeMinutes';
            break;
          case GoalCategory.caloriesBurned:
            field = 'caloriesBurned';
            break;
          case GoalCategory.weight:
            field = 'weight';
            break;
          case GoalCategory.sleepHours:
            field = 'sleepHours';
            break;
          case GoalCategory.hydration:
            field = 'hydration';
            break;
          default:
            continue;
        }

        // Calculate progress as percentage of target
        double value = analysis['totals']?[field] ?? 0.0;
        double progressValue = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;

        progress[field] = progressValue;
      }

      return progress;
    } catch (e) {
      throw Exception('Failed to calculate goal progress: $e');
    }
  }

  // Get recommendations based on current health data
  List<String> getRecommendations() {
    List<String> recommendations = [];

    final analysis = _analysisCache['weeklyAnalysis'];
    if (analysis == null) return recommendations;

    // Steps recommendation
    final avgSteps = analysis['averages']['steps'] ?? 0.0;
    if (avgSteps < 5000) {
      recommendations.add('Try to increase your daily steps to at least 5,000 steps per day.');
    } else if (avgSteps < 10000) {
      recommendations.add('You\'re on the right track with steps! Aim for 10,000 steps daily for optimal health.');
    }

    // Sleep recommendation
    final avgSleep = analysis['averages']['sleepHours'] ?? 0.0;
    if (avgSleep < 6) {
      recommendations.add('You\'re getting less than 6 hours of sleep on average. Try to get 7-9 hours for better health.');
    } else if (avgSleep > 9) {
      recommendations.add('You\'re sleeping more than 9 hours on average. While rest is important, too much sleep can be associated with health issues.');
    }

    // Hydration recommendation
    final avgHydration = analysis['averages']['hydration'] ?? 0.0;
    if (avgHydration < 2.0) {
      recommendations.add('Try to drink more water! Aim for at least 2 liters daily.');
    }

    // Active minutes recommendation
    final avgActiveMinutes = analysis['averages']['activeMinutes'] ?? 0.0;
    if (avgActiveMinutes < 30) {
      recommendations.add('Aim for at least 30 minutes of physical activity each day.');
    }

    return recommendations;
  }

  // Get a summary of the week's health data
  String getWeeklySummary() {
    final analysis = _analysisCache['weeklyAnalysis'];
    if (analysis == null) return 'No data available for this week.';

    final totalSteps = analysis['totals']['steps'] ?? 0.0;
    final totalCalories = analysis['totals']['caloriesBurned'] ?? 0.0;
    final totalDistance = analysis['totals']['distance'] ?? 0.0;
    final avgSleep = analysis['averages']['sleepHours'] ?? 0.0;

    return 'This week, you took ${totalSteps.toInt()} steps, burned ${totalCalories.toInt()} calories, '
        'traveled ${totalDistance.toStringAsFixed(2)} km, and averaged ${avgSleep.toStringAsFixed(1)} hours of sleep per night.';
  }

  // Get data formatted for charts
  List<Map<String, dynamic>> getChartData(String metric) {
    final analysis = _analysisCache['weeklyAnalysis'];
    if (analysis == null) return [];

    final field = metricToField[metric] ?? metric;

    // Fix: Handle the type casting appropriately
    List<dynamic> rawData = analysis['chartData'][field] ?? [];
    return rawData.map((item) => item as Map<String, dynamic>).toList();
  }

  // Clear the analysis cache
  void clearCache() {
    _analysisCache.clear();
    emit(HealthAnalysisInitial());
  }
}