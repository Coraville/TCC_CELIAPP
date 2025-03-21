import 'package:flutter/material.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _page(),
    );
  }

  Widget _page() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Alinha ao centro verticalmente
        children: [
          const Text('Nome da lista'),
          _checkbox(), // Adicionando vírgula que faltava
          const Divider(), // Adicionando const para otimizar performance
        ],
      ),
    );
  }

  Widget _checkbox() {
    return Center(
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.grey,
        ),
        child: CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Example'),
          value: isChecked,
          onChanged: (value) {
            setState(() => isChecked = value!);
          },
          activeColor: Colors.deepOrangeAccent,
          checkColor: Colors.white,
        ),
      ),
    );
  }
}