import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../Data/User_Model.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  // Default timeout duration
  static const Duration _defaultTimeout = Duration(seconds: 30);

  AuthenticationCubit({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        super(AuthenticationInitial());

  // Sign In with Email and Password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    Duration timeout = _defaultTimeout,
  }) async {
    emit(AuthenticationLoading());
    try {
      final userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .timeout(
        timeout,
        onTimeout: () => throw TimeoutException('Sign-in request timed out'),
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get()
            .timeout(
          timeout,
          onTimeout: () => throw TimeoutException('User data fetch timed out'),
        );
        final userData = userDoc.data();

        final user = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? userData?['name'],
          email: firebaseUser.email ?? email,
          phone: firebaseUser.phoneNumber ?? userData?['phone'],
          dateOfBirth: userData?['dateOfBirth'] != null
              ? DateTime.parse(userData!['dateOfBirth'])
              : null,
          createdAt: firebaseUser.metadata.creationTime,
        );
        emit(AuthenticationSuccess(user: user));
      }
    } on TimeoutException catch (e) {
      emit(AuthenticationError(
        message: e.message,
            ));
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationError(
        message: _mapFirebaseErrorToMessage(e),
      ));
    } catch (e) {
      emit(AuthenticationError(
        message: 'An unexpected error occurred',
      ));
    }
  }

  // Sign Up with Email and Password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
    DateTime? dateOfBirth,
    Duration timeout = _defaultTimeout,
  }) async {
    emit(AuthenticationLoading());
    try {
      final userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .timeout(
        timeout,
        onTimeout: () => throw TimeoutException('Sign-up request timed out'),
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Update display name
        await firebaseUser.updateDisplayName(name).timeout(
          timeout,
          onTimeout: () => throw TimeoutException('Profile update timed out'),
        );

        // Create user model
        final user = UserModel(
          uid: firebaseUser.uid,
          name: name,
          email: email,
          phone: phone,
          dateOfBirth: dateOfBirth,
          createdAt: DateTime.now(),
        );

        // Store additional user data in Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toJson())
            .timeout(
          timeout,
          onTimeout: () => throw TimeoutException('User data storage timed out'),
        );

        emit(AuthenticationSuccess(user: user));
      }
    } on TimeoutException catch (e) {
      emit(AuthenticationError(
        message: e.message,
            ));
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationError(
        message: _mapFirebaseErrorToMessage(e),
      ));
    } catch (e) {
      emit(AuthenticationError(
        message: 'An unexpected error occurred during signup',
      ));
    }
  }

  Future<void> signInWithGoogle({
    Duration timeout = const Duration(seconds: 10), // Increased for web
  }) async {
    emit(AuthenticationLoading());
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web-specific Google Sign-In using Popup
        final GoogleAuthProvider provider = GoogleAuthProvider()
            .setCustomParameters({'prompt': 'select_account'});
        userCredential = await _firebaseAuth.signInWithPopup(provider).timeout(
          timeout,
          onTimeout: () => throw TimeoutException('Firebase popup sign-in timed out'),
        );
      } else {
        // Mobile/non-web flow
        final googleUser = await _googleSignIn.signIn().timeout(
          timeout,
          onTimeout: () => throw TimeoutException('Google sign-in timed out'),
        );

        if (googleUser == null) {
          emit(AuthenticationError(message: 'Google Sign-In was cancelled'));
          return;
        }

        final googleAuth = await googleUser.authentication.timeout(
          timeout,
          onTimeout: () => throw TimeoutException('Google authentication timed out'),
        );

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential).timeout(
          timeout,
          onTimeout: () => throw TimeoutException('Firebase credential sign-in timed out'),
        );
      }

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get()
            .timeout(
          timeout,
          onTimeout: () => throw TimeoutException('User data fetch timed out'),
        );

        UserModel user;
        if (!userDoc.exists) {
          user = UserModel(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName,
            email: firebaseUser.email??"",
            phone: firebaseUser.phoneNumber,
            createdAt: DateTime.now(),
          );
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(user.toJson())
              .timeout(
            timeout,
            onTimeout: () => throw TimeoutException('User data storage timed out'),
          );
        } else {
          final userData = userDoc.data();
          user = UserModel.fromJson({
            ...userData!,
            'uid': firebaseUser.uid,
            'email': firebaseUser.email,
          });
        }

        emit(AuthenticationSuccess(user: user));
      }
    } on TimeoutException catch (e) {
      print(e);
      emit(AuthenticationError(message: e.message ?? 'Operation timed out'));
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'popup-blocked') {
        emit(AuthenticationError(
          message: 'Popup was blocked. Please allow popups and try again.',
        ));
      } else {
        emit(AuthenticationError(message: _mapFirebaseErrorToMessage(e)));
      }
    } catch (e) {
      print(e);
      emit(AuthenticationError(message: 'Google sign-in failed'));
    }
  }

  // Forgot Password
  Future<void> resetPassword({
    required String email,
    Duration timeout = _defaultTimeout,
  }) async {
    emit(AuthenticationLoading());
    try {
      await _firebaseAuth
          .sendPasswordResetEmail(email: email)
          .timeout(
        timeout,
        onTimeout: () => throw TimeoutException('Password reset request timed out'),
      );
      emit(PasswordResetSuccess());
    } on TimeoutException catch (e) {
      emit(AuthenticationError(
        message: e.message,
        ));
    } on FirebaseAuthException catch (e) {
      emit(AuthenticationError(
        message: _mapFirebaseErrorToMessage(e),

      ));
    } catch (e) {
      emit(AuthenticationError(
        message: 'Failed to send reset email',
      ));
    }
  }

  String _mapFirebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'requires-recent-login':
        return 'Please log in again before retrying this request';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials';
      default:
        return 'Authentication failed: ${e.message ?? e.code}';
    }
  }
}

// Custom timeout exception class
class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => message;
}