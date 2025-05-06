import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _selectedIndex = 1;
  bool _isScanning = false;
  String _status = 'idle'; // idle, gluten, sem_gluten

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

  Future<void> verificarProduto(String codigo) async {
    setState(() {
      _status = 'checking';
    });

    final url = 'https://br.openfoodfacts.org/api/v0/product/$codigo.json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = data['product'];

        if (product != null) {
          final allergens = List<String>.from(product['allergens_tags'] ?? []);
          final labels = List<String>.from(product['labels_tags'] ?? []);
          final ingredients =
              (product['ingredients_text'] ?? '').toString().toLowerCase();

          final hasGlutenTag =
              allergens.contains('en:gluten') || labels.contains('en:gluten');
          final containsWordGluten = ingredients.contains('gluten');

          if (hasGlutenTag || containsWordGluten) {
            setState(() {
              _status = 'gluten';
            });
          } else {
            setState(() {
              _status = 'sem_gluten';
            });
          }
        } else {
          setState(() {
            _status = 'sem_gluten'; // Produto não encontrado
          });
        }
      } else {
        setState(() {
          _status = 'sem_gluten'; // Erro de resposta
        });
      }
    } catch (e) {
      setState(() {
        _status = 'sem_gluten'; // Erro de conexão ou parsing
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
        color: Colors.green,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/success.json',
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
      );
    } else if (_status == 'gluten') {
      return Container(
        color: Colors.red,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/error.json',
              width: 150,
              height: 150,
            ),
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
    } else if (_status == 'checking') {
      return Center(child: CircularProgressIndicator());
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
            child: const Text('Escanear'),
          ),
          const SizedBox(height: 30),
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
                        ); // Verifica o produto usando a API
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFFFF6E40),
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
            icon: Icon(Icons.shopping_cart),
            label: 'Lista de Compras',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Informações'),
        ],
      ),
    );
  }
}
