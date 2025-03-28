import 'package:flutter/material.dart';
import 'loading_screen.dart'; // Importando a página de carregamento
import 'shopping_list_page.dart';
import 'profile_page.dart';
import 'map_page.dart';
import 'recipes_page.dart';
import 'info_page.dart';
import 'login_page.dart'; // Certifique-se de ter a página de login criada

void main() {
  runApp(const CeliApp());
}

class CeliApp extends StatelessWidget {
  const CeliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CeliApp',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(), // Tela de carregamento
        '/shopping_list': (context) => const ShoppingListPage(),
        '/profile': (context) => const ProfilePage(),
        '/map': (context) => const MapPage(),
        '/recipes': (context) => const RecipesPage(),
        '/info': (context) => const InfoPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}


