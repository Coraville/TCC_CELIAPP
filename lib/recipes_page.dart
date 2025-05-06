import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_detail_page.dart';
import 'add_recipe_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  int _selectedIndex = 2;
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot =
        await FirebaseFirestore.instance.collection('recipes').get();
    setState(() {
      filteredRecipes =
          snapshot.docs.map((doc) {
            var data = doc.data();
            return {
              'name': data['name'],
              'user': data['authorName'],
              'rating': data['rating'] ?? 3, // Default to 3 stars if no rating
              'image':
                  'assets/BDReceitas/recipe_${doc.id}.png', // Use the image from assets
              'docId': doc.id,
            };
          }).toList();
    });
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
        _fetchRecipes(); // Fetch all recipes if search is cleared
      } else {
        filteredRecipes =
            filteredRecipes
                .where(
                  (recipe) => recipe['name'].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

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
            onPressed: () => _searchRecipes(searchController.text),
          ),
        ),
        onChanged: (query) => _searchRecipes(query),
      ),
    );
  }

  Widget _createNewRecipeButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipePage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrangeAccent,
        ),
        child: const Text(
          'Criar Nova Receita',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFFF6E40),
            floating: true,
            snap: true,
            pinned: true,
            expandedHeight: 50,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('', style: TextStyle(fontSize: 20)),
              background: ColoredBox(color: Color(0xFFFF6E40)),
            ),
          ),
          SliverToBoxAdapter(child: _searchField()),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final recipe = filteredRecipes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(recipe: recipe),
                    ),
                  );
                },
                child: Hero(
                  tag: recipe['name'], // Hero tag for animation
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          recipe['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(recipe['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Por: ${recipe['user']}'),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < recipe['rating']
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.yellow[700],
                                size: 20,
                              );
                            }),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.favorite_border, color: Colors.red),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              );
            }, childCount: filteredRecipes.length),
          ),
          SliverToBoxAdapter(child: _createNewRecipeButton()),
        ],
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
            icon: Icon(Icons.shopping_cart),
            label: 'Lista de Compras',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Informações'),
        ],
      ),
    );
  }
}
