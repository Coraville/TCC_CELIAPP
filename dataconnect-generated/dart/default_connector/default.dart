import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DefaultConnector {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseAuth auth = FirebaseAuth.instance;

  // Para o Firestore, não é necessário um "connectorConfig" complicado
  static FirebaseFirestore get firestoreInstance => firestore;

  DefaultConnector();

  // Método simples para verificar se o usuário está autenticado
  static User? getCurrentUser() {
    return auth.currentUser;
  }

  // Método para pegar dados do usuário do Firestore
  static Future<DocumentSnapshot> getUserData(String userId) async {
    return await firestore.collection('usuarios').doc(userId).get();
  }

  // Método para salvar dados no Firestore
  static Future<void> saveUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await firestore
        .collection('usuarios')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }
}
