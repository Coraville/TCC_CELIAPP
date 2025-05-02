import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:celiapp/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) text = text.substring(0, 8);

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;
  bool hasAllergies = false;
  List<String> selectedAllergens = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otherAllergenController = TextEditingController();

  String? selectedAvatar;
  final user = FirebaseAuth.instance.currentUser;

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: 10,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            String avatarPath = 'assets/avatares/avatar${index + 1}.png';
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAvatar = avatarPath;
                });
                Navigator.pop(context);
              },
              child: CircleAvatar(backgroundImage: AssetImage(avatarPath)),
            );
          },
        );
      },
    );
  }

  void _resetPassword() async {
    if (user?.email != null) {
      await authService.value.resetPassword(user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link de redefinição enviado para o e-mail.'),
        ),
      );
    }
  }

  void _logout() async {
    await authService.value.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final routes = ['/profile', '/map', '/recipes', '/shopping_list', '/info'];
    Navigator.pushNamed(context, routes[index]);
  }

  void _selectAllergen() async {
    List<String> allergens = [
      "Glúten",
      "Lactose",
      "Amendoim",
      "Frutos do Mar",
      "Ovos",
      "Nozes",
      "Soja",
      "Peixe",
      "Trigo",
      "Gergelim",
      "Crustáceos",
      "Outros",
    ];

    String? selected = await showDialog<String>(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: const Text("Selecione um alérgeno"),
            children:
                allergens
                    .map(
                      (a) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, a),
                        child: Text(a),
                      ),
                    )
                    .toList(),
          ),
    );

    if (selected != null) {
      if (selected == "Outros") {
        String? custom = await showDialog<String>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("Digite o alérgeno"),
                content: TextField(controller: otherAllergenController),
                actions: [
                  TextButton(
                    onPressed:
                        () => Navigator.pop(
                          context,
                          otherAllergenController.text,
                        ),
                    child: const Text("Adicionar"),
                  ),
                ],
              ),
        );
        if (custom != null && custom.isNotEmpty) {
          setState(() {
            selectedAllergens.add(custom);
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
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFFFF6E40),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _showAvatarOptions,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage:
                        selectedAvatar != null
                            ? AssetImage(selectedAvatar!)
                            : null,
                    child:
                        selectedAvatar == null
                            ? const Icon(Icons.person, size: 35)
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                if (user != null)
                  Expanded(
                    child: Text(
                      user!.email ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Perfil',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.deepOrangeAccent),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: birthDateController,
              decoration: const InputDecoration(
                labelText: "Data de Nascimento",
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                DateInputFormatter(),
              ],
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Alergias:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text("Sim"),
                    value: true,
                    groupValue: hasAllergies,
                    onChanged: (v) => setState(() => hasAllergies = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text("Não"),
                    value: false,
                    groupValue: hasAllergies,
                    onChanged:
                        (v) => setState(() {
                          hasAllergies = v!;
                          selectedAllergens.clear();
                        }),
                  ),
                ),
              ],
            ),
            if (hasAllergies)
              Column(
                children: [
                  ...selectedAllergens.map(
                    (a) => Chip(
                      label: Text(a),
                      onDeleted:
                          () => setState(() => selectedAllergens.remove(a)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.deepOrangeAccent,
                      ),
                      onPressed: _selectAllergen,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetPassword,
              icon: const Icon(Icons.lock_reset),
              label: const Text("Redefinir Senha"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Sair"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
              ),
            ),
          ],
        ),
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
            icon: Icon(Icons.list),
            label: 'Lista de Compras',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Informações'),
        ],
      ),
    );
  }
}
