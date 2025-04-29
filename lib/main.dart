import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CeliApp());
}

class CeliApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CeliApp',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => LoginPage(),
        '/loading': (context) => LoadingScreen(),
        '/recipes': (context) => RecipesPage(),
        '/shopping_list': (context) => ShoppingListPage(),
        '/map': (context) => MapPage(),
        '/profile': (context) => ProfilePage(),
        '/info': (context) => InfoPage(),
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
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return LoadingScreen();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

