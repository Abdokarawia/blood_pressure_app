// File: lib/logic/cubit/health_goals_cubit.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/HealthGoalModel.dart';
import 'health_goals_state.dart';

class HealthGoalsCubit extends Cubit<HealthGoalsState> {
  final FirebaseFirestore _firestore;
  final String _goalsCollection = 'health_goals';

  HealthGoalsCubit({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        super(HealthGoalsInitial());


  // Get goals collection reference
  CollectionReference get _goalsRef => _firestore.collection(_goalsCollection);

  // Load all goals for the current user
  Future<void> loadGoals(userId) async {
    try {


      emit(HealthGoalsLoading());

      // Listen to goals collection filtered by user ID
      _goalsRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
          final goals = snapshot.docs
              .map((doc) => HealthGoalModel.fromFirestore(doc))
              .toList();
          emit(HealthGoalsLoaded(goals));
        },
        onError: (error) {
          emit(HealthGoalsError('Failed to load goals: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(HealthGoalsError('Unexpected error: ${e.toString()}'));
    }
  }

  // Create a new goal
  Future<void> createGoal(HealthGoal goal ,userId) async {
    try {

      emit(HealthGoalCreating());

      // Convert UI model to data model
      final goalModel = HealthGoalModel.fromHealthGoal(goal, userId!);

      // Add document to Firestore
      final docRef = await _goalsRef.add(goalModel.toFirestore());

      // Get the created document with ID
      final createdGoal = goalModel.copyWith(id: docRef.id);

      emit(HealthGoalCreated(createdGoal));
    } catch (e) {
      emit(HealthGoalCreateError('Failed to create goal: ${e.toString()}'));
    }
  }

  // Update an existing goal
  Future<void> updateGoal(HealthGoalModel goal , userId) async {
    try {

      emit(HealthGoalUpdating());

      // Update the document in Firestore
      await _goalsRef.doc(goal.id).update(goal.toFirestore());

      emit(HealthGoalUpdated(goal));
    } catch (e) {
      emit(HealthGoalUpdateError(
        'Failed to update goal: ${e.toString()}',
        goal.id ?? 'unknown',
      ));
    }
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      emit(HealthGoalDeleting());

      // Delete the document from Firestore
      await _goalsRef.doc(goalId).delete();

      emit(HealthGoalDeleted(goalId));
    } catch (e) {
      emit(HealthGoalDeleteError(
        'Failed to delete goal: ${e.toString()}',
        goalId,
      ));
    }
  }

  // Update goal progress
  Future<void> updateGoalProgress(String goalId, double newProgress) async {
    try {
      emit(HealthGoalProgressUpdating());

      // Get the current goal
      final docSnapshot = await _goalsRef.doc(goalId).get();
      if (!docSnapshot.exists) {
        emit(HealthGoalProgressUpdateError(
          'Goal not found',
          goalId,
        ));
        return;
      }

      // Update only the progress field
      final goal = HealthGoalModel.fromFirestore(docSnapshot);
      await _goalsRef.doc(goalId).update({
        'currentProgress': newProgress,
        'lastUpdatedAt': Timestamp.now(),
      });

      // If progress meets target, increment daysAchieved
      if (newProgress >= goal.target &&
          goal.daysAchieved < goal.daysToAchieve) {
        await _goalsRef.doc(goalId).update({
          'daysAchieved': goal.daysAchieved + 1,
        });
      }

      final updatedGoal = goal.copyWith(
        currentProgress: newProgress,
        daysAchieved: newProgress >= goal.target ? goal.daysAchieved + 1 : goal.daysAchieved,
      );

      emit(HealthGoalProgressUpdated(updatedGoal, newProgress));
    } catch (e) {
      emit(HealthGoalProgressUpdateError(
        'Failed to update progress: ${e.toString()}',
        goalId,
      ));
    }
  }

  // Reset goal progress (for daily/weekly goals)
  Future<void> resetGoalProgress(String goalId) async {
    try {
      // Get the current goal
      final docSnapshot = await _goalsRef.doc(goalId).get();
      if (!docSnapshot.exists) {
        return;
      }

      // Reset progress to 0
      await _goalsRef.doc(goalId).update({
        'currentProgress': 0.0,
        'lastUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      // Handle error silently
      print('Failed to reset goal progress: ${e.toString()}');
    }
  }
}