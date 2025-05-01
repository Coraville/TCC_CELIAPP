import 'dart:async';
import 'package:flutter/material.dart';
import 'recipes_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final List<String> _text = ['C', 'e', 'l', 'i', 'A', 'p', 'p'];

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              _text.map((letter) {
                return Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Krona One',
                    color: Colors.deepOrangeAccent,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
