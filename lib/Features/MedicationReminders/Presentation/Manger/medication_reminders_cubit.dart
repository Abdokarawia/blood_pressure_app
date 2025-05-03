import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:uuid/uuid.dart';
import '../../Data/medication_model.dart';
import 'medication_reminders_state.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MedicationCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(MedicationInitial()) {
    _initialize();
  }

  void _initialize() async {
    try {
      // Initialize timezone data (if still needed for other time operations)
      tz_data.initializeTimeZones();

      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          await loadMedications();
        } else {
          emit(MedicationError('User not authenticated'));
        }
      });

    } catch (e) {
      emit(MedicationError('Initialization failed: $e'));
    }
  }

  String? get _userId => _auth.currentUser?.uid;

  Future<void> loadMedications() async {
    final userId = _userId;
    if (userId == null) {
      emit(MedicationError('User not authenticated'));
      return;
    }

    emit(MedicationLoading());
    try {
      final snapshot = await _firestore
          .collection('medications')
          .doc(userId)
          .collection('medications')
          .orderBy('time')
          .get();

      final medications = snapshot.docs
          .map((doc) => Medication.fromJson(doc.data()))
          .toList();

      if (medications.isEmpty) {
        emit(MedicationEmpty());
      } else {
        emit(MedicationLoaded(medications));
      }
    } catch (e) {
      emit(MedicationError('Failed to load medications: $e'));
    }
  }

  Future<void> addMedication({
    required String name,
    required String dosage,
    required DateTime time,
    required List<int> selectedDays,
    required String frequency,
    required String colorHex,
  }) async {
    final userId = _userId;
    if (userId == null) {
      emit(MedicationError('User not authenticated'));
      return;
    }

    try {
      final medication = Medication(
        id: const Uuid().v4(),
        name: name,
        dosage: dosage,
        time: time,
        selectedDays: selectedDays,
        frequency: frequency,
        colorHex: colorHex,
        isActive: true,
      );

      await _firestore
          .collection('medications')
          .doc(userId)
          .collection('medications')
          .doc(medication.id)
          .set(medication.toJson());

      emit(MedicationSuccess('Medication added successfully'));
      await loadMedications();
    } catch (e) {
      emit(MedicationError('Failed to add medication: $e'));
    }
  }

  Future<void> updateMedication(Medication medication) async {
    final userId = _userId;
    if (userId == null) {
      emit(MedicationError('User not authenticated'));
      return;
    }

    try {
      await _firestore
          .collection('medications')
          .doc(userId)
          .collection('medications')
          .doc(medication.id)
          .update(medication.toJson());

      emit(MedicationSuccess('Medication updated successfully'));
      await loadMedications();
    } catch (e) {
      emit(MedicationError('Failed to update medication: $e'));
    }
  }

  Future<void> deleteMedication(String id) async {
    final userId = _userId;
    if (userId == null) {
      emit(MedicationError('User not authenticated'));
      return;
    }

    try {
      await _firestore
          .collection('medications')
          .doc(userId)
          .collection('medications')
          .doc(id)
          .delete();

      emit(MedicationSuccess('Medication deleted successfully'));
      await loadMedications();
    } catch (e) {
      emit(MedicationError('Failed to delete medication: $e'));
    }
  }

  Future<void> toggleMedicationStatus(Medication medication) async {
    final userId = _userId;
    if (userId == null) {
      emit(MedicationError('User not authenticated'));
      return;
    }

    try {
      final updatedMedication = medication.copyWith(isActive: !medication.isActive);

      await _firestore
          .collection('medications')
          .doc(userId)
          .collection('medications')
          .doc(updatedMedication.id)
          .update({'isActive': updatedMedication.isActive});

      emit(MedicationSuccess('Medication status updated successfully'));
      await loadMedications();
    } catch (e) {
      emit(MedicationError('Failed to toggle medication status: $e'));
    }
  }
}