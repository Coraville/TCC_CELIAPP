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
    return Scaffold(backgroundColor: Colors.white, body: _page());
  }

  Widget _page(){
    child: Center(
      child: Column(
        children: [
          const Text(
            'Nome da lista'
          )
          _checkbox(),
          Divider(),
        ]
      )
    )
  }

  Widget _checkbox(
    body: Center(
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.grey,
        ),
      child: CheckBoxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('example'),
        value: isChecked,
        onChanged: (value) {
          setState(() => isChecked = value!);
        },
        activeColor: Colors.deepOrangeAccent,
        checkColor: Colors.white,
      ),
      )
    );
  )

}