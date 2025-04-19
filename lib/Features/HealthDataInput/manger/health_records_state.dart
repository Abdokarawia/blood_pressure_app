
import 'package:equatable/equatable.dart';

import '../data/health_data_model.dart';

abstract class HealthDataState extends Equatable {
  const HealthDataState();

  @override
  List<Object?> get props => [];
}

class HealthDataInitial extends HealthDataState {}

class HealthDataLoading extends HealthDataState {}

class HealthDataLoaded extends HealthDataState {
  final HealthDataModel healthData;

  const HealthDataLoaded(this.healthData);

  @override
  List<Object?> get props => [healthData];
}

class HealthDataSaving extends HealthDataState {}

class HealthDataSaved extends HealthDataState {
  final String message;

  const HealthDataSaved(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthDataError extends HealthDataState {
  final String message;

  const HealthDataError(this.message);

  @override
  List<Object?> get props => [message];
}