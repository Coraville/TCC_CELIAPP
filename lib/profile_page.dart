import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;
  bool hasAllergies = false;
  List<String> selectedAllergens = [];
  final TextEditingController nameController = TextEditingController(text: "Nome Sobrenome");
  final TextEditingController birthDateController = TextEditingController(text: "DD/MM/AA");
  final TextEditingController emailController = TextEditingController(text: "seuemail@email.com.br");
  final TextEditingController passwordController = TextEditingController(text: "****");
  final TextEditingController otherAllergenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      if (nameController.text == "Nome Sobrenome") nameController.clear();
    });
    birthDateController.addListener(() {
      if (birthDateController.text == "DD/MM/AA") birthDateController.clear();
    });
    emailController.addListener(() {
      if (emailController.text == "seuemail@email.com.br") emailController.clear();
    });
    passwordController.addListener(() {
      if (passwordController.text == "****") passwordController.clear();
    });
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

  void _selectAllergen() async {
    List<String> allergens = [
      "Glúten", "Lactose", "Amendoim", "Frutos do Mar", "Ovos", "Nozes",
      "Soja", "Peixe", "Trigo", "Gergelim", "Crustáceos", "Outros"
    ];
    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Selecione um alérgeno"),
          children: allergens.map((String allergen) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, allergen);
              },
              child: Text(allergen),
            );
          }).toList(),
        );
      },
    );
    if (selected != null) {
      if (selected == "Outros") {
        String? customAllergen = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Digite o alérgeno"),
              content: TextField(controller: otherAllergenController),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, otherAllergenController.text),
                  child: const Text("Adicionar"),
                ),
              ],
            );
          },
        );
        if (customAllergen != null && customAllergen.isNotEmpty) {
          setState(() {
            selectedAllergens.add(customAllergen);
          });
        }
      } else if (!selectedAllergens.contains(selected)) {
        setState(() {
          selectedAllergens.add(selected);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), backgroundColor: Colors.deepOrangeAccent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perfil',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepOrangeAccent),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nome")),
              TextField(controller: birthDateController, decoration: const InputDecoration(labelText: "Data de Nascimento")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "E-mail")),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Senha")),
              const SizedBox(height: 20),
              const Text("Alergias:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("Sim"),
                      value: true,
                      groupValue: hasAllergies,
                      onChanged: (bool? value) {
                        setState(() {
                          hasAllergies = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("Não"),
                      value: false,
                      groupValue: hasAllergies,
                      onChanged: (bool? value) {
                        setState(() {
                          hasAllergies = value!;
                          selectedAllergens.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (hasAllergies) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedAllergens.map((allergen) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Chip(
                        label: Text(allergen),
                        onDeleted: () {
                          setState(() {
                            selectedAllergens.remove(allergen);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.deepOrangeAccent),
                    onPressed: _selectAllergen,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Receitas'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista de Compras'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Informações'),
        ],
      ),
    );
  }
}
