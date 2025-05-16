import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({
    required this.recipeId,
    required this.recipe,
    Key? key,
  }) : super(key: key);

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('recipes')
              .doc(widget.recipeId)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Receita não encontrada.'));
        }

        final recipe = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              recipe['name'] ?? 'Detalhes da Receita',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.deepOrangeAccent,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      recipe['image'] != null &&
                              recipe['image'].toString().isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              recipe['image'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[300],
                            ),
                            child: const Center(
                              child: Icon(Icons.image, size: 60),
                            ),
                          ),
                      const SizedBox(height: 16),
                      Text(
                        recipe['name'] ?? 'Sem nome',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe['preparationTime'] != null
                            ? '${recipe['preparationTime']} ${recipe['preparationTimeUnit'] ?? ''} • ${recipe['servings'] ?? '1'} porções'
                            : 'Sem tempo de preparo • ${recipe['servings'] ?? '1'} porções',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (recipe['avatar'] != null &&
                              recipe['avatar'].toString().isNotEmpty)
                            CircleAvatar(
                              backgroundImage: AssetImage(recipe['avatar']),
                              radius: 16,
                            )
                          else
                            const CircleAvatar(
                              radius: 16,
                              child: Icon(Icons.person, size: 16),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recipe['authorName'] ?? 'Autor desconhecido',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              FutureBuilder<int>(
                                future: _getLikesCount(widget.recipeId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text('...');
                                  }
                                  if (snapshot.hasError) {
                                    return const Text('Erro');
                                  }
                                  final count = snapshot.data ?? 0;
                                  return Text('$count likes');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      const Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (recipe['description'] != null)
                        Text(
                          recipe['description'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey[300]),
                      const Text(
                        'Ingredientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _getIngredients(widget.recipeId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Nenhum ingrediente encontrado.');
                          }
                          return Column(
                            children:
                                snapshot.data!.map((ingredient) {
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.check,
                                      color: Colors.deepOrangeAccent,
                                    ),
                                    title: Text(ingredient['name']),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const Text(
                        'Comentários',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('recipes')
                                .doc(widget.recipeId)
                                .collection('comments')
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final comments = snapshot.data!.docs;

                          if (comments.isEmpty) {
                            return const Text('Nenhum comentário ainda.');
                          }

                          return ListView.builder(
                            itemCount: comments.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final comment =
                                  comments[index].data()
                                      as Map<String, dynamic>;
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      (comment['avatar'] != null &&
                                              comment['avatar']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? AssetImage(comment['avatar'])
                                          : null,
                                  child:
                                      (comment['avatar'] == null ||
                                              comment['avatar']
                                                  .toString()
                                                  .isEmpty)
                                          ? const Icon(Icons.person, size: 16)
                                          : null,
                                ),
                                title: Text(comment['text']),
                                subtitle: Text(
                                  comment['author'] ?? 'Anônimo',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Escreva um comentário...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.deepOrangeAccent,
                            ),
                            onPressed: () => _addComment(widget.recipeId),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                icon: Icon(Icons.qr_code_scanner),
                label: 'Scanner',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Receitas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Lista de Compras',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: 'Informações',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> _getLikesCount(String recipeId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('favorite_recipes')
            .where('recipeId', isEqualTo: recipeId)
            .get();
    return snapshot.docs.length;
  }

  Future<List<Map<String, dynamic>>> _getIngredients(String recipeId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipeId)
            .collection('ingredients')
            .get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  void _addComment(String recipeId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty || user == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

    final name =
        userDoc.data()?['nome'] ??
        user!.displayName ??
        user!.email ??
        'Anônimo';
    final avatar = userDoc.data()?['avatar'];

    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .collection('comments')
        .add({
          'text': text,
          'author': name,
          'avatar': avatar,
          'timestamp': FieldValue.serverTimestamp(),
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Comentário adicionado!')));
    _commentController.clear();
  }
}
