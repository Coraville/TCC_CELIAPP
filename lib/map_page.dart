import 'dart:async';
import 'dart:convert'; // Para decodificar a resposta JSON
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _selectedIndex = 1;
  bool _isScanning = false;
  String _status = 'idle'; // idle, gluten, sem_gluten
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

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

  void _playSound(String sound) async {
    if (!_player.isPlaying) {
      await _player.startPlayer(
        fromURI:
            'assets/sounds/$sound.mp3', // Adicione seus arquivos de som no diretório assets/sounds
        codec: Codec.mp3,
      );
    }
  }

  // Função para verificar o produto usando o OpenFoodFacts
  Future<void> verificarProduto(String codigo) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v0/product/$codigo.json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Verifica se o produto possui informações de glúten
      final isGlutenFree =
          data['product'] != null &&
          data['product']['ingredients_text'] != null &&
          data['product']['ingredients_text'].toLowerCase().contains(
                'gluten',
              ) ==
              false;

      if (isGlutenFree) {
        setState(() {
          _status = 'sem_gluten';
        });
        _playSound('success'); // Toca som de sucesso
      } else {
        setState(() {
          _status = 'gluten';
        });
        _playSound('error'); // Toca som de erro
      }
    } else {
      setState(() {
        _status = 'idle';
      });
      print('Erro ao obter dados do produto');
    }

    // Restaura o estado após 5 segundos
    Timer(const Duration(seconds: 5), () {
      setState(() {
        _status = 'idle';
        _isScanning = true;
      });
    });
  }

  Widget _buildResultado() {
    if (_status == 'sem_gluten') {
      return Container(
        color: Colors.green,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/success.json', width: 150, height: 150),
            const SizedBox(height: 20),
            const Text(
              'SEM GLÚTEN!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (_status == 'gluten') {
      return Container(
        color: Colors.red,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/error.json', width: 150, height: 150),
            const SizedBox(height: 20),
            const Text(
              'CUIDADO: POSSUI GLÚTEN!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text('Escanear Código de Barras'),
          ),
          const SizedBox(height: 20),
          _isScanning
              ? SizedBox(
                width: 300,
                height: 300,
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null) {
                        setState(() => _isScanning = false);
                        verificarProduto(
                          code,
                        ); // Chama a verificação após escanear
                      }
                    }
                  },
                ),
              )
              : const SizedBox.shrink(),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.startPlayer();
    } catch (e) {
      print("Erro ao inicializar o player de áudio: $e");
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  Future<void> _disposePlayer() async {
    try {
      await _player.stopPlayer();
    } catch (e) {
      print("Erro ao parar o player de áudio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Produtos'),
        backgroundColor: const Color(0xFFE38854),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _buildResultado(),
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
