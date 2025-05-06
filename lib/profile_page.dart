import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:celiapp/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otherAllergenController = TextEditingController();
  List<String> selectedAllergens = [];

  String? selectedAvatar;
  int _selectedIndex = 0;
  String? email;

  List<String> avatarPaths = List.generate(
    10,
    (index) => 'assets/avatares/avatar${index + 1}.png',
  );

  bool avatarChanged = false;

  final List<String> predefinedAllergens = [
    'Glúten',
    'Lactose',
    'Ovos',
    'Amendoim',
    'Frutos do Mar',
    'Soja',
    'Nozes',
    'Trigo',
    'Peixe',
    'Milho',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = auth.currentUser;
    if (user == null) return;

    final doc = await firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nameController.text = data['name'] ?? '';
        selectedAvatar = data['avatar'] ?? avatarPaths[0];
        birthdayController.text = data['birthday'] ?? '';
        email = user.email;
        emailController.text = email ?? '';
        selectedAllergens = List<String>.from(data['allergens'] ?? []);
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = auth.currentUser;
    if (user == null) return;

    final birthday = birthdayController.text;
    final dateFormat = DateFormat('dd/MM/yyyy');
    try {
      final parsedDate = dateFormat.parseStrict(birthday);
      final currentYear = DateTime.now().year;
      final birthYear = parsedDate.year;

      if (birthYear < 1900 || birthYear > currentYear) {
        throw FormatException('Data inválida');
      }

      await firestore.collection('users').doc(user.uid).set({
        'name': nameController.text,
        'avatar': selectedAvatar,
        'birthday': birthday,
        'allergens': selectedAllergens,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil salvo com sucesso')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data de nascimento inválida')),
      );
    }
  }

  void _logout() async {
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
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

  void _showAvatarOptions() {
    String? tempSelectedAvatar = selectedAvatar;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Escolha seu avatar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: avatarPaths.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final path = avatarPaths[index];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempSelectedAvatar = path;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    tempSelectedAvatar == path
                                        ? Colors.deepOrangeAccent
                                        : Colors.transparent,
                                width: 3,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(path),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (tempSelectedAvatar != null) {
                        setState(() {
                          selectedAvatar = tempSelectedAvatar;
                        });
                        _saveProfile();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                    child: const Text(
                      'Salvar Avatar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _avatarIcon() {
    return GestureDetector(
      onTap: _showAvatarOptions,
      child: CircleAvatar(
        radius: 40,
        backgroundImage:
            selectedAvatar != null
                ? AssetImage(selectedAvatar!)
                : const AssetImage('assets/avatares/avatar1.png'),
      ),
    );
  }

  Widget _buildOtherAllergenInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: otherAllergenController,
            decoration: const InputDecoration(labelText: 'Outro alérgeno'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            final other = otherAllergenController.text.trim();
            if (other.isNotEmpty && !selectedAllergens.contains(other)) {
              setState(() {
                selectedAllergens.add(other);
                otherAllergenController.clear();
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedAvatar == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFFFF6E40),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                _avatarIcon(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nameController.text,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Editar Nome'),
                          content: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                              child: const Text('Salvar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(labelText: 'Aniversário'),
              keyboardType: TextInputType.datetime,
              inputFormatters: [MaskTextInputFormatter(mask: '##/##/####')],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Alérgenos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children:
                  selectedAllergens
                      .map(
                        (a) => Chip(
                          label: Text(a),
                          onDeleted: () {
                            setState(() {
                              selectedAllergens.remove(a);
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            _buildOtherAllergenInput(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
              ),
              child: const Text(
                'Salvar Perfil',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
              ),
              child: const Text('Sair', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFF6E40),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Receitas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'shopping_cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        ],
      ),
    );
  }
}
