import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/config/app_config.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // pour kIsWeb
import '../layouts/main_layout.dart';

// -------------------- ADD COLIS PAGE --------------------
class AddColisPage extends StatefulWidget {
  const AddColisPage({super.key});
  @override
  State<AddColisPage> createState() => _AddColisPageState();
}

class _AddColisPageState extends State<AddColisPage> {
  final _formKey = GlobalKey<FormState>();

  String? _token;
  String? selectedBon2CommandeId;
  String? selectedDesignation;
  final TextEditingController poidsController = TextEditingController();
  final TextEditingController descriptifController = TextEditingController();

  bool isLoading = false;
  String message = "";

  int _currentIndex = 2;

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

  // Données API
  List<Map<String, dynamic>> bon2Commandes = [];

  // Fichiers uploadés
  List<PlatformFile> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _fetchBon2Commandes();
  }

  /// 🔹 Récupération des prises en charge pour dropdown
  Future<void> _fetchBon2Commandes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("jwt_token");

      final url = Uri.parse(bon2commandesIndexUrl);
      final response = await http.post(
        url,
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["Response"]?["Bon2Commandes"] != null) {
          final List<dynamic> list = data["Response"]["Bon2Commandes"];
          setState(() {
            bon2Commandes = list
                .map(
                  (item) => {
                    "id": item["id"].toString(),
                    "numprisecharge": item["numprisecharge"] ?? "N/A",
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
      debugPrint("Erreur chargement Bon2Commandes: $e");
    }
  }

  /// 🔹 Sélection des fichiers images
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true, // ⚠️ indispensable pour Flutter Web
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
      });
    }
  }

  /// 🔹 Envoi du formulaire à l’API
  Future<void> _submitForm() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("jwt_token");

    if (_token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = "";
    });

    /*final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');*/

    final url = Uri.parse(encodagesAddUrl);
    final request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $_token";

    // Champs texte
    request.fields["bon2CommandeId"] = selectedBon2CommandeId ?? "";
    request.fields["designation"] = selectedDesignation ?? "";
    request.fields["poids"] = poidsController.text.trim();
    request.fields["descriptif"] = descriptifController.text.trim();

    // Upload fichiers
    // Gestion des fichiers upload
    for (var file in selectedFiles) {
      if (kIsWeb) {
        if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              "images[]",
              file.bytes!,
              filename: file.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        } else {
          debugPrint("⚠️ File bytes is null for ${file.name}");
        }
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "images[]",
            file.path!,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        debugPrint("⚠️ File has no path or bytes: ${file.name}");
      }
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);

      if (response.statusCode == 200 &&
          data["Response"]["Status"] == "Success") {
        setState(() {
          message = "✅ Colis ajouté avec succès !";
        });
        _clearForm();
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context, true); // 🔁 retour avec refresh
        });
      } else if (response.statusCode == 401) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      } else {
        setState(() {
          message =
              "❌ ${data["Response"]["errorMessage"] ?? "Erreur lors de l’ajout"}";
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
    descriptifController.clear();
    selectedBon2CommandeId = null;
    selectedDesignation = null;
    selectedFiles.clear();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Ajouter un Colis",
      currentIndex: _currentIndex,
      onTabSelected: _navigateTo,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Dropdown Prise en charge
              DropdownButtonFormField<String>(
                value: selectedBon2CommandeId,
                decoration: const InputDecoration(
                  labelText: "Prise en charge (Bon2Commande)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                items: bon2Commandes.map((item) {
                  return DropdownMenuItem<String>(
                    value: item["id"],
                    child: Text("N° ${item["numprisecharge"]}"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBon2CommandeId = value;
                  });
                },
                validator: (value) => value == null
                    ? "Veuillez sélectionner une prise en charge"
                    : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Dropdown Designation
              DropdownButtonFormField<String>(
                value: selectedDesignation,
                decoration: const InputDecoration(
                  labelText: "Désignation",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '',
                    child: Text('Select Designation'),
                  ),
                  DropdownMenuItem(value: 'Voiture', child: Text('Voiture')),
                  DropdownMenuItem(
                    value: 'Électroménager',
                    child: Text('Électroménager'),
                  ),
                  DropdownMenuItem(value: 'Meuble', child: Text('Meuble')),
                  DropdownMenuItem(
                    value: 'Electronique',
                    child: Text('Electronique'),
                  ),
                  DropdownMenuItem(
                    value: 'Bureautique',
                    child: Text('Bureautique'),
                  ),
                  DropdownMenuItem(
                    value: 'Effet personnel',
                    child: Text('Effet personnel'),
                  ),
                  DropdownMenuItem(value: 'Autres', child: Text('Autres')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDesignation = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? "Veuillez sélectionner une désignation"
                    : null,
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
                  if (value == null || value.isEmpty) return "Poids requis";
                  if (double.tryParse(value) == null) return "Poids invalide";
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
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Descriptif requis" : null,
              ),
              const SizedBox(height: 20),

              // 🔹 Upload fichiers
              ElevatedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text("Ajouter des images"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
              if (selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedFiles
                      .map((f) => Chip(label: Text(f.name)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 30),

              // 🔹 Bouton enregistrer
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
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
