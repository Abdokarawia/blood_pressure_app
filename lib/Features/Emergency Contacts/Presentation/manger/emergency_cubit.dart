import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Data/emergency_model.dart';
import 'emergency_state.dart';

class EmergencyContactsCubit extends Cubit<EmergencyContactsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'emergency_contacts';

  EmergencyContactsCubit() : super(EmergencyContactsInitial()) {}

  void loadContacts() {
    emit(EmergencyContactsLoading());
    _firestore.collection(_collectionPath).snapshots().listen((snapshot) {
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
      await _firestore.collection(_collectionPath).add(contact.toMap());
      // Success feedback handled in UI via state changes
    } catch (e) {
      emit(EmergencyContactsError('Failed to add contact: $e'));
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      emit(EmergencyContactsLoading());
      await _firestore.collection(_collectionPath).doc(contactId).delete();
      // Success feedback handled in UI via state changes
    } catch (e) {
      emit(EmergencyContactsError('Failed to delete contact: $e'));
    }
  }
}