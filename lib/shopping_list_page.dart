import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  TextEditingController itemController = TextEditingController();

  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadShoppingLists();
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

  Future<void> _addItemToList(int index, String itemName) async {
    if (itemName.isEmpty || user == null) return;

    final list = shoppingLists[index];
    final newItem = {'name': itemName, 'checked': false};

    setState(() {
      list['items'].add(newItem);
    });

    try {
      await firestore
          .collection('shopping_lists')
          .doc(user!.uid)
          .collection('user_lists')
          .doc(list['id'])
          .update({'items': list['items']});
    } catch (e) {
      print("Erro ao adicionar item: $e");
    }
  }

  Future<void> _toggleItem(int listIndex, int itemIndex, bool value) async {
    shoppingLists[listIndex]['items'][itemIndex]['checked'] = value;

    try {
      await firestore
          .collection('shopping_lists')
          .doc(user!.uid)
          .collection('user_lists')
          .doc(shoppingLists[listIndex]['id'])
          .update({'items': shoppingLists[listIndex]['items']});
    } catch (e) {
      print("Erro ao atualizar item: $e");
    }

    setState(() {});
  }

  Future<void> _deleteList(int index) async {
    try {
      await firestore
          .collection('shopping_lists')
          .doc(user!.uid)
          .collection('user_lists')
          .doc(shoppingLists[index]['id'])
          .delete();

      setState(() {
        shoppingLists.removeAt(index);
      });
    } catch (e) {
      print("Erro ao deletar lista: $e");
    }
  }

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

  Widget _createNewListButton() {
    return TextButton(
      onPressed: () => _showNewListDialog(),
      child: const Text(
        'Criar Nova Lista',
        style: TextStyle(color: Colors.deepOrangeAccent),
      ),
    );
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
                _createNewList(listNameController.text);
                listNameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Criar'),
            ),
            TextButton(
              onPressed: () {
                listNameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Item'),
          content: TextField(controller: itemController),
          actions: [
            TextButton(
              onPressed: () {
                _addItemToList(index, itemController.text);
                itemController.clear();
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
            TextButton(
              onPressed: () {
                itemController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _shoppingLists() {
    return Expanded(
      child: ListView.builder(
        itemCount: shoppingLists.length,
        itemBuilder: (context, index) {
          final list = shoppingLists[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(list['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < list['items'].length; i++)
                    Row(
                      children: [
                        Checkbox(
                          value: list['items'][i]['checked'],
                          onChanged: (value) {
                            _toggleItem(index, i, value!);
                          },
                        ),
                        Text(list['items'][i]['name']),
                      ],
                    ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteList(index),
              ),
              onTap: () => _showAddItemDialog(index),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFFFF6E40),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _createNewListButton(),
          const SizedBox(height: 20),
          _shoppingLists(),
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
