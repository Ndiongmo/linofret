// -------------------- REGISTER PAGE --------------------
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/*const String baseHost =
    "http://localhost"; // <-- change to http://10.0.2.2 for Android emulator*/
const String loginUrl = "$baseHost/thinkfreight/api/v1/clients/token.json";
const String registerUrl = "$baseHost/thinkfreight/api/v1/clients/add.json";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final Map<String, TextEditingController> fields = {
    'nom': TextEditingController(),
    'prenom': TextEditingController(),
    'adresse1': TextEditingController(),
    'tel': TextEditingController(),
    'mobile': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'pays': TextEditingController(),
    'ville': TextEditingController(),
  };
  bool isLoading = false;
  String message = "";

  Future<void> doRegister() async {
    // basic validation
    for (var e in fields.entries) {
      if (e.value.text.trim().isEmpty) {
        setState(() {
          message = 'Champ ${e.key} obligatoire';
        });
        return;
      }
    }

    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final resp = await http.post(
        Uri.parse(registerUrl), // REGISTER_URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          for (var entry in fields.entries) entry.key: entry.value.text.trim(),
        }),
      );

      final data = json.decode(resp.body);
      if (resp.statusCode == 200 && data["Response"]["Status"] == "Success") {
        setState(() {
          message = '✅ Inscription réussie. Connectez-vous.';
        });
        // optionally go back to login
        Future.delayed(
          const Duration(seconds: 1),
          () => Navigator.of(context).pop(),
        );
      } else if (resp.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      } else {
        setState(() {
          message =
              '❌ ${data["Response"]["errorMessage"] ?? 'Erreur inscription'}';
        });
      }
    } catch (e) {
      setState(() {
        message = '⚠️ Erreur: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInput(
    String key,
    String label, {
    bool obscure = false,
    bool hidden = false,
  }) {
    final ctrl = fields[key]!;
    if (hidden) {
      // hidden with default values - used if needed
      ctrl.text = ctrl.text.isEmpty ? 'default' : ctrl.text;
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (var entry in fields.entries)
              _buildInput(
                entry.key,
                entry.key[0].toUpperCase() + entry.key.substring(1),
                obscure: entry.key == 'password',
              ),
            const SizedBox(height: 12),
            if (isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: doRegister,
                icon: const Icon(Icons.send),
                label: const Text("S’inscrire"),
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
            const SizedBox(height: 10),
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
