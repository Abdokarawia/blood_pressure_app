import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../GoalReminders/data/HealthGoalModel.dart';
import '../data/health_data_model.dart';
import 'health_records_state.dart';
import 'package:intl/intl.dart';

class HealthDataCubit extends Cubit<HealthDataState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Map to store goals by category for quick access
  Map<GoalCategory, double> _goalTargets = {};

  // Cache for daily data to minimize Firebase reads
  Map<String, HealthDataModel> _dailyDataCache = {};

  // Text controllers for all form fields
  final TextEditingController caloriesBurnedController = TextEditingController();
  final TextEditingController activeMinutesController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController hydrationController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController goalWeightLossController = TextEditingController();
  final TextEditingController sleepHoursController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();

  // Default values for all metrics
  final Map<String, double> _defaults = {
    'Calories Burned': 0,
    'Active Minutes': 0,
    'Heart Rate': 0,
    'Hydration': 0,
    'Weight': 0,
    'Goal Weight Loss': 0,
    'Sleep Hours': 0,
    'Steps': 0,
    'Distance': 0,
  };

  // Getter to access goal targets
  Map<GoalCategory, double> get goalTargets => _goalTargets;

  HealthDataCubit() : super(HealthDataInitial()) {
    _initializeControllers();
  }

  void _initializeControllers() {
    caloriesBurnedController.text = _defaults['Calories Burned']!.toInt().toString();
    activeMinutesController.text = _defaults['Active Minutes']!.toInt().toString();
    heartRateController.text = _defaults['Heart Rate']!.toInt().toString();
    hydrationController.text = _defaults['Hydration']!.toStringAsFixed(1);
    weightController.text = _defaults['Weight']!.toStringAsFixed(1);
    goalWeightLossController.text = _defaults['Goal Weight Loss']!.toStringAsFixed(1);
    sleepHoursController.text = _defaults['Sleep Hours']!.toStringAsFixed(1);
    stepsController.text = _defaults['Steps']!.toInt().toString();
    distanceController.text = _defaults['Distance']!.toStringAsFixed(2);
  }

  String? get _userId => _auth.currentUser?.uid;

  // Format a DateTime to a consistent string key for daily data storage
  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Get the formatted string for today
  String get _todayKey => _formatDateKey(DateTime.now());

  Future<void> loadHealthData() async {
    try {
      emit(HealthDataLoading());

      final userId = _userId;
      if (userId == null) {
        emit(HealthDataError('User not authenticated'));
        return;
      }

      // Try to get today's data first
      final todayKey = _todayKey;
      final docSnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('dailyData')
          .doc(todayKey)
          .get();

      if (docSnapshot.exists) {
        final healthData = HealthDataModel.fromMap(
          docSnapshot.data()!,
          docSnapshot.id,
        );

        // Update all text controllers with retrieved data
        caloriesBurnedController.text = healthData.caloriesBurned.toInt().toString();
        activeMinutesController.text = healthData.activeMinutes.toString();
        heartRateController.text = healthData.heartRate.toString();
        hydrationController.text = healthData.hydration.toStringAsFixed(1);
        weightController.text = healthData.weight.toStringAsFixed(1);
        goalWeightLossController.text = healthData.goalWeightLoss.toStringAsFixed(1);
        sleepHoursController.text = healthData.sleepHours.toStringAsFixed(1);
        stepsController.text = healthData.steps.toString();
        distanceController.text = healthData.distance.toStringAsFixed(2);

        // Cache this data
        _dailyDataCache[todayKey] = healthData;

        emit(HealthDataLoaded(healthData));
      } else {
        _initializeControllers();
        emit(HealthDataInitial());
      }

      // Load goals after loading health data
      await loadGoals(_userId);
    } catch (e) {
      emit(HealthDataError('Failed to load health data: ${e.toString()}'));
    }
  }

  Future<void> saveHealthData({DateTime? forDate}) async {
    try {
      emit(HealthDataSaving());

      final userId = _userId;
      if (userId == null) {
        emit(HealthDataError('User not authenticated'));
        return;
      }

      final date = forDate ?? DateTime.now();
      final dateKey = _formatDateKey(date);

      final healthData = HealthDataModel(
        id: userId,
        caloriesBurned: double.tryParse(caloriesBurnedController.text) ?? _defaults['Calories Burned']!,
        activeMinutes: int.tryParse(activeMinutesController.text) ?? _defaults['Active Minutes']!.toInt(),
        heartRate: int.tryParse(heartRateController.text) ?? _defaults['Heart Rate']!.toInt(),
        hydration: double.tryParse(hydrationController.text) ?? _defaults['Hydration']!,
        weight: double.tryParse(weightController.text) ?? _defaults['Weight']!,
        goalWeightLoss: double.tryParse(goalWeightLossController.text) ?? _defaults['Goal Weight Loss']!,
        sleepHours: double.tryParse(sleepHoursController.text) ?? _defaults['Sleep Hours']!,
        steps: int.tryParse(stepsController.text) ?? _defaults['Steps']!.toInt(),
        distance: double.tryParse(distanceController.text) ?? _defaults['Distance']!,
        timestamp: date,
      );

      // Save to daily data collection with date as document ID
      await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('dailyData')
          .doc(dateKey)
          .set(healthData.toMap(), SetOptions(merge: true));

      // Also update the latest data in the user document for quick access
      await _firestore
          .collection('healthData')
          .doc(userId)
          .set({
        'latestData': healthData.toMap(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update the cache
      _dailyDataCache[dateKey] = healthData;

      // Calculate and update weekly and monthly summaries
      await _updateAggregatedData(userId, date);

      emit(HealthDataSaved('Health data saved successfully'));
    } catch (e) {
      emit(HealthDataError('Failed to save health data: ${e.toString()}'));
    }
  }

  Future<void> _updateAggregatedData(String userId, DateTime date) async {
    try {
      // Generate week and month keys
      final weekYear = '${date.year}-W${(date.day / 7).ceil()}';
      final monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      // Get all data from this week
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));

      final weekData = await getHealthDataByDateRange(weekStart, weekEnd);

      if (weekData.isNotEmpty) {
        // Calculate weekly aggregates
        final weeklyAggregates = _calculateAggregates(weekData);

        // Save weekly summary
        await _firestore
            .collection('healthData')
            .doc(userId)
            .collection('weeklySummaries')
            .doc(weekYear)
            .set({
          ...weeklyAggregates,
          'startDate': weekStart,
          'endDate': weekEnd,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Calculate monthly aggregates
      final monthStart = DateTime(date.year, date.month, 1);
      final monthEnd = (date.month < 12)
          ? DateTime(date.year, date.month + 1, 0)
          : DateTime(date.year + 1, 1, 0);

      final monthData = await getHealthDataByDateRange(monthStart, monthEnd);

      if (monthData.isNotEmpty) {
        final monthlyAggregates = _calculateAggregates(monthData);

        // Save monthly summary
        await _firestore
            .collection('healthData')
            .doc(userId)
            .collection('monthlySummaries')
            .doc(monthYear)
            .set({
          ...monthlyAggregates,
          'startDate': monthStart,
          'endDate': monthEnd,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating aggregated data: $e');
      // Don't throw or emit state here, as this is a background process
    }
  }

  Map<String, dynamic> _calculateAggregates(List<HealthDataModel> dataList) {
    if (dataList.isEmpty) return {};

    double totalCalories = 0;
    int totalActiveMinutes = 0;
    double totalHydration = 0;
    int totalSteps = 0;
    double totalDistance = 0;
    double totalSleep = 0;

    List<double> weights = [];
    List<int> heartRates = [];

    for (var data in dataList) {
      totalCalories += data.caloriesBurned;
      totalActiveMinutes += data.activeMinutes;
      totalHydration += data.hydration;
      totalSteps += data.steps;
      totalDistance += data.distance;
      totalSleep += data.sleepHours;

      if (data.weight > 0) weights.add(data.weight);
      if (data.heartRate > 0) heartRates.add(data.heartRate);
    }

    // Calculate averages
    final daysCount = dataList.length;
    final avgCalories = totalCalories / daysCount;
    final avgActiveMinutes = totalActiveMinutes / daysCount;
    final avgHydration = totalHydration / daysCount;
    final avgSteps = totalSteps / daysCount;
    final avgDistance = totalDistance / daysCount;
    final avgSleep = totalSleep / daysCount;

    // Only average weights and heart rates if we have data
    final avgWeight = weights.isNotEmpty
        ? weights.reduce((a, b) => a + b) / weights.length
        : 0;

    final avgHeartRate = heartRates.isNotEmpty
        ? heartRates.reduce((a, b) => a + b) / heartRates.length
        : 0;

    return {
      'avgCaloriesBurned': avgCalories,
      'avgActiveMinutes': avgActiveMinutes,
      'avgHydration': avgHydration,
      'avgSteps': avgSteps,
      'avgDistance': avgDistance,
      'avgSleepHours': avgSleep,
      'avgWeight': avgWeight,
      'avgHeartRate': avgHeartRate,
      'totalCaloriesBurned': totalCalories,
      'totalActiveMinutes': totalActiveMinutes,
      'totalSteps': totalSteps,
      'totalDistance': totalDistance,
      'daysLogged': daysCount,
    };
  }

  Future<HealthDataModel?> getHealthDataForDate(DateTime date) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final dateKey = _formatDateKey(date);

      // Check cache first
      if (_dailyDataCache.containsKey(dateKey)) {
        return _dailyDataCache[dateKey];
      }

      // If not in cache, get from Firestore
      final docSnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('dailyData')
          .doc(dateKey)
          .get();

      if (docSnapshot.exists) {
        final healthData = HealthDataModel.fromMap(
          docSnapshot.data()!,
          docSnapshot.id,
        );

        // Add to cache
        _dailyDataCache[dateKey] = healthData;
        return healthData;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get health data for date: $e');
    }
  }

  Future<List<HealthDataModel>> getHealthHistory({int limit = 30}) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('dailyData')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final results = querySnapshot.docs
          .map((doc) => HealthDataModel.fromMap(doc.data(), doc.id))
          .toList();

      // Update cache with results
      for (var data in results) {
        final dateKey = _formatDateKey(data.timestamp);
        _dailyDataCache[dateKey] = data;
      }

      return results;
    } catch (e) {
      throw Exception('Failed to get health history: $e');
    }
  }

  Future<List<HealthDataModel>> getHealthDataByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Normalize dates to start of day and end of day
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('dailyData')
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThanOrEqualTo: end)
          .orderBy('timestamp', descending: true)
          .get();

      final results = querySnapshot.docs
          .map((doc) => HealthDataModel.fromMap(doc.data(), doc.id))
          .toList();

      // Update cache with results
      for (var data in results) {
        final dateKey = _formatDateKey(data.timestamp);
        _dailyDataCache[dateKey] = data;
      }

      return results;
    } catch (e) {
      throw Exception('Failed to get health data by date range: $e');
    }
  }

  Future<Map<String, dynamic>?> getWeeklySummary(DateTime forWeek) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Calculate week number
      final weekYear = '${forWeek.year}-W${(forWeek.day / 7).ceil()}';

      final docSnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('weeklySummaries')
          .doc(weekYear)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get weekly summary: $e');
    }
  }

  Future<Map<String, dynamic>?> getMonthlySummary(int year, int month) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final monthYear = '$year-${month.toString().padLeft(2, '0')}';

      final docSnapshot = await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('monthlySummaries')
          .doc(monthYear)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get monthly summary: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDailyProgressTrend(
      String metric,
      int days,
      ) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days - 1));

      final data = await getHealthDataByDateRange(startDate, endDate);

      // Convert to a list of map entries for the specific metric
      return data.map((entry) {
        final value = switch (metric) {
          'caloriesBurned' => entry.caloriesBurned,
          'activeMinutes' => entry.activeMinutes.toDouble(),
          'heartRate' => entry.heartRate.toDouble(),
          'hydration' => entry.hydration,
          'weight' => entry.weight,
          'sleepHours' => entry.sleepHours,
          'steps' => entry.steps.toDouble(),
          'distance' => entry.distance,
          _ => 0.0,
        };

        return {
          'date': _formatDateKey(entry.timestamp),
          'value': value,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get daily progress trend: $e');
    }
  }

  // Load all goals for the current user
  Future<void> loadGoals(userId) async {
    try {
      emit(HealthGoalsLoading());

      // Listen to goals collection filtered by user ID
      FirebaseFirestore.instance
          .collection('health_goals')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
          final goals = snapshot.docs
              .map((doc) => HealthGoalModel.fromFirestore(doc))
              .toList();

          // Update goal targets map
          _goalTargets = {};
          for (final goal in goals) {
            if (!_goalTargets.containsKey(goal.category)) {
              _goalTargets[goal.category] = goal.target;
            }
          }

          emit(HealthGoalsLoaded());
        },
        onError: (error) {
          emit(
            HealthGoalsError('Failed to load goals: ${error.toString()}'),
          );
        },
      );
    } catch (e) {
      emit(HealthGoalsError('Unexpected error: ${e.toString()}'));
    }
  }

  // Get target for a specific category
  double? getTargetForCategory(GoalCategory category) {
    return _goalTargets[category];
  }

  // Calculate progress percentage towards a goal
  double calculateGoalProgress(GoalCategory category, double currentValue) {
    final target = getTargetForCategory(category);
    if (target == null || target <= 0) return 0.0;

    return (currentValue / target).clamp(0.0, 1.0);
  }

  void resetToDefaults() {
    _initializeControllers();
    emit(HealthDataInitial());
  }

  // Clear cache for specific date or all dates
  void clearCache({String? dateKey}) {
    if (dateKey != null) {
      _dailyDataCache.remove(dateKey);
    } else {
      _dailyDataCache.clear();
    }
  }

  @override
  Future<void> close() {
    // Dispose all controllers
    caloriesBurnedController.dispose();
    activeMinutesController.dispose();
    heartRateController.dispose();
    hydrationController.dispose();
    weightController.dispose();
    goalWeightLossController.dispose();
    sleepHoursController.dispose();
    stepsController.dispose();
    distanceController.dispose();
    return super.close();
  }
}