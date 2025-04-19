// File: lib/logic/cubit/health_goals_state.dart
import 'package:equatable/equatable.dart';

import '../../data/HealthGoalModel.dart';

abstract class HealthGoalsState extends Equatable {
  const HealthGoalsState();

  @override
  List<Object> get props => [];
}

// Initial state when the cubit is first created
class HealthGoalsInitial extends HealthGoalsState {}

// Loading states
class HealthGoalsLoading extends HealthGoalsState {}
class HealthGoalCreating extends HealthGoalsState {}
class HealthGoalUpdating extends HealthGoalsState {}
class HealthGoalDeleting extends HealthGoalsState {}
class HealthGoalProgressUpdating extends HealthGoalsState {}

// Success states
class HealthGoalsLoaded extends HealthGoalsState {
  final List<HealthGoalModel> goals;

  const HealthGoalsLoaded(this.goals);

  @override
  List<Object> get props => [goals];

  // Helper method to create a new instance with updated goals
  HealthGoalsLoaded copyWith({List<HealthGoalModel>? goals}) {
    return HealthGoalsLoaded(goals ?? this.goals);
  }
}

class HealthGoalCreated extends HealthGoalsState {
  final HealthGoalModel goal;

  const HealthGoalCreated(this.goal);

  @override
  List<Object> get props => [goal];
}

class HealthGoalUpdated extends HealthGoalsState {
  final HealthGoalModel goal;

  const HealthGoalUpdated(this.goal);

  @override
  List<Object> get props => [goal];
}

class HealthGoalDeleted extends HealthGoalsState {
  final String goalId;

  const HealthGoalDeleted(this.goalId);

  @override
  List<Object> get props => [goalId];
}

class HealthGoalProgressUpdated extends HealthGoalsState {
  final HealthGoalModel goal;
  final double newProgress;

  const HealthGoalProgressUpdated(this.goal, this.newProgress);

  @override
  List<Object> get props => [goal, newProgress];
}

// Error states
class HealthGoalsError extends HealthGoalsState {
  final String message;
  final String? code;

  const HealthGoalsError(this.message, {this.code});

  @override
  List<Object> get props => [message, code ?? ''];
}

class HealthGoalCreateError extends HealthGoalsState {
  final String message;
  final String? code;

  const HealthGoalCreateError(this.message, {this.code});

  @override
  List<Object> get props => [message, code ?? ''];
}

class HealthGoalUpdateError extends HealthGoalsState {
  final String message;
  final String? code;
  final String goalId;

  const HealthGoalUpdateError(this.message, this.goalId, {this.code});

  @override
  List<Object> get props => [message, goalId, code ?? ''];
}

class HealthGoalDeleteError extends HealthGoalsState {
  final String message;
  final String? code;
  final String goalId;

  const HealthGoalDeleteError(this.message, this.goalId, {this.code});

  @override
  List<Object> get props => [message, goalId, code ?? ''];
}

class HealthGoalProgressUpdateError extends HealthGoalsState {
  final String message;
  final String? code;
  final String goalId;

  const HealthGoalProgressUpdateError(this.message, this.goalId, {this.code});

  @override
  List<Object> get props => [message, goalId, code ?? ''];
}