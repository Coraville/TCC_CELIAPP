import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Lista de palavras proibidas (exemplo, adicione ou remova conforme necessário)
const List<String> forbiddenWords = [
  'palavrão1',
  'palavrão2',
  'xingamento1',
  'xingamento2', // Adicione os termos reais
  '@',
  '#',
  '%',
  '^',
  '&',
  '*',
  '!',
  '(',
  ')',
  '=',
  '-',
  '+',
  '}',
  '{',
  '[',
  ']',
  // Adicione outros símbolos que você deseja bloquear
];

bool containsForbiddenWords(String text) {
  text = text.toLowerCase();
  for (var word in forbiddenWords) {
    if (text.contains(word)) {
      return true;
    }
  }
  return false;
}

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({Key? key}) : super(key: key);

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [];

  // Variáveis para armazenar a imagem selecionada e as imagens disponíveis
  String? selectedImage; // A imagem selecionada
  final List<String> availableImages = [
    // Lista de imagens disponíveis
    'assets/BDReceitas/recipe1.jpg',
    'assets/BDReceitas/recipe2.jpg',
    'assets/BDReceitas/recipe3.jpg',
    'assets/BDReceitas/recipe4.jpg',
  ];

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Trate o caso de usuário não autenticado
        return;
      }

      final recipeRef = FirebaseFirestore.instance.collection('recipes').doc();
      await recipeRef.set({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anônimo',
        'createdAt': FieldValue.serverTimestamp(),
        'image': selectedImage, // Salvando a imagem selecionada no Firestore
      });

      for (var controller in _ingredientControllers) {
        final ingredient = controller.text.trim();
        if (ingredient.isNotEmpty) {
          await recipeRef.collection('ingredients').add({
            'name': ingredient,
            'authorId': user.uid,
          });
        }
      }

      // Após salvar, você pode navegar de volta ou mostrar uma mensagem de sucesso
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Receita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Receita'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da receita';
                  }
                  if (containsForbiddenWords(value)) {
                    return 'Nome da receita contém palavras proibidas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  if (containsForbiddenWords(value)) {
                    return 'Descrição contém palavras proibidas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Escolha uma imagem:'),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = availableImages[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = imagePath;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                selectedImage == imagePath
                                    ? Colors.orange
                                    : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Image.asset(
                          imagePath,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingredientes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._ingredientControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Ingrediente'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o ingrediente';
                      }
                      if (containsForbiddenWords(value)) {
                        return 'Ingrediente contém palavras proibidas';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addIngredientField,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Ingrediente'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitRecipe,
                child: const Text('Salvar Receita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
