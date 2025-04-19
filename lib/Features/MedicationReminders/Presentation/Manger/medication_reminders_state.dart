import 'package:equatable/equatable.dart';

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

class MedicationSuccess extends MedicationState {
  final String message;

  const MedicationSuccess(this.message);

  @override
  List<Object> get props => [message];
}