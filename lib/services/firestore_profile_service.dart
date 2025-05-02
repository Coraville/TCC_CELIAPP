import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _profiles => _firestore.collection('users');

  Future<void> saveUserProfile({
    required String name,
    required String birthDate,
    required String email,
    required bool hasAllergies,
    required List<String> allergens,
  }) async {
    if (userId == null) return;

    await _profiles.doc(userId).set({
      'name': name,
      'birthDate': birthDate,
      'email': email,
      'hasAllergies': hasAllergies,
      'allergens': allergens,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (userId == null) return null;

    final doc = await _profiles.doc(userId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }
}
