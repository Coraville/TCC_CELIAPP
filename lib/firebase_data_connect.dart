import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDataConnect {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtém o UID do usuário autenticado
  String get userId => _auth.currentUser?.uid ?? '';

  // Salvar ou atualizar dados do usuário
  Future<void> salvarDadosUsuario({
    required String nome,
    required String avatar,
    required String aniversario,
  }) async {
    try {
      if (_auth.currentUser != null) {
        // Verifica se o usuário é do Google
        if (_auth.currentUser!.providerData.any(
          (userInfo) => userInfo.providerId == 'google.com',
        )) {
          final String nomeGoogle = _auth.currentUser?.displayName ?? nome;
          final String avatarGoogle = _auth.currentUser?.photoURL ?? avatar;

          // Salva ou atualiza os dados do usuário
          await _firestore.collection('usuarios').doc(userId).set({
            'nome': nomeGoogle,
            'avatar': avatarGoogle,
            'aniversario': aniversario,
            'email': _auth.currentUser?.email,
          }, SetOptions(merge: true));
        } else {
          // Caso não seja Google, usa os dados passados
          await _firestore.collection('usuarios').doc(userId).set({
            'nome': nome,
            'avatar': avatar,
            'aniversario': aniversario,
            'email': _auth.currentUser?.email,
          }, SetOptions(merge: true));
        }
      } else {
        throw FirebaseAuthException(
          code: 'USER_NOT_AUTHENTICATED',
          message: 'Usuário não autenticado',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Erro: ${e.code}, Mensagem: ${e.message}');
      rethrow;
    }
  }

  // Ler os dados do usuário
  Future<Map<String, dynamic>?> carregarDadosUsuario() async {
    try {
      if (_auth.currentUser != null) {
        final doc = await _firestore.collection('usuarios').doc(userId).get();
        return doc.exists ? doc.data() : null;
      } else {
        throw FirebaseAuthException(
          code: 'USER_NOT_AUTHENTICATED',
          message: 'Usuário não autenticado',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Erro: ${e.code}, Mensagem: ${e.message}');
      rethrow;
    }
  }

  // Criar uma nova lista de compras
  Future<void> criarListaDeCompras(String nomeLista) async {
    try {
      if (_auth.currentUser != null) {
        await _firestore
            .collection('usuarios')
            .doc(userId)
            .collection('listas')
            .add({
              'nome': nomeLista,
              'criado_em': FieldValue.serverTimestamp(),
            });
      } else {
        throw FirebaseAuthException(
          code: 'USER_NOT_AUTHENTICATED',
          message: 'Usuário não autenticado',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Erro: ${e.code}, Mensagem: ${e.message}');
      rethrow;
    }
  }

  // Listar todas as listas do usuário
  Stream<List<Map<String, dynamic>>> obterListasDeCompras() {
    try {
      if (_auth.currentUser != null) {
        return _firestore
            .collection('usuarios')
            .doc(userId)
            .collection('listas')
            .snapshots()
            .map(
              (snapshot) =>
                  snapshot.docs.map((doc) {
                    final data = doc.data();
                    data['id'] = doc.id;
                    return data;
                  }).toList(),
            );
      } else {
        throw FirebaseAuthException(
          code: 'USER_NOT_AUTHENTICATED',
          message: 'Usuário não autenticado',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Erro: ${e.code}, Mensagem: ${e.message}');
      rethrow;
    }
  }

  // Atualizar um item em uma lista
  Future<void> atualizarItemDaLista({
    required String listaId,
    required String itemId,
    required Map<String, dynamic> dados,
  }) async {
    try {
      if (_auth.currentUser != null) {
        await _firestore
            .collection('usuarios')
            .doc(userId)
            .collection('listas')
            .doc(listaId)
            .collection('itens')
            .doc(itemId)
            .update(dados);
      } else {
        throw FirebaseAuthException(
          code: 'USER_NOT_AUTHENTICATED',
          message: 'Usuário não autenticado',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Erro: ${e.code}, Mensagem: ${e.message}');
      rethrow;
    }
  }

  // Adicionar um item a uma lista
  Future<void> adicionarItemNaLista({
    required String listaId,
    required String nome,
    required bool comprado,
  }) async {
    try {
      if (_auth.currentUser != null) {
        await _firestore
            .collection('usuarios')
            .doc(userId)
            .collection('listas')
            .doc(listaId)
            .collection('itens')
            .add({
              'nome': nome,
              'comprado': comprado,
              'criado_em': FieldValue.serverTimestamp(),
            });
      } else {
        throw FirebaseAuthException(
          code: 'USER_NOT_AUTHENTICATED',
          message: 'Usuário não autenticado',
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Erro: ${e.code}, Mensagem: ${e.message}');
      rethrow;
    }
  }
}
