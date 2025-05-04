import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../GoalReminders/data/HealthGoalModel.dart';
import '../../HealthDataInput/data/health_data_model.dart';

part 'health_data_analysis_state.dart';

class HealthDataAnalysisCubit extends Cubit<HealthDataAnalysisState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HealthDataAnalysisCubit() : super(HealthDataAnalysisInitial());

  String? get _userId => _auth.currentUser?.uid;

  Future<void> analyzeHealthData({
    List<String> metrics = const [
      'caloriesBurned',
      'activeMinutes',
      'heartRate',
      'hydration',
      'weight',
      'sleepHours',
      'steps',
      'distance'
    ],
  }) async {
    try {
      emit(HealthDataAnalysisLoading());

      final result = await analyzeHealthHistory(metrics: metrics);

      if (result['status'] == 'success') {
        emit(HealthDataAnalysisSuccess(result['analysis']));
      } else if (result['status'] == 'empty') {
        emit(HealthDataAnalysisEmpty(result['message']));
      } else {
        emit(HealthDataAnalysisFailure(result['message']));
      }
    } catch (e) {
      emit(HealthDataAnalysisFailure('Failed to analyze health data: ${e.toString()}'));
    }
  }

  Future<Map<String, dynamic>> analyzeHealthHistory({
    List<String> metrics = const [
      'caloriesBurned',
      'activeMinutes',
      'heartRate',
      'hydration',
      'weight',
      'sleepHours',
      'steps',
      'distance'
    ],
  }) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Query history collection
      final querySnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'status': 'empty',
          'message': 'No health data found in history'
        };
      }

      final List<HealthDataModel> historyData = querySnapshot.docs
          .map((doc) => HealthDataModel.fromMap(doc.data(), doc.id))
          .toList();

      // Initialize result map
      Map<String, dynamic> analysis = {
        'dataPoints': historyData.length,
        'period': {
          'start': historyData.last.timestamp,
          'end': historyData.first.timestamp,
        },
        'metrics': <String, Map<String, dynamic>>{},
        'trends': <String, String>{},
        'goalProgress': <String, Map<String, dynamic>>{},
        'hasDataForMetric': <String, bool>{},  // Track which metrics have data
      };

      // Calculate statistics for each requested metric
      for (final metric in metrics) {
        // Skip metrics that don't exist in the model
        if (!_isValidMetric(metric)) {
          analysis['hasDataForMetric'][metric] = false;
          continue;
        }

        // Extract values for this metric
        List<num> values = _extractMetricValues(historyData, metric);

        if (values.isEmpty || values.every((v) => v == 0)) {
          analysis['hasDataForMetric'][metric] = false;
          continue;
        }

        // Mark that this metric has data
        analysis['hasDataForMetric'][metric] = true;

        // Calculate statistics
        num min = values.reduce((a, b) => a < b ? a : b);
        num max = values.reduce((a, b) => a > b ? a : b);
        double avg = values.reduce((a, b) => a + b) / values.length;

        // Calculate trend (simple linear trend)
        String trend = _calculateTrend(historyData, metric);

        // Add to analysis
        analysis['metrics'][metric] = {
          'min': min,
          'max': max,
          'average': avg,
          'current': values.first,
          'change': values.length > 1 ? values.first - values.last : 0,
          'changePercentage': values.length > 1 && values.last != 0
              ? ((values.first - values.last) / values.last * 100).toStringAsFixed(1) + '%'
              : '0%',
        };

        analysis['trends'][metric] = trend;

        // Calculate goal progress if applicable
        GoalCategory? category = _metricToGoalCategory(metric);
        if (category != null) {
          // Get goal target from Firestore for this category
          double? target = await _getGoalTarget(userId, category);
          if (target != null) {
            double current = values.first.toDouble();
            double progressPercentage = (current / target * 100).clamp(0, 100);

            analysis['goalProgress'][metric] = {
              'target': target,
              'current': current,
              'percentage': progressPercentage,
              'remaining': target > current ? target - current : 0,
            };
          }
        }
      }

      // Check if we have any data for any metric
      bool hasAnyData = analysis['hasDataForMetric'].values.any((hasData) => hasData == true);
      if (!hasAnyData) {
        return {
          'status': 'empty',
          'message': 'No health data available for selected metrics'
        };
      }

      return {
        'status': 'success',
        'analysis': analysis,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to analyze health data: ${e.toString()}'
      };
    }
  }

  // Helper method to get goal target from Firestore
  Future<double?> _getGoalTarget(String userId, GoalCategory category) async {
    try {
      final querySnapshot = await _firestore
          .collection('health_goals')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final goalDoc = querySnapshot.docs.first;
        final goal = HealthGoalModel.fromFirestore(goalDoc);
        return goal.target;
      }
      return null;
    } catch (e) {
      print('Error fetching goal target: $e');
      return null;
    }
  }

  // Helper method to check if metric exists in the model
  bool _isValidMetric(String metric) {
    final validMetrics = [
      'caloriesBurned',
      'activeMinutes',
      'heartRate',
      'hydration',
      'weight',
      'goalWeightLoss',
      'sleepHours',
      'steps',
      'distance'
    ];
    return validMetrics.contains(metric);
  }

  // Helper method to extract metric values from history data
  List<num> _extractMetricValues(List<HealthDataModel> data, String metric) {
    return data.map((entry) {
      switch (metric) {
        case 'caloriesBurned': return entry.caloriesBurned;
        case 'activeMinutes': return entry.activeMinutes;
        case 'heartRate': return entry.heartRate;
        case 'hydration': return entry.hydration;
        case 'weight': return entry.weight;
        case 'goalWeightLoss': return entry.goalWeightLoss;
        case 'sleepHours': return entry.sleepHours;
        case 'steps': return entry.steps;
        case 'distance': return entry.distance;
        default: return 0;
      }
    }).toList();
  }

  // Helper method to calculate trend
  String _calculateTrend(List<HealthDataModel> data, String metric) {
    if (data.length < 2) return 'stable';

    final values = _extractMetricValues(data, metric);

    // Simple trend calculation
    if (values.first > values.last) {
      return 'increasing';
    } else if (values.first < values.last) {
      return 'decreasing';
    } else {
      return 'stable';
    }
  }

  // Helper method to map metric name to goal category
  GoalCategory? _metricToGoalCategory(String metric) {
    switch (metric) {
      case 'caloriesBurned': return GoalCategory.caloriesBurned;
      case 'activeMinutes': return GoalCategory.activeMinutes;
      case 'hydration': return GoalCategory.hydration;
      case 'weight': return GoalCategory.weight;
      case 'sleepHours': return GoalCategory.sleepHours;
      case 'steps': return GoalCategory.steps;
      case 'distance': return GoalCategory.distanceCovered;
      default: return null;
    }
  }
}