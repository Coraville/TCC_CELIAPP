import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'shopping_list_page.dart'; // Tela principal após login

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? errorMessage;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShoppingListPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _page());
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Celiapp",
              style: TextStyle(
                fontFamily: 'Krona One',
                fontSize: 32,
                color: Colors.deepOrangeAccent,
              ),
            ),
            const SizedBox(height: 55),
            _inputField("e-mail", emailController),
            const SizedBox(height: 15),
            _inputField("senha", senhaController, isPassword: true),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            const SizedBox(height: 10),
            _registerBtn(),
            const SizedBox(height: 70),
            _loginRedirectBtn(),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String hintText,
    TextEditingController controller, {
    isPassword = false,
  }) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: const BorderSide(color: Colors.grey),
    );
    return TextField(
      style: const TextStyle(fontFamily: 'RobotoFlex', color: Colors.black),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'RobotoFlex',
          color: Colors.grey,
        ),
        enabledBorder: border,
        focusedBorder: border,
        isDense: true,
      ),
      obscureText: isPassword,
    );
  }

  Widget _registerBtn() {
    return TextButton(
      onPressed: isLoading ? null : _register,
      child:
          isLoading
              ? const CircularProgressIndicator()
              : const Text(
                'Registrar',
                style: TextStyle(
                  fontFamily: 'RobotoFlex',
                  color: Colors.deepOrangeAccent,
                  fontSize: 15,
                ),
              ),
    );
  }

  Widget _loginRedirectBtn() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context); // Volta para a tela de login
      },
      child: const Text(
        'Já tem uma conta? Faça login',
        style: TextStyle(
          fontFamily: 'RobotoFlex',
          color: Colors.deepOrangeAccent,
          fontSize: 15,
        ),
      ),
    );
  }
}
