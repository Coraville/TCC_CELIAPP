import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'avatar_selection_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  DateTime? _selectedDate;
  String? _avatarPath;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _register() async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': user.email,
          'avatar': _avatarPath ?? '',
          'birthdate':
              _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        });
      }
    } catch (e) {
      print('Erro no registro: $e');
    }
  }

  Future<void> _registerWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final snapshot = await userDoc.get();

        if (!snapshot.exists) {
          await userDoc.set({
            'name': user.displayName ?? '',
            'email': user.email,
            'avatar': user.photoURL ?? '',
            'birthdate': null,
          });
        }
      }
    } catch (e) {
      print('Erro no login com Google: $e');
    }
  }

  void _pickAvatar() async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => AvatarSelectionPage()),
    );

    if (selected != null) {
      setState(() {
        _avatarPath = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar =
        _avatarPath != null
            ? Image.asset(_avatarPath!, width: 80, height: 80)
            : const Icon(Icons.account_circle, size: 80);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            avatar,
            TextButton(
              onPressed: _pickAvatar,
              child: const Text('Selecionar Avatar'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _selectedDate != null
                      ? 'Nascimento: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                      : 'Data de nascimento não selecionada',
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Registrar'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar com Google'),
              onPressed: _registerWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}
