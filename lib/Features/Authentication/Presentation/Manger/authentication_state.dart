// lib/features/authentication/presentation/bloc/authentication_state.dart
part of 'authentication_cubit.dart';

@immutable
abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final UserModel user;

  AuthenticationSuccess({required this.user});
}

class AuthenticationError extends AuthenticationState {
  final String message;

  AuthenticationError({required this.message});
}
class PasswordResetSuccess extends AuthenticationState {}