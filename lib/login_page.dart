import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'shopping_list_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String? errorMessage;
  bool _obscureText = true; // Controla a visibilidade da senha

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
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

  Future<void> _loginWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShoppingListPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        errorMessage = "Erro inesperado ao fazer login com o Google.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 60),
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
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _loginBtn(),
                        _forgotpass(),
                        const SizedBox(height: 20),
                        _bottomRegisterText(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30, top: 20),
                      child: Column(
                        children: [
                          const Text(
                            'Logar com',
                            style: TextStyle(
                              fontFamily: 'RobotoFlex',
                              fontSize: 16,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _socialLoginIcons(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
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
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
      ),
      obscureText: isPassword ? _obscureText : false,
    );
  }

  Widget _loginBtn() {
    return ElevatedButton(
      onPressed: isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrangeAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child:
          isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                'LOGIN',
                style: TextStyle(
                  fontFamily: 'RobotoFlex',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
    );
  }

  void _showPasswordResetDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Redefinir senha',
            style: TextStyle(fontFamily: 'RobotoFlex'),
          ),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(hintText: 'Digite seu e-mail'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
              ),
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, insira um e-mail válido.'),
                    ),
                  );
                  return;
                }
                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('E-mail de redefinição enviado!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? 'Erro ao enviar e-mail.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Enviar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _forgotpass() {
    return TextButton(
      onPressed: () {
        _showPasswordResetDialog();
      },
      child: const Text(
        'Esqueceu a senha?',
        style: TextStyle(
          fontFamily: 'RobotoFlex',
          color: Colors.deepOrangeAccent,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _socialLoginIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            // TODO: Implementar login com Facebook
          },
          icon: Image.asset(
            'assets/images/facebook_logo.png',
            height: 40,
            width: 40,
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: isLoading ? null : _loginWithGoogle,
          icon: Image.asset(
            'assets/images/google_logo.png',
            height: 40,
            width: 40,
          ),
        ),
      ],
    );
  }

  Widget _bottomRegisterText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Ainda não é cadastrado? ',
          style: TextStyle(
            fontFamily: 'RobotoFlex',
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistroPage()),
            );
          },
          child: const Text(
            'Comece agora!',
            style: TextStyle(
              fontFamily: 'RobotoFlex',
              fontSize: 15,
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
