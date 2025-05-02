import 'package:flutter/material.dart';
import 'shopping_list_page.dart';
import 'profile_page.dart';
import 'map_page.dart';
import 'info_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  int _selectedIndex = 2;
  TextEditingController searchController = TextEditingController();

  // Lista fictícia de receitas
  List<Map<String, dynamic>> allRecipes = [
    {
      'name': 'Bolo de Cenoura',
      'user': 'João Silva',
      'rating': 4,
      'saved': false,
    },
    {'name': 'Feijoada', 'user': 'Maria Oliveira', 'rating': 5, 'saved': false},
    {
      'name': 'Sopa de Legumes',
      'user': 'Carlos Almeida',
      'rating': 3,
      'saved': false,
    },
  ];

  List<Map<String, dynamic>> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    filteredRecipes = allRecipes;
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

  void _searchRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRecipes = allRecipes;
      } else {
        filteredRecipes =
            allRecipes
                .where(
                  (recipe) => recipe['name'].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  void _showCreateRecipeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Criar Nova Receita'),
          content: const Text(
            'Aqui será a lógica para criar uma nova receita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o popup
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), backgroundColor: Color(0xFFFF6E40)),
      body: Column(
        children: [_searchField(), _recipeList(), _createNewRecipeButton()],
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

  // Campo de pesquisa
  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Pesquisar receitas...',
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _searchRecipes(searchController.text);
            },
          ),
        ),
        onChanged: (query) {
          _searchRecipes(query);
        },
      ),
    );
  }

  // Lista de receitas compartilhadas
  Widget _recipeList() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = filteredRecipes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(recipe['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Por: ${recipe['user']}'),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < recipe['rating'] ? Icons.star : Icons.star_border,
                        color: Colors.yellow[700],
                        size: 20,
                      );
                    }),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  recipe['saved'] ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    recipe['saved'] = !recipe['saved'];
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Botão para criar uma nova receita
  Widget _createNewRecipeButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          _showCreateRecipeDialog(); // Abre o popup de criação de nova receita
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors
                  .deepOrangeAccent, // Substituí "primary" por "backgroundColor"
        ),
        child: const Text('Criar Nova Receita'),
      ),
    );
  }
}
