import 'package:equatable/equatable.dart';
import '../../Data/emergency_model.dart';

abstract class EmergencyContactsState extends Equatable {
  const EmergencyContactsState();

  @override
  List<Object?> get props => [];
}

class EmergencyContactsInitial extends EmergencyContactsState {}

class EmergencyContactsLoading extends EmergencyContactsState {}

class EmergencyContactsLoaded extends EmergencyContactsState {
  final List<EmergencyContact> contacts;

  const EmergencyContactsLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class EmergencyContactsError extends EmergencyContactsState {
  final String message;

  const EmergencyContactsError(this.message);

  @override
  List<Object?> get props => [message];
}