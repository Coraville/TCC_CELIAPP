import 'dart:async';
import 'dart:convert';
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
  bool _isScanning = true;
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
        fromURI: 'assets/sounds/$sound.mp3',
        codec: Codec.mp3,
      );
    }
  }

  Future<void> verificarProduto(String codigo) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v0/product/$codigo.json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

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
        _playSound('success');
      } else {
        setState(() {
          _status = 'gluten';
        });
        _playSound('error');
      }
    } else {
      setState(() {
        _status = 'idle';
      });
    }

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
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF98FF96),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/images/success.json',
                width: 150,
                height: 150,
              ),
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
        ),
      );
    } else if (_status == 'gluten') {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFB21613),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/images/error.json', width: 150, height: 150),
              const SizedBox(height: 20),
              const Text(
                'CUIDADO: CONTÉM GLUTÉN',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
            ),
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null && _isScanning) {
                  setState(() => _isScanning = false);
                  verificarProduto(code);
                }
              }
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigationBar(
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
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'Scanner',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Receitas',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lista'),
                BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _player.stopPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _buildResultado(),
      ),
    );
  }
}
