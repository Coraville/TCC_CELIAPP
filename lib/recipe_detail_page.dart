import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
        backgroundColor: const Color(0xFFFF6E40),
      ),
      body: Center(
        child: Hero(
          tag: recipe['name'],
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Exibição da imagem da receita
                  Image.asset(
                    recipe['image'],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    recipe['name'],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Por: ${recipe['authorName']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Descrição: ${recipe['description']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < (recipe['rating'] ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.yellow[700],
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredientes:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Exibindo os ingredientes
                  FutureBuilder(
                    future: _getIngredients(
                      recipe['id'],
                    ), // Substitua pelo ID da receita
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Nenhum ingrediente encontrado.');
                      }

                      final ingredients = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(ingredients[index]['name']),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Função para buscar ingredientes de uma receita
  Future<List<Map<String, dynamic>>> _getIngredients(String recipeId) async {
    final ingredientsRef = FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .collection('ingredients');
    final snapshot = await ingredientsRef.get();

    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }
}
