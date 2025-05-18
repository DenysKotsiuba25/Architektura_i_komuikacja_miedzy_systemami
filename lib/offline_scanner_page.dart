import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_data.dart';
import 'add_product_page.dart';
import 'local_database.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'login_page.dart'; // 

class OfflineScannerPage extends StatefulWidget {
  final String authToken;
  const OfflineScannerPage({super.key, required this.authToken});

  @override
  State<OfflineScannerPage> createState() => _OfflineScannerPageState();
}

class _OfflineScannerPageState extends State<OfflineScannerPage> {
  final TextEditingController _controller = TextEditingController();
  Product? foundProduct;
  String? error;

  Future<Product?> fetchProductFromAPI(String code) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$code.json');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          return Product(
            name: product['product_name'] ?? 'Brak nazwy',
            brand: product['brands'] ?? 'Brak marki',
            ingredients: product['ingredients_text'] ?? 'Brak składu',
            imageUrl: product['image_front_small_url'] ?? 'https://via.placeholder.com/150',
          );
        }
      }
    } catch (e) {
      print('Błąd: $e');
    }

    return null;
  }

  void fetchProduct(String code) async {
    setState(() {
      foundProduct = null;
      error = null;
    });

    final product = await fetchProductFromAPI(code);
    if (product != null) {
      setState(() {
        foundProduct = product;
      });
    } else {
      final local = await LocalDatabase.getProduct(code);
      if (local != null) {
        setState(() {
          foundProduct = local;
        });
      } else {
        setState(() {
          error = 'Nie znaleziono produktu. Możesz go dodać.';
        });
      }
    }
  }

  void _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (result != null && result is String) {
      _controller.text = result;
      fetchProduct(result);
    }
  }

  void _addProduct() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductPage(initialCode: code),
      ),
    );

    if (result != null && result is Product) {
      setState(() {
        foundProduct = result;
        error = null;
      });
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skaner Produktów'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Wprowadź kod kreskowy'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final code = _controller.text.trim();
                    if (code.isNotEmpty) fetchProduct(code);
                  },
                  child: const Text('Szukaj'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _scanBarcode,
                  child: const Text('Skanuj kod'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (foundProduct != null) ...[
              Text('Znaleziono:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Image.network(foundProduct!.imageUrl, height: 100),
              Text('Nazwa: ${foundProduct!.name}'),
              Text('Marka: ${foundProduct!.brand}'),
              Text('Składniki: ${foundProduct!.ingredients}'),
            ] else if (error != null) ...[
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Dodaj produkt lokalnie'),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skanuj kod')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            Navigator.pop(context, barcode.rawValue!);
          }
        },
      ),
    );
  }
}
