import 'package:flutter/material.dart';
import 'shopping_list_page.dart';
import 'profile_page.dart';
import 'map_page.dart';
import 'recipes_page.dart';
import 'info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CeliApp',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ShoppingListPage(),
        '/profile': (context) => const ProfilePage(),
        '/map': (context) => const MapPage(),
        '/recipes': (context) => const RecipesPage(),
        '/info': (context) => const InfoPage(),
      },
    );
  }
}
