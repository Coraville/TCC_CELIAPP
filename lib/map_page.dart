import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _selectedIndex = 1;

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
        Navigator.pushNamed(context, '/info');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa'), backgroundColor: Colors.deepOrangeAccent),
      body: const Center(child: Text('Página do Mapa')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Receitas'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Compras'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Informações'),
        ],
      ),
    );
  }
}