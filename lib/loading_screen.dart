import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:celiapp/login_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<Offset>> _letterAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Tempo total da animação
      vsync: this,
    );

    _letterAnimations = List.generate(
      7,
          (index) {
        return Tween<Offset>(
          begin: Offset(0, -1), // Começa fora da tela
          end: Offset(0, 0), // Vai até a posição centralizada
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, (index + 1) * 0.1, curve: Curves.easeOut),
        ));
      },
    );

    _controller.forward();

    // Após 7 segundos de carregamento, navega para a página de login
    Future.delayed(const Duration(seconds: 7), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E1C1), // Fundo bege claro
      body: Stack(
        children: [
          // Ramo de trigo nos cantos
          Positioned(
            left: 20,
            top: 20,
            child: Icon(
              Icons.grain,
              color: const Color(0xFFF4E1C1),
              size: 40,
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Icon(
              Icons.grain,
              color: const Color(0xFFF4E1C1),
              size: 40,
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Icon(
              Icons.grain,
              color: const Color(0xFFF4E1C1),
              size: 40,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Icon(
              Icons.grain,
              color: const Color(0xFFF4E1C1),
              size: 40,
            ),
          ),

          // Animação da palavra CeliApp
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (index) {
                return SlideTransition(
                  position: _letterAnimations[index],
                  child: GestureDetector(
                    onTap: () {
                      // Animação de pulo ao clicar na letra
                      _controller.repeat();
                    },
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -10 * _controller.value),
                          child: Text(
                            'CeliApp'[index],
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
