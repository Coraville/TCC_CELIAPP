import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'shopping_list_page.dart';
import 'map_page.dart';
import 'recipes_page.dart';
import 'profile_page.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int _selectedIndex = 3;

  // Função para abrir o link no navegador
  Future<void> _launchURL() async {
    const url = 'https://www.fenacelbra.com.br/'; // Link para o site oficial
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link';
    }
  }

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
        Navigator.pushNamed(context, '/shopping_list');
        break;
      case 4:
        Navigator.pushNamed(context, '/info');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Link para o site oficial
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: _launchURL,
              child: Text(
                'Site Oficial da FENALCEBRA',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Trecho da lei nº 10.674
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '''Lei nº 10.674 - Art. 1º
              Fica obrigatória a inclusão no rótulo dos produtos alimentícios, a informação sobre a presença de glúten em sua composição.''',
              style: TextStyle(fontSize: 16),
            ),
          ),

          // Linha separadora
          const Divider(color: Colors.grey, thickness: 1, height: 30),

          // Versão do aplicativo e créditos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Versão do aplicativo: 1.0',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Créditos dos desenvolvedores:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Arthur Vinicius Mendes dos Santos',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Carolina Mesquita dos Santos',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Laiz Preda Torres',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Mayra Olimpia Tavares',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista de Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Informações',
          ),
        ],
      ),
    );
  }
}


