import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/config/app_config.dart';
import '../layouts/main_layout.dart';

// -------------------- ADD DESTINATAIRE PAGE --------------------
class AddDestinatairePage extends StatefulWidget {
  const AddDestinatairePage({super.key});
  @override
  State<AddDestinatairePage> createState() => _AddDestinatairePageState();
}

class _AddDestinatairePageState extends State<AddDestinatairePage> {
  final Map<String, TextEditingController> fields = {
    'nom': TextEditingController(),
    'prenom': TextEditingController(),
    'adresse1': TextEditingController(),
    'tel': TextEditingController(),
    'mobile': TextEditingController(),
    'email': TextEditingController(
      text: 'default@linofret.com',
    ), // default value (hidden requirement)
    'password': TextEditingController(
      text: 'defaultpass@123',
    ), // default value (hidden)
    'pays': TextEditingController(),
    'ville': TextEditingController(),
  };
  String message = '';
  bool loading = false;
  String? _token;

  Future<void> submit() async {
    // required fields check
    if (fields['nom']!.text.trim().isEmpty ||
        fields['prenom']!.text.trim().isEmpty) {
      setState(() {
        message = 'Nom & Prenom requis';
      });
      return;
    }
    setState(() {
      loading = true;
      message = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("jwt_token");

      if (_token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final resp = await http.post(
        Uri.parse(destinataireAddUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          for (var e in fields.entries) e.key: e.value.text.trim(),
        }),
      );
      final data = json.decode(resp.body);
      if (resp.statusCode == 200 && data["Response"]["Status"] == "Success") {
        setState(() {
          message = '✅ Destinataire ajouté';
        });
        Future.delayed(
          const Duration(milliseconds: 800),
          () => Navigator.of(context).pop(),
        );
      } else if (resp.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      } else {
        setState(() {
          message = '❌ ${data["Response"]["errorMessage"] ?? 'Erreur'}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Erreur: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _field(String key, String label, {bool hidden = false}) {
    if (hidden) return const SizedBox.shrink();
    if (key == 'nom' || key == 'prenom') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: fields[key],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
          ),
        ),
      );
    } else if (key == 'tel' || key == 'mobile') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: fields[key],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone, color: Colors.blue.shade700),
          ),
        ),
      );
    } else if (key == 'adresse1') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: fields[key],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.home, color: Colors.blue.shade700),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: fields[key],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city, color: Colors.blue.shade700),
          ),
        ),
      );
    }
  }

  int _currentIndex = 3;

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/pec');
        break;
      case 2:
        Navigator.pushNamed(context, '/colis');
        break;
      case 3:
        Navigator.pushNamed(context, '/destinataires');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Ajout",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _field('nom', 'Nom'),
            _field('prenom', 'Prénom'),
            _field('adresse1', 'Adresse1'),
            _field('tel', 'Tel'),
            _field('mobile', 'Mobile'),
            // email & password are hidden as requested (but kept default value)
            const SizedBox(height: 6),
            _field('pays', 'Pays'),
            _field('ville', 'Ville'),
            const SizedBox(height: 10),
            if (loading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Enregistrer" /*,
                  style: TextStyle(color: Colors.white),*/,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (message.isNotEmpty)
              Text(
                message,
                style: TextStyle(
                  color: message.startsWith('✅') ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
