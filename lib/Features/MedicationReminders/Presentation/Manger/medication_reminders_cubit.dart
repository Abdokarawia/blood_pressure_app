import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../Data/medication_model.dart';
import 'medication_reminders_state.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final FirebaseFirestore _firestore;

  MedicationCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(MedicationInitial()) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    emit(MedicationLoading());
    try {
      final snapshot = await _firestore.collection('medications').get();
      final medications = snapshot.docs.map((doc) => Medication.fromJson(doc.data())).toList();
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
    try {
      final medication = Medication(
        id: const Uuid().v4(),
        name: name,
        dosage: dosage,
        time: time,
        selectedDays: selectedDays,
        frequency: frequency,
        colorHex: colorHex,
      );
      await _firestore
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
    try {
      await _firestore
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
    try {
      await _firestore.collection('medications').doc(id).delete();
      emit(MedicationSuccess('Medication deleted successfully'));
      await loadMedications();
    } catch (e) {
      emit(MedicationError('Failed to delete medication: $e'));
    }
  }

  Future<void> toggleMedicationStatus(Medication medication) async {
    try {
      final updatedMedication = Medication(
        id: medication.id,
        name: medication.name,
        dosage: medication.dosage,
        time: medication.time,
        selectedDays: medication.selectedDays,
        isActive: !medication.isActive,
        frequency: medication.frequency,
        colorHex: medication.colorHex,
      );
      await _firestore
          .collection('medications')
          .doc(updatedMedication.id)
          .update(updatedMedication.toJson());
      emit(MedicationSuccess('Medication status updated successfully'));
      await loadMedications();
    } catch (e) {
      emit(MedicationError('Failed to toggle medication status: $e'));
    }
  }
}