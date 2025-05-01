import 'dart:async';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _movementController;
  late List<Animation<double>> _lettersAnimations;

  final List<String> _text = ['C', 'e', 'l', 'i', 'A', 'p', 'p'];

  @override
  void initState() {
    super.initState();

    // Animação de rotação
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Animação de movimento horizontal
    _movementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Inicializa as animações para mover as letras
    _lettersAnimations = List.generate(_text.length, (index) {
      return Tween<double>(begin: 0.0, end: 30.0 * index.toDouble()).animate(
        CurvedAnimation(parent: _movementController, curve: Curves.easeOut),
      );
    });

    // Inicia a animação de movimento após a rotação
    Future.delayed(const Duration(seconds: 3), () {
      _movementController.forward();
    });

    // Após 6 segundos, navega para a próxima tela
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RecipesPage(),
        ), // Substitua pela tela desejada
      );
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _movementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      body: Stack(
        children: [
          // Animação do nome "CeliApp"
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle:
                          _rotationController.value *
                          2 *
                          3.1415927, // 360 graus
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_text.length, (index) {
                      return AnimatedBuilder(
                        animation: _lettersAnimations[index],
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _lettersAnimations[index].value),
                            child: child,
                          );
                        },
                        child: Text(
                          _text[index],
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Krona One',
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recipes Page")),
      body: const Center(child: Text("Welcome to Recipes Page!")),
    );
  }
}
