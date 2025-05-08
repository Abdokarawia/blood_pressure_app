import 'package:equatable/equatable.dart';

abstract class HealthAnalysisState extends Equatable {
  const HealthAnalysisState();

  @override
  List<Object?> get props => [];
}

// Initial state when no analysis has been performed
class HealthAnalysisInitial extends HealthAnalysisState {}

// Loading state while analysis is being performed
class HealthAnalysisLoading extends HealthAnalysisState {}

// State when analysis data is successfully loaded
class HealthAnalysisLoaded extends HealthAnalysisState {
  final Map<String, dynamic> analysis;

  const HealthAnalysisLoaded(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

// Error state when analysis fails
class HealthAnalysisError extends HealthAnalysisState {
  final String message;

  const HealthAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}

// State when goals are being loaded
class HealthGoalsLoading extends HealthAnalysisState {}

// State when goals are successfully loaded
class HealthGoalsLoaded extends HealthAnalysisState {
  @override
  List<Object?> get props => [];
}

// Error state when loading goals fails
class HealthGoalsError extends HealthAnalysisState {
  final String message;

  const HealthGoalsError(this.message);

  @override
  List<Object?> get props => [message];
}