import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/config/app_config.dart';
import '../layouts/main_layout.dart';

// -------------------- ADD PRISE PAGE --------------------
class AddPrisePage extends StatefulWidget {
  const AddPrisePage({super.key});

  @override
  State<AddPrisePage> createState() => _AddPriseEnChargePageState();
}

class _AddPriseEnChargePageState extends State<AddPrisePage> {
  final formKey = GlobalKey<FormState>();
  String? _token;

  // Contrôleurs
  final TextEditingController poidsController = TextEditingController();
  final TextEditingController descriptifController = TextEditingController();
  final TextEditingController doorEnlevementController =
      TextEditingController();
  final TextEditingController doorLivraisonController = TextEditingController();

  // Champs cachés
  String enlevementId = "3";
  String livraisonId = "4";

  // Dropdown destinataire
  List<Map<String, dynamic>> destinataires = [];
  String? selectedDestinataireId;

  bool isLoading = false;
  String message = "";

  int _currentIndex = 1;

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
  void initState() {
    super.initState();
    _fetchDestinataires();
  }

  /// 🔹 Récupération de la liste des destinataires
  Future<void> _fetchDestinataires() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("jwt_token");

      if (_token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final url = Uri.parse(destinatairesUrl);
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["Response"]?["Destinataires"] != null) {
          final List<dynamic> list = data["Response"]["Destinataires"];

          setState(() {
            destinataires = list
                .map(
                  (item) => {
                    "id": item["destinataire"]["id"].toString(),
                    "name":
                        "${item["destinataire"]["nom"]} ${item["destinataire"]["prenom"]}",
                  },
                )
                .toList();
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      }
    } catch (e) {
      debugPrint("Erreur chargement destinataires: $e");
    }
  }

  /// 🔹 Envoi du formulaire à l’API
  Future<void> _submitForm() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = "";
    });

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("jwt_token");

    final url = Uri.parse(bon2commandesAddUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: json.encode({
          "destinataireId": selectedDestinataireId,
          "poids": poidsController.text.trim(),
          "descriptif": descriptifController.text.trim(),
          "enlevementId": enlevementId,
          "doorEnlevement": doorEnlevementController.text.trim(),
          "livraisonId": livraisonId,
          "doorLivraison": doorLivraisonController.text.trim(),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data["Response"]["Status"] == 'Success') {
        setState(() {
          message = "✅ Prise en charge enregistrée avec succès !";
        });
        _clearForm();
        Future.delayed(
          const Duration(milliseconds: 800),
          () => Navigator.of(context).pop(),
        );
      } else if (response.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      } else {
        setState(() {
          message =
              "❌ ${data["Response"]["errorMessage"] ?? "Erreur lors de l’enregistrement"}";
        });
      }
    } catch (e) {
      setState(() {
        message = "⚠️ Erreur réseau : $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearForm() {
    poidsController.clear();
    //descriptifController.clear();
    doorEnlevementController.clear();
    doorLivraisonController.clear();
    selectedDestinataireId = null;
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Nouvelle PeC",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // 🔹 Liste déroulante destinataire
              DropdownButtonFormField<String>(
                value: selectedDestinataireId,
                decoration: const InputDecoration(
                  labelText: "Destinataire",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: destinataires.map((item) {
                  return DropdownMenuItem<String>(
                    value: item["id"],
                    child: Text(item["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDestinataireId = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Veuillez choisir un destinataire" : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Poids
              TextFormField(
                controller: poidsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Poids (kg)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez renseigner le poids";
                  }
                  if (double.tryParse(value) == null) {
                    return "Poids invalide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 🔹 Descriptif
              TextFormField(
                controller: descriptifController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descriptif",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Descriptif requis" : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Door Enlevement
              TextFormField(
                controller: doorEnlevementController,
                decoration: const InputDecoration(
                  labelText: "Adresse d’enlèvement (doorEnlevement)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Adresse d’enlèvement requise"
                    : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Door Livraison
              TextFormField(
                controller: doorLivraisonController,
                decoration: const InputDecoration(
                  labelText: "Adresse de livraison (doorLivraison)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Adresse de livraison requise"
                    : null,
              ),
              const SizedBox(height: 30),

              // 🔹 Bouton enregistrer
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
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
              const SizedBox(height: 20),

              // 🔹 Message de retour
              Text(
                message,
                style: TextStyle(
                  color: message.startsWith("✅")
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
