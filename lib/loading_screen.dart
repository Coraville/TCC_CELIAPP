import 'dart:async';
import 'package:flutter/material.dart';
import 'recipes_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // Navega para a próxima tela após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecipesPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      body: Center(
        child: Image.asset(
          'assets/images/Trigo.png',
          width: 200, // Ajuste o tamanho conforme quiser
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
