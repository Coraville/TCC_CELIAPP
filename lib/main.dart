import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // Adicione essa importação
import 'firebase_options.dart';
import 'login_page.dart';
import 'loading_screen.dart';
import 'recipes_page.dart';
import 'shopping_list_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'info_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  runApp(const CeliApp());
}

class CeliApp extends StatelessWidget {
  const CeliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CeliApp',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/loading': (context) => const LoadingScreen(),
        '/recipes': (context) => const RecipesPage(),
        '/shopping_list': (context) => const ShoppingListPage(),
        '/map': (context) => const MapPage(),
        '/profile': (context) => const ProfilePage(),
        '/info': (context) => const InfoPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const LoadingScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
