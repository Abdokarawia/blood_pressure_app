import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Data/emergency_model.dart';
import 'emergency_state.dart';

class EmergencyContactsCubit extends Cubit<EmergencyContactsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionPath = 'emergency_contacts';

  EmergencyContactsCubit() : super(EmergencyContactsInitial()) {}

  void loadContacts() {
    emit(EmergencyContactsLoading());

    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(EmergencyContactsError('User not authenticated'));
      return;
    }

    _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      final contacts = snapshot.docs.map((doc) {
        return EmergencyContact.fromMap(doc.data(), doc.id);
      }).toList();

      emit(EmergencyContactsLoaded(contacts));
    }, onError: (error) {
      emit(EmergencyContactsError(error.toString()));
    });
  }

  Future<void> addContact(EmergencyContact contact) async {
    try {
      emit(EmergencyContactsLoading());

      final String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(EmergencyContactsError('User not authenticated'));
        return;
      }

      // Add the userId to the contact data
      final contactData = contact.toMap();
      contactData['userId'] = uid;

      await _firestore.collection(_collectionPath).add(contactData);
      // Success feedback handled in UI via state changes
    } catch (e) {
      emit(EmergencyContactsError('Failed to add contact: $e'));
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      emit(EmergencyContactsLoading());

      final String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(EmergencyContactsError('User not authenticated'));
        return;
      }

      // Verify the contact belongs to the current user before deleting
      final docSnapshot = await _firestore.collection(_collectionPath).doc(contactId).get();
      if (docSnapshot.exists && docSnapshot.data()?['userId'] == uid) {
        await _firestore.collection(_collectionPath).doc(contactId).delete();
      } else {
        emit(EmergencyContactsError('Cannot delete: Contact not found or unauthorized'));
      }
      // Success feedback handled in UI via state changes
    } catch (e) {
      emit(EmergencyContactsError('Failed to delete contact: $e'));
    }
  }

  // Helper method to check authentication status
  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }
}