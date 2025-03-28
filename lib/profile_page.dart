import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/profile');
        break;
      case 1:
        Navigator.pushNamed(context, '/map');
        break;
      case 2:
        Navigator.pushNamed(context, '/recipes');
        break;
      case 3:
        Navigator.pushNamed(context, '/info'); // Navegação para Informações
        break;
      case 4:
        Navigator.pushNamed(context, '/shopping_list'); // Navegação para Lista de Compras
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), backgroundColor: Colors.deepOrangeAccent),
      body: const Center(child: Text('Página de Perfil')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Receitas'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista de Compras'), // Alterado para ícone de lista
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Informações'),
        ],
      ),
    );
  }
}

