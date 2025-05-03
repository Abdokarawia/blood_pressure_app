part of 'health_data_analysis_cubit.dart';

@immutable
abstract class HealthDataAnalysisState {}

class HealthDataAnalysisInitial extends HealthDataAnalysisState {}

class HealthDataAnalysisLoading extends HealthDataAnalysisState {}

class HealthDataAnalysisSuccess extends HealthDataAnalysisState {
  final Map<String, dynamic> analysis;

  HealthDataAnalysisSuccess(this.analysis);
}

class HealthDataAnalysisEmpty extends HealthDataAnalysisState {
  final String message;

  HealthDataAnalysisEmpty(this.message);
}

class HealthDataAnalysisFailure extends HealthDataAnalysisState {
  final String error;

  HealthDataAnalysisFailure(this.error);
}