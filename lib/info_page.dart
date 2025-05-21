import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int _selectedIndex = 4;

  Future<void> _openForm(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o link.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Função para abrir o link no navegador com confirmação
  Future<void> _confirmAndLaunchURL(BuildContext context) async {
    const url = 'https://www.fenacelbra.com.br/';
    final Uri uri = Uri.parse(url);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.deepOrange,
            child: const Text(
              'Atenção',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: const Text(
            'Você está saindo do aplicativo. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fechar a caixa de diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Fechar a caixa de diálogo
                try {
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!launched) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Não foi possível abrir o link.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao abrir o link: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
        title: const Text(''),
        backgroundColor: const Color(0xFFFF6E40),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // Link para o site da FENALCEBRA com TextButton para acessibilidade
            TextButton(
              onPressed: () => _confirmAndLaunchURL(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
              ),
              child: const Text(
                'Site Oficial da FENALCEBRA',
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 20),

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

            const Divider(color: Colors.grey, thickness: 1, height: 30),

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
            const Divider(color: Colors.grey, thickness: 1, height: 30),
            const Text(
              'Nutricionista consultado:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Vitor Correia Rodrigues - CRN: 77480 ',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => _openForm('https://forms.gle/Djv6kw67vBbE8a1u5'),
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              child: const Text(
                'Feedback',
                style: TextStyle(fontSize: 16, color: Colors.deepOrangeAccent),
              ),
            ),
            TextButton(
              onPressed:
                  () => _openForm(
                    'https://docs.google.com/forms/d/e/1FAIpQLSc0MeO0aU5YSVTHJw6d9XI88NfdXigIMgDKYus8j5p5RIZBCg/viewform',
                  ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Lista de Compras',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Informações'),
        ],
      ),
    );
  }
}
