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
            const SizedBox(height: 10),
            _loginBtn(),
            const SizedBox(height: 70),
            _registerBtn(),
            _forgotpass()
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

  Widget _loginBtn(){
    return TextButton(
        onPressed: (){
          debugPrint("email : ${emailController.text}" );
          debugPrint("senha : ${senhaController.text}" );
        },
        child: const Text('login', style: TextStyle(
            fontFamily: 'RobotoFlex',
            color: Colors.deepOrangeAccent,
          fontSize: 15
        )
      )
    );
  }

  Widget _registerBtn(){
    return TextButton(
        onPressed: (){},
        child: const Text('registre-se', style: TextStyle(
            fontFamily: 'RobotoFlex',
            color: Colors.deepOrangeAccent,
            fontSize: 15
        )
        )
    );
  }

  Widget _forgotpass(){
    return TextButton(
        onPressed: (){},
        child: const Text('esqueceu a senha?', style: TextStyle(
            fontFamily: 'RobotoFlex',
            color: Colors.deepOrangeAccent,
            fontSize: 15
        )
        )
    );
  }
}
