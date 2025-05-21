import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListDetailPage extends StatefulWidget {
  final String listId;
  final String listName;

  const ListDetailPage({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> items = [];
  TextEditingController itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final doc =
        await firestore
            .collection('shopping_lists')
            .doc(user!.uid)
            .collection('user_lists')
            .doc(widget.listId)
            .get();

    final data = doc.data();
    if (data != null && data['items'] != null) {
      setState(() {
        items = List<Map<String, dynamic>>.from(data['items']);
      });
    }
  }

  Future<void> _toggleItem(int index, bool value) async {
    items[index]['checked'] = value;
    await _saveItems();
  }

  Future<void> _addItem(String name) async {
    if (name.trim().isEmpty) return;
    setState(() => items.add({'name': name, 'checked': false}));
    await _saveItems();
  }

  Future<void> _saveItems() async {
    await firestore
        .collection('shopping_lists')
        .doc(user!.uid)
        .collection('user_lists')
        .doc(widget.listId)
        .update({'items': items});
    setState(() {});
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Novo Item'),
            content: TextField(controller: itemController),
            actions: [
              TextButton(
                onPressed: () {
                  _addItem(itemController.text.trim());
                  itemController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Adicionar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: const Color(0xFFFF6E40),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = items[index];
          return CheckboxListTile(
            title: Text(item['name']),
            value: item['checked'],
            onChanged: (value) => _toggleItem(index, value!),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: Colors.deepOrangeAccent,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          final routes = [
            '/profile',
            '/map',
            '/recipes',
            '/shopping_list',
            '/info',
          ];
          Navigator.pushNamed(context, routes[index]);
        },
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
