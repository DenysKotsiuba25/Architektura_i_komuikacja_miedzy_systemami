import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'offline_scanner_page.dart';
import 'register_page.dart';  // Importujemy stronę rejestracji

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final url = Uri.parse('https://reqres.in/api/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': 'reqres-free-v1', // Dodajemy klucz API
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      if (token != null) {
        // Zalogowanie i przejście na stronę główną
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OfflineScannerPage(authToken: token),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Brak tokena w odpowiedzi. Skontaktuj się z administratorem.';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Niepoprawny email lub hasło. Status: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Wprowadź email' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Hasło'),
                obscureText: true,
                validator: (val) => val!.isEmpty ? 'Wprowadź hasło' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
                child: const Text('Zaloguj'),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              // Dodajemy przycisk przejścia do strony rejestracji
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Nie masz konta? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text('Zarejestruj się'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
