import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:uuid/uuid.dart';
import '../../Data/medication_model.dart';
import 'medication_reminders_state.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseMessaging _messaging;


  MedicationCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        super(MedicationInitial()) {
    _initialize();
  }

  void _initialize() async {
    try {
      // Initialize timezone data for scheduling
      tz_data.initializeTimeZones();

      // Setup notification channel (Android specific)
      await _setupNotificationChannel();

      // Request notification permissions
      await _requestNotificationPermissions();

      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          await _storeFcmToken();
          await loadMedications();
        } else {
          emit(MedicationError('User not authenticated'));
        }
      });

      // Listen for FCM token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        await _storeFcmToken(token: newToken);
      });

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleNotification(message);
      });

      // Handle notification open events
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotification(message, fromOpen: true);
      });

      // Check for initial message (if app was opened from terminated state)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotification(initialMessage, fromOpen: true);
      }

    } catch (e) {
      emit(MedicationError('Initialization failed: $e'));
    }
  }

  Future<void> _setupNotificationChannel() async {
    // This is Android-specific - no effect on iOS
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      print('Error setting notification options: $e');
    }
  }

  void _handleNotification(RemoteMessage message, {bool fromOpen = false}) {
    try {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        final title = notification.title ?? 'Medication Reminder';
        final body = notification.body ?? 'Time to take your medication';

        if (fromOpen) {
          emit(MedicationNotificationOpened(title, body, data));
        } else {
          emit(MedicationNotificationReceived(title, body, data));
        }

        // Handle specific medication action if needed
        if (data['medicationId'] != null) {
          // You could load the specific medication here
          print('Notification for medication: ${data['medicationId']}');
        }
      }
    } catch (e) {
      emit(MedicationError('Error handling notification: $e'));
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Notification permissions: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        emit(MedicationSuccess('Notification permissions granted'));
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        emit(MedicationSuccess('Provisional notification permissions granted'));
      } else {
        emit(MedicationError('Notification permissions denied'));
      }
    } catch (e) {
      emit(MedicationError('Failed to request notification permissions: $e'));
    }
  }

  String? get _userId => _auth.currentUser?.uid;

  Future<void> _storeFcmToken({String? token}) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      final fcmToken = token ?? await _messaging.getToken();
      if (fcmToken == null) {
        emit(MedicationError('Failed to get FCM token'));
        return;
      }

      print('Storing FCM token: $fcmToken');

      await _firestore.collection('fcmTokens').doc(userId).set({
        'token': fcmToken,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': {
          'platform': 'mobile',
          'lastActive': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      emit(MedicationError('Failed to store FCM token: $e'));
    }
  }

  Future<void> _scheduleNotifications({
    required String userId,
    required String medicationId,
    required String medicationName,
    required DateTime scheduledTime,
    required List<int> selectedDays,
    required String frequency,
  }) async {
    try {
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

      // Subscribe to topic for this medication
      await _messaging.subscribeToTopic('medication_$medicationId');
      print('Subscribed to topic: medication_$medicationId');

    } catch (e) {
      emit(MedicationError('Failed to schedule notifications: $e'));
      rethrow;
    }
  }

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

      await _scheduleNotifications(
        userId: userId,
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
      // Cancel existing notifications
      await _cancelMedicationNotifications(medication.id);

      // Update medication
      await _firestore
          .collection('medications')
          .doc(userId)
          .collection('medications')
          .doc(medication.id)
          .update(medication.toJson());

      // Schedule new notifications if medication is active
      if (medication.isActive) {
        await _scheduleNotifications(
          userId: userId,
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

  Future<void> _cancelMedicationNotifications(String medicationId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      final notificationsSnapshot = await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('notifications')
          .where('medicationId', isEqualTo: medicationId)
          .where('status', isEqualTo: 'pending')
          .get();

      final batch = _firestore.batch();
      for (var doc in notificationsSnapshot.docs) {
        batch.update(doc.reference, {'status': 'canceled'});
      }
      await batch.commit();

      // Unsubscribe from topic
      await _messaging.unsubscribeFromTopic('medication_$medicationId');
    } catch (e) {
      print('Error canceling notifications: $e');
      rethrow;
    }
  }

  Future<void> deleteMedication(String id) async {
    final userId = _userId;
    if (userId == null) {
      emit(MedicationError('User not authenticated'));
      return;
    }

    try {
      // Cancel notifications first
      await _cancelMedicationNotifications(id);

      // Then delete medication
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

      if (!updatedMedication.isActive) {
        await _cancelMedicationNotifications(medication.id);
      } else {
        await _scheduleNotifications(
          userId: userId,
          medicationId: medication.id,
          medicationName: medication.name,
          scheduledTime: medication.time,
          selectedDays: medication.selectedDays,
          frequency: medication.frequency,
        );
      }

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

  // Debug/testing methods
  Future<void> testNotification() async {
    try {
      final token = await _messaging.getToken();
      print('Current FCM token: $token');

      emit(MedicationSuccess('Test notification token: $token'));
    } catch (e) {
      emit(MedicationError('Failed to get FCM token: $e'));
    }
  }

  Future<void> checkNotificationPermissions() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      emit(MedicationNotificationSettings(settings));
    } catch (e) {
      emit(MedicationError('Failed to check permissions: $e'));
    }
  }
}