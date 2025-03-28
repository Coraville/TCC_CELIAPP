import 'package:flutter/material.dart';
import 'map_page.dart';
import 'recipes_page.dart';
import 'profile_page.dart';
import 'info_page.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<Map<String, dynamic>> shoppingLists = [];
  TextEditingController listNameController = TextEditingController();
  TextEditingController itemController = TextEditingController();

  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _createNewListButton(),
          const SizedBox(height: 20),
          Expanded(child: _shoppingLists()),
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
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista de Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Informações',
          ),
        ],
      ),
    );
  }

  Widget _createNewListButton() {
    return TextButton(
      onPressed: () {
        _showNewListDialog();
      },
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
          content: TextField(
            controller: listNameController,
            decoration: const InputDecoration(hintText: 'Digite o nome da lista'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  shoppingLists.add({'name': listNameController.text, 'items': []});
                });
                listNameController.clear();
                Navigator.pop(context);
              },
              child: const Text('Criar'),
            ),
            TextButton(
              onPressed: () {
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
    return ListView.builder(
      itemCount: shoppingLists.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            title: Text(shoppingLists[index]['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var item in shoppingLists[index]['items'])
                  Row(
                    children: [
                      Checkbox(
                        value: item['checked'],
                        onChanged: (bool? value) {
                          setState(() {
                            item['checked'] = value!;
                          });
                        },
                      ),
                      Text(item['name']),
                    ],
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditListDialog(index),
            ),
            onTap: () => _showAddItemDialog(index),
          ),
        );
      },
    );
  }

  void _showEditListDialog(int index) {
    TextEditingController editController = TextEditingController(text: shoppingLists[index]['name']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Nome da Lista'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Digite o novo nome da lista'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  shoppingLists[index]['name'] = editController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
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
          title: const Text('Adicionar Item à Lista'),
          content: TextField(
            controller: itemController,
            decoration: const InputDecoration(hintText: 'Digite o nome do item'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  shoppingLists[index]['items'].add({'name': itemController.text, 'checked': false});
                });
                itemController.clear();
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}





