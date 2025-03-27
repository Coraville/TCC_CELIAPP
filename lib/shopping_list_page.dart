import 'package:flutter/material.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<Map<String, dynamic>> shoppingLists = []; // Lista de listas de compras
  TextEditingController listNameController = TextEditingController(); // Controlador para nome da lista
  TextEditingController itemController = TextEditingController(); // Controlador para itens de compras

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
    );
  }

  // Botão para criar nova lista
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

  // Exibe o diálogo para criar nova lista
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

  // Exibe a lista de compras
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

  // Exibe o diálogo para editar o nome da lista
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

  // Exibe o diálogo para adicionar um item à lista
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