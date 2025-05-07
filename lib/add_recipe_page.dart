import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Lista de palavras proibidas (exemplo, adicione ou remova conforme necessário)
const List<String> forbiddenWords = [
  'puta',
  'viado',
  'PUTA',
  'Caralho',
  'vadia',
  'cuzao',
  'arrombado',
  'viadinho',
  'merda',
  'bosta',
  'porra' // Adicione os termos reais
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
  text = text
      .replaceAll(RegExp(r'4'), 'a')
      .replaceAll(RegExp(r'0'), 'o')
      .replaceAll(RegExp(r'1'), 'i')
      .replaceAll(RegExp(r'3'), 'e')
      .replaceAll(RegExp(r'5'), 's')
      .replaceAll(RegExp(r'7'), 't');
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
    final primaryColor = Colors.deepOrangeAccent;

    return Scaffold(
      appBar: AppBar(title: const Text(''), backgroundColor: primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nova Receita',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nome da receita
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome da Receita',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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
              const SizedBox(height: 20),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                maxLines: 3,
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
              const SizedBox(height: 20),

              // Seleção de imagem
              const Text(
                'Escolha uma imagem:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
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
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                selectedImage == imagePath
                                    ? Colors.deepOrangeAccent
                                    : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Ingredientes
              const Text(
                'Ingredientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._ingredientControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Ingrediente',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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

              // Botão para adicionar ingrediente
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addIngredientField,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Ingrediente'),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
              ),

              const SizedBox(height: 20),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Salvar Receita',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
