import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'recipes_page.dart'; // Importa a página de receitas
import 'shopping_list_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'info_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // Após 6 segundos, navega para a página de receitas
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecipesPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E1C1), // Fundo bege claro
      body: Stack(
        children: [
          // Ramo de trigo no canto superior esquerdo (espelhado horizontalmente)
          Positioned(
            left: 20,
            top: 20,
            child: Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..scale(-1.0, 1.0), // Espelhamento horizontal
              child: Image.asset(
                'assets/images/trigo.png',
                width: 150,
                height: 150,
              ),
            ),
          ),

          // Ramo de trigo no canto inferior direito (rotacionado 90°)
          Positioned(
            right: 20,
            bottom: 20,
            child: Transform.rotate(
              angle: 1.5708, // 90 graus em radianos
              child: Image.asset(
                'assets/images/trigo.png',
                width: 150,
                height: 150,
              ),
            ),
          ),

          // Animação do nome "CeliApp"
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [WavyAnimatedText('CeliApp')],
                    isRepeatingAnimation: false, // Executa uma única vez
                  ),
                ),
                const SizedBox(height: 30),

                // Indicador de carregamento simples
                const CircularProgressIndicator(color: Colors.deepOrangeAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
