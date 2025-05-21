// ... imports
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

  List<Map<String, dynamic>> allRecipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  String filterOption = 'Todas';

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot =
        await FirebaseFirestore.instance.collection('recipes').get();
    final favoritesSnapshot =
        await FirebaseFirestore.instance
            .collection('favorite_recipes')
            .where('userId', isEqualTo: user!.uid)
            .get();

    final favoriteRecipeIds =
        favoritesSnapshot.docs
            .map((doc) => doc.data()['recipeId'] as String)
            .toSet();

    setState(() {
      allRecipes =
          snapshot.docs.map((doc) {
            var data = doc.data();
            return {
              'name': data['name'],
              'user': data['authorName'],
              'rating': data['rating'] ?? 3,
              'image': data['image'],
              'docId': doc.id,
              'isFavorite': favoriteRecipeIds.contains(doc.id),
              'authorId': data['authorId'],
            };
          }).toList();
      _applyFilters();
    });
  }

  void _toggleFavorite(String docId, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('favorite_recipes')
        .doc('${user.uid}_$docId');

    if (isFavorite) {
      await favRef.delete();
    } else {
      await favRef.set({
        'userId': user.uid,
        'recipeId': docId,
        'favoritedAt': FieldValue.serverTimestamp(),
      });
    }
    _fetchRecipes();
  }

  void _applyFilters() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      if (filterOption == 'Todas') {
        filteredRecipes = List.from(allRecipes);
      } else if (filterOption == 'Minhas receitas') {
        filteredRecipes =
            allRecipes
                .where((recipe) => recipe['authorId'] == user!.uid)
                .toList();
      } else if (filterOption == 'Receitas favoritadas') {
        filteredRecipes =
            allRecipes.where((recipe) => recipe['isFavorite'] == true).toList();
      }
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
    final user = FirebaseAuth.instance.currentUser;

    List<Map<String, dynamic>> baseList;

    if (filterOption == 'Todas') {
      baseList = List.from(allRecipes);
    } else if (filterOption == 'Minhas receitas') {
      baseList =
          allRecipes
              .where((recipe) => recipe['authorId'] == user!.uid)
              .toList();
    } else if (filterOption == 'Receitas favoritadas') {
      baseList =
          allRecipes.where((recipe) => recipe['isFavorite'] == true).toList();
    } else {
      baseList = List.from(allRecipes);
    }

    setState(() {
      filteredRecipes =
          baseList
              .where(
                (recipe) =>
                    recipe['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar receitas...',
                border: OutlineInputBorder(),
              ),
              onChanged: _searchRecipes,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              isExpanded: true, // <- ESSENCIAL para evitar overflow
              value: filterOption,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.filter_list),
              items:
                  <String>[
                    'Todas',
                    'Minhas receitas',
                    'Receitas favoritadas',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        overflow:
                            TextOverflow.ellipsis, // evita texto muito longo
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    filterOption = newValue;
                    searchController
                        .clear(); // limpa a busca ao trocar o filtro
                  });
                  _applyFilters();
                }
              },
            ),
          ),
        ],
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
                      builder:
                          (_) => RecipeDetailPage(
                            recipe: recipe,
                            recipeId:
                                recipe['docId'], // Passando o ID da receita correto
                          ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                        child:
                            recipe['image'] != null
                                ? Image.network(
                                  recipe['image'],
                                  fit: BoxFit.cover,
                                )
                                : const Icon(Icons.image, size: 50),
                      ),
                    ),
                    title: Text(recipe['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text('Por: ${recipe['user']}')],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        recipe['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed:
                          () => _toggleFavorite(
                            recipe['docId'],
                            recipe['isFavorite'],
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
