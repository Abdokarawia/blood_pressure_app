import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../Data/medication_model.dart';

abstract class MedicationState extends Equatable {
  const MedicationState();

  @override
  List<Object> get props => [];
}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationLoaded extends MedicationState {
  final List<Medication> medications;

  const MedicationLoaded(this.medications);

  @override
  List<Object> get props => [medications];
}

class MedicationEmpty extends MedicationState {}

class MedicationError extends MedicationState {
  final String message;

  const MedicationError(this.message);

  @override
  List<Object> get props => [message];
}

class MedicationNotificationReceived extends MedicationState {
  final String title;
  final String body;
  final Map<String, dynamic> data;

  MedicationNotificationReceived(this.title, this.body, this.data);
}

class MedicationNotificationOpened extends MedicationState {
  final String title;
  final String body;
  final Map<String, dynamic> data;

  MedicationNotificationOpened(this.title, this.body, this.data);
}

class MedicationNotificationSettings extends MedicationState {
  final NotificationSettings settings;

  MedicationNotificationSettings(this.settings);
}

class MedicationInAppNotification extends MedicationState {
  final String title;
  final String message;
  final Map<String, dynamic> data;

  MedicationInAppNotification(this.title, this.message, this.data);
}

class MedicationUpcomingReminder extends MedicationState {
  final String medicationName;
  final String message;
  final String medicationId;
  final DateTime dueTime;

  MedicationUpcomingReminder(
      this.medicationName,
      this.message,
      this.medicationId,
      this.dueTime,
      );
}

class MedicationSuccess extends MedicationState {
  final String message;

  const MedicationSuccess(this.message);

  @override
  List<Object> get props => [message];
}