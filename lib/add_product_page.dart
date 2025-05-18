import 'package:flutter/material.dart';
import 'product_data.dart';
import 'local_database.dart';

class AddProductPage extends StatefulWidget {
  final String initialCode;
  const AddProductPage({super.key, required this.initialCode});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final ingredientsController = TextEditingController();
  final imageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj produkt lokalnie')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Kod: ${widget.initialCode}', style: const TextStyle(fontSize: 16)),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nazwa'),
                validator: (val) => val!.isEmpty ? 'Wymagane' : null,
              ),
              TextFormField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Marka'),
              ),
              TextFormField(
                controller: ingredientsController,
                decoration: const InputDecoration(labelText: 'Składniki'),
              ),
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'URL zdjęcia'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final product = Product(
                      name: nameController.text,
                      brand: brandController.text,
                      ingredients: ingredientsController.text,
                      imageUrl: imageController.text,
                    );
                    await LocalDatabase.insertProduct(widget.initialCode, product);
                    Navigator.pop(context, product);
                  }
                },
                child: const Text('Zapisz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
