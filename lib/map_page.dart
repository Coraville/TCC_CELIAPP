import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/services.dart' show rootBundle;

// RouteObserver global
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with WidgetsBindingObserver, RouteAware {
  int _selectedIndex = 1;
  bool _isScanning = true; // scanner ativo por padrão
  String _status = 'idle'; // idle, checking, gluten, sem_gluten
  late MobileScannerController _cameraController;
  Map<String, dynamic>? _glutenProductsLocal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocalGlutenData();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void didPopNext() {
    setState(() {
      _isScanning = true;
      _status = 'idle';
    });
  }

  Future<void> _loadLocalGlutenData() async {
    final jsonString = await rootBundle.loadString(
      'assets/gluten_products.json',
    );
    setState(() {
      _glutenProductsLocal = jsonDecode(jsonString);
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/recipes');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/shopping_list');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/info');
        break;
    }
  }

  Future<void> verificarProduto(String codigo) async {
    setState(() {
      _status = 'checking';
      _isScanning = false;
    });

    final url = 'https://br.openfoodfacts.org/api/v0/product/$codigo.json';

    final List<String> glutenKeywordsLocal = [
      'gluten',
      'trigo',
      'cevada',
      'centeio',
      'malte',
      'farinha',
      'farelo',
      'amido de trigo',
      'pode conter glúten',
      'contém glúten',
      'contém gluten',
      'pode conter trigo',
      'pode conter cevada',
      'pode conter centeio',
      'pode conter malte',
      'aveia',
      'trigos',
      'glúten',
    ];

    final glutenAbsencePhrases = [
      'sem gluten',
      'gluten free',
      'não contém gluten',
      'não contém trigo',
      'isento de gluten',
      'livre de gluten',
    ];

    bool isGlutenLocal = false;

    try {
      if (_glutenProductsLocal != null &&
          _glutenProductsLocal!.containsKey(codigo)) {
        final productInfo = _glutenProductsLocal![codigo];
        if (productInfo is Map<String, dynamic> &&
            productInfo['contains_gluten'] == true) {
          isGlutenLocal = true;
        }
      }

      if (isGlutenLocal) {
        setState(() {
          _status = 'gluten';
        });
      } else {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final product = data['product'];
          if (product != null) {
            final allergens = List<String>.from(
              product['allergens_tags'] ?? [],
            );
            final labels = List<String>.from(product['labels_tags'] ?? []);
            final rawIngredients =
                (product['ingredients_text'] ?? '').toString();
            final ingredients = removeDiacritics(rawIngredients.toLowerCase());
            final normalizedAllergens =
                allergens.map(removeDiacritics).toList();
            final normalizedLabels = labels.map(removeDiacritics).toList();

            final hasGlutenTag =
                normalizedAllergens.contains('en:gluten') ||
                normalizedAllergens.contains('pt:gluten') ||
                normalizedLabels.contains('en:gluten') ||
                normalizedLabels.contains('pt:gluten');

            final containsGlutenLocal = glutenKeywordsLocal.any(
              (keyword) => ingredients.contains(keyword),
            );
            final containsNoGluten = glutenAbsencePhrases.any(
              (phrase) => ingredients.contains(phrase),
            );

            if ((hasGlutenTag || containsGlutenLocal) && !containsNoGluten) {
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
              _status = 'sem_gluten';
            });
          }
        } else {
          setState(() {
            _status = 'gluten';
          });
        }
      }
    } catch (e) {
      setState(() {
        _status = 'sem_gluten';
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
      return const Center(child: CircularProgressIndicator());
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFFFF6E40),
      ),
      body: Stack(
        children: [
          Visibility(
            visible: _isScanning,
            child: MobileScanner(
              controller: _cameraController,
              fit: BoxFit.cover,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && _isScanning) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    setState(() {
                      _isScanning = false;
                    });
                    verificarProduto(code);
                  }
                }
              },
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                _status != 'idle' ? _buildResultado() : const SizedBox.shrink(),
          ),
        ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Receitas',
          ),
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
