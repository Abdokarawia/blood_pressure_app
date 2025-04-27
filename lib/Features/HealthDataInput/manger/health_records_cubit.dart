import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../GoalReminders/data/HealthGoalModel.dart';
import '../data/health_data_model.dart';
import 'health_records_state.dart';

class HealthDataCubit extends Cubit<HealthDataState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Map to store goals by category for quick access
  Map<GoalCategory, double> _goalTargets = {};

  // Text controllers for all form fields
  final TextEditingController caloriesBurnedController =
      TextEditingController();
  final TextEditingController activeMinutesController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController hydrationController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController goalWeightLossController =
      TextEditingController();
  final TextEditingController sleepHoursController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();

  // Default values for all metrics
  final Map<String, double> _defaults = {
    'Calories Burned': 0,
    'Active Minutes': 0,
    'Heart Rate': 72,
    'Hydration': 0,
    'Weight': 70,
    'Goal Weight Loss': 0,
    'Sleep Hours': 8, // Average recommended sleep
    'Steps': 0,
    'Distance': 0, // in kilometers
  };

  // Getter to access goal targets
  Map<GoalCategory, double> get goalTargets => _goalTargets;

  HealthDataCubit() : super(HealthDataInitial()) {
    _initializeControllers();
  }

  void _initializeControllers() {
    caloriesBurnedController.text =
        _defaults['Calories Burned']!.toInt().toString();
    activeMinutesController.text =
        _defaults['Active Minutes']!.toInt().toString();
    heartRateController.text = _defaults['Heart Rate']!.toInt().toString();
    hydrationController.text = _defaults['Hydration']!.toStringAsFixed(1);
    weightController.text = _defaults['Weight']!.toStringAsFixed(1);
    goalWeightLossController.text = _defaults['Goal Weight Loss']!
        .toStringAsFixed(1);
    sleepHoursController.text = _defaults['Sleep Hours']!.toStringAsFixed(1);
    stepsController.text = _defaults['Steps']!.toInt().toString();
    distanceController.text = _defaults['Distance']!.toStringAsFixed(2);
  }

  String? get _userId => _auth.currentUser?.uid;

  Future<void> loadHealthData() async {
    try {
      emit(HealthDataLoading());

      final userId = _userId;
      if (userId == null) {
        emit(HealthDataError('User not authenticated'));
        return;
      }

      final docSnapshot =
          await _firestore.collection('healthData').doc(userId).get();

      if (docSnapshot.exists) {
        final healthData = HealthDataModel.fromMap(
          docSnapshot.data()!,
          docSnapshot.id,
        );

        // Update all text controllers with retrieved data
        caloriesBurnedController.text =
            healthData.caloriesBurned.toInt().toString();
        activeMinutesController.text = healthData.activeMinutes.toString();
        heartRateController.text = healthData.heartRate.toString();
        hydrationController.text = healthData.hydration.toStringAsFixed(1);
        weightController.text = healthData.weight.toStringAsFixed(1);
        goalWeightLossController.text = healthData.goalWeightLoss
            .toStringAsFixed(1);
        sleepHoursController.text = healthData.sleepHours.toStringAsFixed(1);
        stepsController.text = healthData.steps.toString();
        distanceController.text = healthData.distance.toStringAsFixed(2);

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

  Future<void> saveHealthData() async {
    try {
      emit(HealthDataSaving());

      final userId = _userId;
      if (userId == null) {
        emit(HealthDataError('User not authenticated'));
        return;
      }

      final healthData = HealthDataModel(
        id: userId,
        caloriesBurned:
            double.tryParse(caloriesBurnedController.text) ??
            _defaults['Calories Burned']!,
        activeMinutes:
            int.tryParse(activeMinutesController.text) ??
            _defaults['Active Minutes']!.toInt(),
        heartRate:
            int.tryParse(heartRateController.text) ??
            _defaults['Heart Rate']!.toInt(),
        hydration:
            double.tryParse(hydrationController.text) ??
            _defaults['Hydration']!,
        weight: double.tryParse(weightController.text) ?? _defaults['Weight']!,
        goalWeightLoss:
            double.tryParse(goalWeightLossController.text) ??
            _defaults['Goal Weight Loss']!,
        sleepHours:
            double.tryParse(sleepHoursController.text) ??
            _defaults['Sleep Hours']!,
        steps:
            int.tryParse(stepsController.text) ?? _defaults['Steps']!.toInt(),
        distance:
            double.tryParse(distanceController.text) ?? _defaults['Distance']!,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('healthData')
          .doc(userId)
          .set(healthData.toMap(), SetOptions(merge: true));

      // Also add to history subcollection
      await _firestore
          .collection('healthData')
          .doc(userId)
          .collection('history')
          .add(healthData.toMap());

      emit(HealthDataSaved('Health data saved successfully'));
    } catch (e) {
      emit(HealthDataError('Failed to save health data: ${e.toString()}'));
    }
  }

  Future<List<HealthDataModel>> getHealthHistory() async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection('healthData')
              .doc(userId)
              .collection('history')
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => HealthDataModel.fromMap(doc.data(), doc.id))
          .toList();
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

      final querySnapshot =
          await _firestore
              .collection('healthData')
              .doc(userId)
              .collection('history')
              .where('timestamp', isGreaterThanOrEqualTo: startDate)
              .where('timestamp', isLessThanOrEqualTo: endDate)
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => HealthDataModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get health data by date range: $e');
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
              final goals =
                  snapshot.docs
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
              print(_goalTargets);
              print(snapshot.docs);
              print(goals);
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

  void resetToDefaults() {
    _initializeControllers();
    emit(HealthDataInitial());
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
