// lib/cubit/health_data_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/health_data_model.dart';
import 'health_records_state.dart';

class HealthDataCubit extends Cubit<HealthDataState> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text controllers for the form fields
  final TextEditingController caloriesBurnedController = TextEditingController();
  final TextEditingController activeMinutesController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController hydrationController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController goalWeightLossController = TextEditingController();

  // Default values
  final Map<String, double> _defaults = {
    'Calories Burned': 0,
    'Active Minutes': 0,
    'Heart Rate': 72,
    'Hydration': 0,
    'Weight': 70,
    'Goal Weight Loss': 0,
  };

  HealthDataCubit() : super(HealthDataInitial()) {
    _initializeControllers();
  }

  // Initialize controllers with default values
  void _initializeControllers() {
    caloriesBurnedController.text = _defaults['Calories Burned']!.toInt().toString();
    activeMinutesController.text = _defaults['Active Minutes']!.toInt().toString();
    heartRateController.text = _defaults['Heart Rate']!.toInt().toString();
    hydrationController.text = _defaults['Hydration']!.toStringAsFixed(1);
    weightController.text = _defaults['Weight']!.toStringAsFixed(1);
    goalWeightLossController.text = _defaults['Goal Weight Loss']!.toStringAsFixed(1);
  }

  // Fetch the most recent health data and update text controllers
  Future<void> loadLastHealthData(userId) async {
    try {
      emit(HealthDataLoading());


      final querySnapshot = await _firestore
          .collection('healthData')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final healthData = HealthDataModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        // Update text controllers with retrieved data
        caloriesBurnedController.text = healthData.caloriesBurned.toInt().toString();
        activeMinutesController.text = healthData.activeMinutes.toString();
        heartRateController.text = healthData.heartRate.toString();
        hydrationController.text = healthData.hydration.toStringAsFixed(1);
        weightController.text = healthData.weight.toStringAsFixed(1);
        goalWeightLossController.text = healthData.goalWeightLoss.toStringAsFixed(1);

        emit(HealthDataLoaded(healthData));
      } else {
        // No data found, use default values
        _initializeControllers();
        emit(HealthDataInitial());
      }
    } catch (e) {
      emit(HealthDataError('Failed to load health data: ${e.toString()}'));
    }
  }

  // Save current health data to Firebase
  Future<void> saveHealthData(userId) async {
    try {
      emit(HealthDataSaving());


      // Create a new health data model from text controllers
      final healthData = HealthDataModel(
        caloriesBurned: double.tryParse(caloriesBurnedController.text) ?? _defaults['Calories Burned']!,
        activeMinutes: int.tryParse(activeMinutesController.text) ?? _defaults['Active Minutes']!.toInt(),
        heartRate: int.tryParse(heartRateController.text) ?? _defaults['Heart Rate']!.toInt(),
        hydration: double.tryParse(hydrationController.text) ?? _defaults['Hydration']!,
        weight: double.tryParse(weightController.text) ?? _defaults['Weight']!,
        goalWeightLoss: double.tryParse(goalWeightLossController.text) ?? _defaults['Goal Weight Loss']!,
      );

      await _firestore
          .collection('healthData')
          .add(healthData.toMap());

      emit(HealthDataSaved('Health data saved successfully'));
    } catch (e) {
      emit(HealthDataError('Failed to save health data: ${e.toString()}'));
    }
  }

  // Update existing health data in Firebase
  Future<void> updateHealthData(String documentId , userId) async {
    try {
      emit(HealthDataSaving());

      // Create an updated health data model
      final healthData = HealthDataModel(
        id: documentId,
        caloriesBurned: double.tryParse(caloriesBurnedController.text) ?? _defaults['Calories Burned']!,
        activeMinutes: int.tryParse(activeMinutesController.text) ?? _defaults['Active Minutes']!.toInt(),
        heartRate: int.tryParse(heartRateController.text) ?? _defaults['Heart Rate']!.toInt(),
        hydration: double.tryParse(hydrationController.text) ?? _defaults['Hydration']!,
        weight: double.tryParse(weightController.text) ?? _defaults['Weight']!,
        goalWeightLoss: double.tryParse(goalWeightLossController.text) ?? _defaults['Goal Weight Loss']!,
      );

      await _firestore
          .collection('healthData')
          .doc(documentId)
          .update(healthData.toMap());

      emit(HealthDataSaved('Health data updated successfully'));
    } catch (e) {
      emit(HealthDataError('Failed to update health data: ${e.toString()}'));
    }
  }

  // Get health data entries for a specific date range
  Future<List<HealthDataModel>> getHealthDataByDateRange(
      DateTime startDate,
      DateTime endDate,
      userId
      ) async {
    try {
      final querySnapshot = await _firestore
          .collection('healthData')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HealthDataModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();
    } catch (e) {
      throw Exception('Failed to get health data by date range: $e');
    }
  }

  // Reset form fields to default values
  void resetToDefaults() {
    _initializeControllers();
    emit(HealthDataInitial());
  }

  @override
  Future<void> close() {
    // Dispose of text controllers when cubit is closed
    caloriesBurnedController.dispose();
    activeMinutesController.dispose();
    heartRateController.dispose();
    hydrationController.dispose();
    weightController.dispose();
    goalWeightLossController.dispose();
    return super.close();
  }
}