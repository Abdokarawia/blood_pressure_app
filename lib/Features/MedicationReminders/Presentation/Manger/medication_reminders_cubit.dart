import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/Utils/notification_service.dart';
import '../../Data/medication_model.dart';
import 'medication_reminders_state.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationService _notificationService; // Add notification service

  MedicationCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationService = notificationService ?? NotificationService(), // Initialize notification service
        super(MedicationInitial()) {
    _initialize();
  }

  void _initialize() async {
    try {
      // Initialize timezone data
      tz_data.initializeTimeZones();

      // Initialize the notification service
      await _notificationService.initializeNotifications();
      await _notificationService.requestPermissions();

      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          await loadMedications();
          await fetchNotifications();
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

      // Schedule notifications for the new medication
      await scheduleNotifications(
        medicationId: medication.id,
        medicationName: medication.name,
        scheduledTime: medication.time,
        selectedDays: medication.selectedDays,
        frequency: medication.frequency,
      );

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

      // Cancel existing notifications for this medication
      await _cancelMedicationNotifications(medication.id);

      // Re-schedule notifications if medication is active
      if (medication.isActive) {
        await scheduleNotifications(
          medicationId: medication.id,
          medicationName: medication.name,
          scheduledTime: medication.time,
          selectedDays: medication.selectedDays,
          frequency: medication.frequency,
        );
      }

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
      // Cancel notifications for this medication
      await _cancelMedicationNotifications(id);

      // Delete medication from Firestore
      await _firestore
          .collection('medications')
          .doc(userId)
          .collection('medications')
          .doc(id)
          .delete();

      // Also clean up notification records
      await _deleteNotificationRecords(id);

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

      // Handle notifications based on new active status
      if (updatedMedication.isActive) {
        // Re-enable notifications
        await scheduleNotifications(
          medicationId: updatedMedication.id,
          medicationName: updatedMedication.name,
          scheduledTime: updatedMedication.time,
          selectedDays: updatedMedication.selectedDays,
          frequency: updatedMedication.frequency,
        );
      } else {
        // Cancel notifications
        await _cancelMedicationNotifications(updatedMedication.id);
      }

      emit(MedicationSuccess('Medication status updated successfully'));
      await loadMedications();
    } catch (e) {
      emit(MedicationError('Failed to toggle medication status: $e'));
    }
  }

  /// Fetch notifications for the current user
  Future<void> fetchNotifications() async {
    final userId = _userId;
    if (userId == null) {
      emit(MedicationError('User not authenticated'));
      return;
    }

    emit(MedicationLoading());
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = snapshot.docs.map((doc) {
        return doc.data();
      }).toList();

      emit(NotificationsFetched());
    } catch (e) {
      emit(MedicationError('Failed to fetch notifications: $e'));
    }
  }

  /// Schedule notifications for a medication
  Future<void> scheduleNotifications({
    required String medicationId,
    required String medicationName,
    required DateTime scheduledTime,
    required List<int> selectedDays,
    required String frequency,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30));
      final scheduledTimes = <DateTime>[];

      // Generate schedule for the next 30 days
      for (var date = now; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
        final dayOfWeek = date.weekday;
        if (!selectedDays.contains(dayOfWeek)) continue;

        final notificationTime = DateTime(
          date.year,
          date.month,
          date.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );

        if (notificationTime.isBefore(now)) continue;
        scheduledTimes.add(notificationTime);
      }

      if (scheduledTimes.isEmpty) {
        emit(MedicationError('No valid notification times for this schedule'));
        return;
      }

      final notificationId = const Uuid().v4();
      final notificationRef = _firestore
          .collection('notifications')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId);

      // Store notification data in Firestore
      await notificationRef.set({
        'notificationId': notificationId,
        'medicationId': medicationId,
        'medicationName': medicationName,
        'scheduledTimes': scheduledTimes.map((time) => Timestamp.fromDate(time)).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'frequency': frequency,
        'selectedDays': selectedDays,
        'payload': {
          'type': 'medication_reminder',
          'medicationId': medicationId,
          'action': 'take_medication',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      });

      // Schedule local notifications for each time
      for (int i = 0; i < scheduledTimes.length; i++) {
        final time = scheduledTimes[i];
        final notificationUniqueId = int.parse('${medicationId.hashCode}$i'.substring(0, 9));

        await _notificationService.scheduleNotification(
          id: notificationUniqueId,
          title: 'Time for your medication',
          body: 'Remember to take $medicationName now',
          scheduledDate: time,
          payload: '{"medicationId":"$medicationId","notificationId":"$notificationId"}',
          channelId: 'medication_channel', // Use medication-specific channel
        );
      }

      // Refresh notifications list
      await fetchNotifications();
    } catch (e) {
      emit(MedicationError('Failed to schedule notifications: $e'));
    }
  }

  /// Cancel all notifications for a specific medication
  Future<void> _cancelMedicationNotifications(String medicationId) async {
    try {
      final userId = _userId;
      if (userId == null) return;

      // Find all notification records for this medication
      final snapshot = await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('notifications')
          .where('medicationId', isEqualTo: medicationId)
          .get();

      // For each notification record
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final scheduledTimes = (data['scheduledTimes'] as List<dynamic>?)
            ?.map((timestamp) => (timestamp as Timestamp).toDate())
            .toList();

        // Cancel each scheduled local notification
        if (scheduledTimes != null) {
          for (int i = 0; i < scheduledTimes.length; i++) {
            final notificationUniqueId = int.parse('${medicationId.hashCode}$i'.substring(0, 9));
            await _notificationService.cancelNotification(notificationUniqueId);
          }
        }
      }
    } catch (e) {
      emit(MedicationError('Failed to cancel notifications: $e'));
    }
  }

  /// Delete notification records for a medication
  Future<void> _deleteNotificationRecords(String medicationId) async {
    try {
      final userId = _userId;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('notifications')
          .where('medicationId', isEqualTo: medicationId)
          .get();

      // Delete each notification document
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting notification records: $e');
    }
  }

  /// Helper method to format time ago
  String getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final formattedDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());
      return formattedDate;
    }
  }

  /// Method to handle when user takes a medication
  Future<void> markMedicationAsTaken(String medicationId, DateTime timestamp) async {
    final userId = _userId;
    if (userId == null) {
      emit(MedicationError('User not authenticated'));
      return;
    }

    try {
      // Record that the medication was taken
      await _firestore
          .collection('medications')
          .doc(userId)
          .collection('history')
          .add({
        'medicationId': medicationId,
        'takenAt': Timestamp.fromDate(timestamp),
        'status': 'taken',
      });

      emit(MedicationSuccess('Medication marked as taken'));
    } catch (e) {
      emit(MedicationError('Failed to record medication: $e'));
    }
  }
}