import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final _dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  String _genero = '';
  bool _isSenhaVisible = false;
  bool _isConfirmarSenhaVisible = false;
  String? selectedAvatar = 'assets/avatares/avatar1.png';

  final List<String> avatarPaths = [
    'assets/avatares/avatar1.png',
    'assets/avatares/avatar2.png',
    'assets/avatares/avatar3.png',
    'assets/avatares/avatar4.png',
    'assets/avatares/avatar5.png',
    'assets/avatares/avatar6.png',
    'assets/avatares/avatar7.png',
    'assets/avatares/avatar8.png',
    'assets/avatares/avatar9.png',
    'assets/avatares/avatar10.png',
    'assets/avatares/avatar11.png',
    'assets/avatares/avatar12.png',
    'assets/avatares/avatar13.png',
  ];

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      final String nome = _nomeController.text;
      final String email = _emailController.text;
      final String senha = _senhaController.text;
      final String confirmarSenha = _confirmarSenhaController.text;
      final String birthday = _birthdayController.text;

      final dateFormat = DateFormat('dd/MM/yyyy');
      try {
        final parsedDate = dateFormat.parseStrict(birthday);
        final currentYear = DateTime.now().year;
        final birthYear = parsedDate.year;

        if (birthYear < 1900 || birthYear > currentYear) {
          throw FormatException('Data inválida');
        }

        if (senha != confirmarSenha) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('As senhas não coincidem')));
          return;
        }

        try {
          final UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: senha);

          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(userCredential.user!.uid)
              .set({
                'nome': nome,
                'email': email,
                'aniversario': birthday,
                'genero': _genero,
                'avatar': selectedAvatar ?? '',
              });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuário registrado com sucesso!')),
          );

          Navigator.pop(context);
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao registrar: ${e.message}')),
          );
        }
      } on FormatException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na data de nascimento: ${e.message}')),
        );
      }
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

  Widget _inputField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    if (hint.toLowerCase() == 'data de nascimento') {
      inputFormatters = [_dateMaskFormatter];
      keyboardType = TextInputType.number;
    }

    return TextFormField(
      controller: controller,
      obscureText:
          isPassword
              ? (hint == 'Senha' ? !_isSenhaVisible : !_isConfirmarSenhaVisible)
              : false,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontFamily: 'RobotoFlex'),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        suffixIcon:
            isPassword
                ? GestureDetector(
                  onTap: () {
                    setState(() {
                      if (hint == 'Senha') {
                        _isSenhaVisible = !_isSenhaVisible;
                      } else if (hint == 'Confirmar senha') {
                        _isConfirmarSenhaVisible = !_isConfirmarSenhaVisible;
                      }
                    });
                  },
                  child: Icon(
                    _isSenhaVisible || _isConfirmarSenhaVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                )
                : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obrigatório';
        if (hint.toLowerCase() == 'e-mail' && !value.contains('@')) {
          return 'E-mail inválido';
        }
        if (hint.toLowerCase() == 'data de nascimento') {
          if (value.length != 10) return 'Formato inválido (dd/mm/aaaa)';
          try {
            final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(value);
            final now = DateTime.now();
            if (parsedDate.year < 1900 || parsedDate.isAfter(now)) {
              return 'Data fora do intervalo válido';
            }
          } catch (e) {
            return 'Data inválida';
          }
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  'CeliApp',
                  style: TextStyle(
                    fontFamily: 'Krona One',
                    fontSize: 32,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                const SizedBox(height: 20),
                _avatarIcon(),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _inputField('Nome', _nomeController),
                      const SizedBox(height: 15),
                      _inputField(
                        'E-mail',
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      _inputField('Senha', _senhaController, isPassword: true),
                      const SizedBox(height: 15),
                      _inputField(
                        'Confirmar senha',
                        _confirmarSenhaController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      _inputField(
                        'Data de Nascimento',
                        _birthdayController,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          MaskTextInputFormatter(mask: '##/##/####'),
                        ],
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _genero.isEmpty ? null : _genero,
                        style: const TextStyle(
                          fontFamily: 'RobotoFlex',
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Gênero',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            _genero = newValue!;
                          });
                        },
                        items:
                            [
                              'Homem Cisgênero',
                              'Mulher Cisgênero',
                              'Homem Transgênero',
                              'Mulher Transgênero',
                              'Travesti',
                              'Não-Binário',
                              'Prefiro não falar',
                            ].map((genero) {
                              return DropdownMenuItem<String>(
                                value: genero,
                                child: Text(genero),
                              );
                            }).toList(),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Selecione um gênero'
                                    : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _registrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Registrar',
                            style: TextStyle(
                              fontFamily: 'RobotoFlex',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
