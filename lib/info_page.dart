import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'recipes_page.dart';
import 'shopping_list_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'info_page.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int _selectedIndex = 4;

  // Função para abrir o link no navegador
  Future<void> _launchURL() async {
    const url = 'https://www.fenacelbra.com.br/';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Não foi possível abrir o link';
      }
    } catch (e) {
      print("Erro ao abrir URL: $e");
      // Exibir um alerta ou um Snackbar para o usuário
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
      appBar: AppBar(title: const Text(''), backgroundColor: Color(0xFFE38854)),
      body: SingleChildScrollView(
        // Adicionando rolagem
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinha tudo à esquerda
          children: [
            // Título "Informações"
            const Text(
              'Informações',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Link para o site da FENALCEBRA
            GestureDetector(
              onTap: _launchURL,
              child: const Text(
                'Site Oficial da FENALCEBRA',
                style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Trecho da lei
            const Text(
              'LEI N° 10.674',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'ART. 1°',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Fica obrigatória a inclusão no rótulo dos produtos alimentícios, a informação sobre a presença de glúten em sua composição.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),

            // Linha separadora
            const Divider(color: Colors.grey, thickness: 1, height: 30),

            // Versão do aplicativo e créditos
            const Text('CeliApp v1.0', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            const Text(
              'Desenvolvido por:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Arthur Vinicius Mendes dos Santos',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Carolina Mesquita dos Santos',
              style: TextStyle(fontSize: 16),
            ),
            const Text('Laiz Preda Torres', style: TextStyle(fontSize: 16)),
            const Text('Mayra Olimpia Tavares', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              child: const Text(
                'Feedback',
                style: TextStyle(fontSize: 16, color: Colors.deepOrangeAccent),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              child: const Text(
                'Reportar Bug',
                style: TextStyle(fontSize: 16, color: Colors.deepOrangeAccent),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Receitas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista de Compras',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Informações'),
        ],
      ),
    );
  }
}
