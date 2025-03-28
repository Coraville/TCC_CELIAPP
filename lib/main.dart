import 'package:flutter/material.dart';
import 'shopping_list_page.dart';
import 'profile_page.dart';
import 'map_page.dart';
import 'recipes_page.dart';
import 'info_page.dart';

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
      initialRoute: '/info',
      routes: {
        '/shopping_list': (context) => const ShoppingListPage(),
        '/profile': (context) => const ProfilePage(),
        '/map': (context) => const MapPage(),
        '/recipes': (context) => const RecipesPage(),
        '/info': (context) => const InfoPage(),
      },
    );
  }
}

