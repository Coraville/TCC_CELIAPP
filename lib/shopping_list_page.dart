// shopping_list_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'list_detail.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> shoppingLists = [];
  TextEditingController listNameController = TextEditingController();

  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadShoppingLists();
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

  void _loadShoppingLists() async {
    if (user == null) return;
    try {
      final snapshot =
          await firestore
              .collection('shopping_lists')
              .doc(user!.uid)
              .collection('user_lists')
              .get();

      setState(() {
        shoppingLists =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'name': data['name'],
                'items': List<Map<String, dynamic>>.from(data['items'] ?? []),
              };
            }).toList();
      });
    } catch (e) {
      print("Erro ao carregar listas: $e");
    }
  }

  Future<void> _createNewList(String name) async {
    if (name.isEmpty || user == null) return;
    try {
      final docRef = await firestore
          .collection('shopping_lists')
          .doc(user!.uid)
          .collection('user_lists')
          .add({'name': name, 'items': []});

      setState(() {
        shoppingLists.add({'id': docRef.id, 'name': name, 'items': []});
      });
    } catch (e) {
      print("Erro ao criar lista: $e");
    }
  }

  Future<void> _renameList(int index, String newName) async {
    if (newName.isEmpty || user == null) return;
    final id = shoppingLists[index]['id'];
    try {
      await firestore
          .collection('shopping_lists')
          .doc(user!.uid)
          .collection('user_lists')
          .doc(id)
          .update({'name': newName});
      setState(() => shoppingLists[index]['name'] = newName);
    } catch (e) {
      print("Erro ao renomear lista: $e");
    }
  }

  Future<void> _deleteList(int index) async {
    final id = shoppingLists[index]['id'];
    try {
      await firestore
          .collection('shopping_lists')
          .doc(user!.uid)
          .collection('user_lists')
          .doc(id)
          .delete();
      setState(() => shoppingLists.removeAt(index));
    } catch (e) {
      print("Erro ao deletar lista: $e");
    }
  }

  void _showNewListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nome da Nova Lista'),
          content: TextField(controller: listNameController),
          actions: [
            TextButton(
              onPressed: () {
                listNameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _createNewList(listNameController.text);
                listNameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameDialog(int index) {
    final controller = TextEditingController(
      text: shoppingLists[index]['name'],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Renomear Lista'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _renameList(index, controller.text);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListCard(int index) {
    final list = shoppingLists[index];
    final items = list['items'] as List<dynamic>;
    final total = items.length;
    final checked = items.where((item) => item['checked'] == true).length;
    final percent = total == 0 ? 0 : (checked / total * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          list['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Concluído: $percent%'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'renomear') {
              _showRenameDialog(index);
            } else if (value == 'excluir') {
              _deleteList(index);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'renomear', child: Text('Renomear')),
                const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
              ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ListDetailPage(
                    listId: list['id'],
                    listName: list['name'],
                  ),
            ),
          );
          _loadShoppingLists(); // Recarrega as listas e porcentagens ao voltar
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFFF6E40)),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showNewListDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Criar Nova Lista'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: shoppingLists.length,
              itemBuilder: (context, index) => _buildListCard(index),
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
