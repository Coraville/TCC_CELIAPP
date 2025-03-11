import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _page(),
    );
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          _inputField("e-mail", emailController),
          const SizedBox(height:50),
          _inputField("senha", senhaController, isPassword: true),
          const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller, 
    {isPassword = false}){
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Colors.grey)
    );
    return TextField(
      style: const TextStyle(color: Colors.grey),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: border,
        focusedBorder: border
      ),
      obscureText: isPassword,
    );
  }
}