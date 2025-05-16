import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'recipes_page.dart';

// Lista de palavras proibidas
const List<String> forbiddenWords = [
  'puta', 'viado', 'caralho', 'vadia', 'cuzao', 'arrombado',
  'viadinho', 'merda', 'bosta', 'porra', '@', '#', '%', '^', '&',
  '*',
  '!',
  '=',
  '-',
  '}',
  '{',
  '[',
  ']', // Outros símbolos que você deseja bloquear
];

bool containsForbiddenWords(String text) {
  text = text.toLowerCase();
  text = text.replaceAll(RegExp(r'[^a-z0-9]'), '');
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
  final TextEditingController _preparationTime = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  String _selectedTimeUnit = 'Minutos';
  bool _isSubmitting = false;

  File? _imageFile;
  String? imageUrl;

  Future<void> _pickImage() async {
    // Verifica se o usuário está autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Caso não esteja autenticado, redireciona para a tela de login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, faça login para adicionar uma imagem.'),
        ),
      );
      // Redirecionar para a tela de login (ou apenas exibir a tela de login)
      return;
    }

    // Se o usuário estiver autenticado, permite escolher uma imagem
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      // Verifica se o usuário está autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Se o usuário não estiver autenticado, exibe uma mensagem e retorna null
        print('Usuário não autenticado');
        return null;
      }

      // Caso o usuário esteja autenticado, faz o upload da imagem
      final storageRef = FirebaseStorage.instance.ref().child(
        'recipe_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = storageRef.putFile(imageFile);
      final taskSnapshot = await uploadTask.whenComplete(() => null);
      final imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final validIngredients =
          _ingredientControllers
              .map((c) => c.text.trim())
              .where((i) => i.isNotEmpty)
              .toList();

      if (validIngredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicione pelo menos um ingrediente.')),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToFirebase(_imageFile!);
        }

        final recipeId =
            FirebaseFirestore.instance.collection('recipes').doc().id;
        final recipeRef = FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipeId);

        // Busca avatar do usuário na coleção 'users'
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        final avatar = userDoc.data()?['avatar'] ?? '';

        // Salva a receita principal no Firestore
        await recipeRef.set({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'authorId': user.uid,
          'authorName': user.displayName ?? 'Anônimo',
          'preparationTime': _preparationTime.text,
          'preparationTimeUnit': _selectedTimeUnit,
          'servings': int.parse(_servingsController.text),
          'createdAt': FieldValue.serverTimestamp(),
          'image': imageUrl,
          'userId': user.uid,
          'avatar': avatar,
        });

        // Salva os ingredientes associados à receita
        for (var ingredient in validIngredients) {
          await recipeRef.collection('ingredients').add({
            'name': ingredient,
            'authorId': user.uid,
            'userId': user.uid,
          });
        }

        _nameController.clear();
        _descriptionController.clear();
        _preparationTime.clear();
        _servingsController.clear();
        _ingredientControllers.clear();
        _imageFile = null;
        _selectedTimeUnit = 'Minutos';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita adicionada com sucesso!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RecipesPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar receita: $e')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _preparationTime.dispose();
    _servingsController.dispose();
    for (var c in _ingredientControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepOrangeAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Receita'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Receita'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira o nome';
                  if (containsForbiddenWords(value))
                    return 'Nome com palavras proibidas';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Insira a descrição';
                  if (containsForbiddenWords(value))
                    return 'Descrição com palavras proibidas';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child:
                    _imageFile != null
                        ? Image.file(
                          _imageFile!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.add_a_photo),
                        ),
              ),
              const SizedBox(height: 12),
              const Text('Ingredientes:'),
              ..._ingredientControllers.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: TextFormField(
                    controller: c,
                    decoration: const InputDecoration(labelText: 'Ingrediente'),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Insira um ingrediente';
                      if (containsForbiddenWords(v))
                        return 'Ingrediente com palavras proibidas';
                      return null;
                    },
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addIngredientField,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar ingrediente'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _preparationTime,
                decoration: const InputDecoration(
                  labelText: 'Tempo de preparo',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o tempo';
                  if (int.tryParse(v) == null) return 'Apenas números';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedTimeUnit,
                onChanged: (v) => setState(() => _selectedTimeUnit = v!),
                items:
                    ['Minutos', 'Horas', 'Dias']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _servingsController,
                decoration: const InputDecoration(labelText: 'Porções'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe as porções';
                  if (int.tryParse(v) == null) return 'Apenas números';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  onPressed: _isSubmitting ? null : _submitRecipe,
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text(
                            'Adicionar Receita',
                            style: TextStyle(color: Colors.white),
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
